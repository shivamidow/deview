//===---------------------- EnableWebAPIMarking.cpp -----------------------===//
//                    Enable web api marking for chromium
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Scalar/EnableWebAPIMarking.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Demangle/Demangle.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/IR/IRBuilder.h"
#include <set>
#include <map>
#include <string.h>
#include <iostream>
#include <fstream>
#include <sstream>

using namespace llvm;
using namespace std;

#define DEBUG_TYPE "enable-web-api-marking"

namespace llvm {
void initializeEnableWebAPIMarkingPassPass(PassRegistry&);
} // end namespace llvm

namespace {

class EnableWebAPIMarkingPass : public ModulePass {
  APInt Duplicate;
  APInt Amend;

public:
  static char ID;
  static map<string, map<string, int> > FunctionIndexes;
  void read_indexes();

  EnableWebAPIMarkingPass()
    : ModulePass(ID) {
    initializeEnableWebAPIMarkingPassPass(*PassRegistry::getPassRegistry());
  }

  bool runOnModule(Module &M) override;
  void instrumentFunction(Function& F, Module& M, int idx);

  /*	
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<LoopInfoWrapperPass>();
  }
  */

  void replace(std::string& str, const std::string& from, const std::string& to) {
    if (from.empty())
      return;

    size_t start_pos = 0;
    while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
      str.replace(start_pos, from.length(), to);
      start_pos += to.length(); // In case 'to' contains 'from', like replacing 'x' with 'yx'
    }
  }

  inline bool starts_with(const std::string& str, const std::string& prefix) {
    return str.find(prefix) == 0;
  }

  inline bool ends_with(const std::string& str, const std::string& suffix) {
    return str.size() >= suffix.size()
        && std::equal(str.rbegin(), str.rbegin() + suffix.size(), suffix.rbegin(), suffix.rend());
  }

  inline bool contains(const std::string& str, const std::string& substr) {
      return str.find(substr) != std::string::npos;
  }

  std::string getBaseName(const std::string& path) {
    std::size_t found = path.find_last_of("/\\");
    return found == std::string::npos ? "" : path.substr(found + 1);
  }

  bool isJSAPI(const std::string& basename, const std::string& func_basename, const std::string& classname) {
    return (
            starts_with(basename, "v8_")
//            && !starts_with(basename, "v8_idb_")
//            && !ends_with(basename, "cache.cc")
//            && !ends_with(basename, "crypto.cc")
//            && !ends_with(basename, "crypto_key.cc")
//            && !ends_with(basename, "event.cc")
//            && !contains(basename, "worker")
            && !ends_with(classname, "v8_internal")
        )
        && (
            ends_with(func_basename, "AttributeSetterCallback")
            || ends_with(func_basename, "AttributeGetterCallback")
            || ends_with(func_basename, "ConstructorCallback")
            || ends_with(func_basename, "MethodCallback")
        );
  }

  bool isHTMLAPI(const std::string& basename, const std::string& func_basename) {
    return (
            basename == "html_element_factory.cc"
            || basename == "mathml_element_factory.cc"
            || basename == "svg_element_factory.cc"
        )
        && ends_with(func_basename, "Constructor");
  }

  bool isCSSAPI(const std::string& basename, const std::string& func_basename) {
    return (basename == "shorthands.cc"
            || basename == "shorthands_custom.cc"
            || basename == "longhands.cc"
            || basename == "longhands_custom.cc")
            // longhands.cc
        && (ends_with(func_basename, "ApplyInherit")
            || ends_with(func_basename, "ApplyInitial")
            || ends_with(func_basename, "ApplyValue")
            || ends_with(func_basename, "GetJSPropertyName")
//            || ends_with(func_basename, "GetPropertyName")    // crash causer
//            || ends_with(func_basename, "GetPropertyNameAtomicString")    // crash causer
//            || ends_with(func_basename, "GetVisitedProperty")    // crash causer
            // longhands_custom.cc
            || ends_with(func_basename, "CSSValueFromComputedStyleInternal")
            || ends_with(func_basename, "ColorIncludingFallback")
            || ends_with(func_basename, "InitialValue")
            //|| ends_with(func_basename, "IsLayoutDependent")
            || ends_with(func_basename, "ParseSingleValue")
            // shorthands.cc
//            || ends_with(func_basename, "Exposure")    // crash causer
            //|| ends_with(func_basename, "IsLayoutDependentProperty")
            || ends_with(func_basename, "ParseShorthand")
//            || ends_with(func_basename, "ResolveDirectionAwareProperty")    // crash causer
            // shorthands_custom.cc, optional
            || ends_with(func_basename, "ConsumeAnimationValue")
            || ends_with(func_basename, "ConsumeFont")
            || ends_with(func_basename, "ConsumeImplicitAutoFlow")
            || ends_with(func_basename, "ConsumeSystemFont")
            || ends_with(func_basename, "ConsumeTransitionValue"));
  }

  bool isWebAPI(const std::string& module_path, const std::string& func_basename, const std::string& classname) {
    std::string basename(getBaseName(module_path));
    return isHTMLAPI(basename, func_basename)
        || isJSAPI(basename, func_basename, classname)
        || isCSSAPI(basename, func_basename);
  }

  //===========string split begins===========
  template<typename Out>
  void split(const std::string &s, char delim, Out result) {
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
      *(result++) = item;
    }
  }

  std::vector<std::string> split(const std::string &s, char delim) {
    std::vector<std::string> elems;
    split(s, delim, std::back_inserter(elems));
    return elems;
  }
  //============string split ends==============

  void mark_func(Module& M, Function& F, int id) {
    // first basic block
    BasicBlock* entry_bb = &(F.getEntryBlock());
    IRBuilder <> builder(M.getContext());

    // the new basic blocks for instrumentation:
    // cx_global_function_id = id
    // jmp entry
    //
    // entry:
    //
    // exit
    BasicBlock* mark_bb = BasicBlock::Create(M.getContext(), entry_bb->getName() + ".mark_cov", &F, entry_bb);

    PointerType* i32PtrTy = PointerType::get(IntegerType::get(M.getContext(), 32), 0);
    string cx_global_function_id_name = "cx_global_function_id";
    GlobalVariable* cx_global_function_id = M.getGlobalVariable(cx_global_function_id_name);
    if (!cx_global_function_id) {
      cx_global_function_id = new GlobalVariable(M, i32PtrTy, false,
          GlobalVariable::CommonLinkage, ConstantPointerNull::get(i32PtrTy), cx_global_function_id_name);

      MaybeAlign align(4);
      cx_global_function_id->setAlignment(align);
    }

    // cx_global_function_id = id
    builder.SetInsertPoint(mark_bb);
    Type* i32Ty = builder.getInt32Ty();
    builder.CreateStore(ConstantInt::get(i32Ty, id), cx_global_function_id);
    builder.CreateBr(entry_bb);
  }	
};
} // end anonymous namespace

char EnableWebAPIMarkingPass::ID = 42;
map<string, map<string, int>> EnableWebAPIMarkingPass::FunctionIndexes = map<string, map<string, int>>();

INITIALIZE_PASS_BEGIN(EnableWebAPIMarkingPass,
    "enable-web-api-marking", "Leave a mark in each function.", false, false)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_END(EnableWebAPIMarkingPass,
    "enable-web-api-marking", "Leave a mark in each function.", false, false)

void EnableWebAPIMarkingPass::instrumentFunction(Function& F, Module& M, int index) {
	mark_func(M, F, index);
}

void EnableWebAPIMarkingPass::read_indexes() {
  const char* index_file = getenv("SLIMIUM_UNIQUE_INDEX_PATH");
  if (!index_file) {
    outs() << "SLIMIUM_UNIQUE_INDEX_PATH is not set. Will use /tmp/unique_indexes.txt instead." << '\n';
    index_file = "/tmp/unique_indexes.txt";
  }
  
  ifstream infile = ifstream(index_file);
  if (!infile.is_open())
      return;
  
  string line;
  while (getline(infile, line)) {
    vector<string> tokens = split(line, ' ');
    string file_name = tokens[0];

    FunctionIndexes[file_name] = map<string, int> ();

    int function_num = (tokens.size() - 1) / 2;
    for (int i = 0; i < function_num; i++) {
      int idx = stoi(tokens[i * 2 + 1]);
      string func_name = tokens[i * 2 + 2];
      FunctionIndexes[file_name][func_name] =  idx;
    }
  }
  infile.close();
}

bool EnableWebAPIMarkingPass::runOnModule(Module &M) {
  if (!FunctionIndexes.size())
    read_indexes();

  std::string module_path = M.getName().str();
  if (FunctionIndexes.find(module_path) == FunctionIndexes.end())
    errs() << "Cannot find indexes for " << module_path << '\n';

  size_t basename_buffer_size = 1;
  size_t classname_buffer_size = 1;
  char* basename_buffer = static_cast<char*>(std::malloc(basename_buffer_size));
  char* classname_buffer = static_cast<char*>(std::malloc(classname_buffer_size));

  llvm::ItaniumPartialDemangler Demangler;
  map<string, int> function_index_map = FunctionIndexes[module_path];

  for (Function &F : M) {
    // skip special functions
    if (F.isDeclaration() || F.isIntrinsic() || F.empty())
      continue;

    string func_name = F.getName().str();
    Demangler.partialDemangle(func_name.c_str());
    basename_buffer = Demangler.getFunctionBaseName(basename_buffer, &basename_buffer_size);
    classname_buffer = Demangler.getFunctionDeclContextName(classname_buffer, &classname_buffer_size);
    if (!basename_buffer)
      continue;

    std::string func_basename(basename_buffer);
    std::string classname(classname_buffer);
    if (!isWebAPI(module_path, func_basename, classname))
        continue;

    if (function_index_map.find(func_name) == function_index_map.end()) {
      errs() << "Cannot find index for " << func_name << '\n';
      continue;
    }

    instrumentFunction(F, M, function_index_map[func_name]);
  }

  std::free(basename_buffer);
  std::free(classname_buffer);
  return true;
}

namespace llvm {
ModulePass* createEnableWebAPIMarkingPass() {
  return new EnableWebAPIMarkingPass();
}
} // end namespace llvm
