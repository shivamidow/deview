//===--------------------- EnableWebAPIProfiling.cpp ----------------------===//
//                   Enable web api profiling for chromium
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Scalar/EnableWebAPIProfiling.h"

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

#define DEBUG_TYPE "enable-web-api-profiling"

namespace llvm {
void initializeEnableWebAPIProfilingPassPass(PassRegistry&);
} // end namespace llvm

namespace {

class EnableWebAPIProfilingPass : public ModulePass {
  APInt Duplicate;
  APInt Amend;

public:
  static char ID;
  static map<string, map<string, int> > FunctionIndexes;
  void read_indexes();

  EnableWebAPIProfilingPass()
    : ModulePass(ID) {
    initializeEnableWebAPIProfilingPassPass(*PassRegistry::getPassRegistry());
  }

  bool runOnModule(Module &M) override;
  void instrumentFunction(Function& F, Module& M, int idx);

  /*
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
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

  void record_cov(Module& M, Function& F, int id) {
    // first basic block
    BasicBlock* entry_bb = &(F.getEntryBlock());
    IRBuilder <> builder(M.getContext());

    // get or create shmget, shmat, shmdt
    // declare dso_local i32 @shmget(i32, i64, i32)
    Function *shm_get = M.getFunction("shmget");
    if (!shm_get) {
      vector<Type*> param_tys;
      param_tys.push_back(IntegerType::get(M.getContext(), 32));
      param_tys.push_back(IntegerType::get(M.getContext(), 64));
      param_tys.push_back(IntegerType::get(M.getContext(), 32));

      Type* result_ty = IntegerType::get(M.getContext(), 32);
      FunctionType* func_ty = FunctionType::get(result_ty, param_tys, false);
      shm_get = Function::Create(func_ty, GlobalValue::ExternalLinkage, "shmget", &M);

      AttributeList al;
      shm_get->setAttributes(al);
    }

    // declare dso_local i8* @shmat(i32, i8*, i32)
    Function *shm_at = M.getFunction("shmat");
    if (!shm_at) {
      vector<Type*> param_tys;
      param_tys.push_back(IntegerType::get(M.getContext(), 32));
      param_tys.push_back(PointerType::get(IntegerType::get(M.getContext(), 8), 0));
      param_tys.push_back(IntegerType::get(M.getContext(), 32));

      Type* result_ty = PointerType::get(IntegerType::get(M.getContext(), 8), 0);
      FunctionType *func_ty = FunctionType::get(result_ty, param_tys, false);
      shm_at = Function::Create(func_ty, GlobalValue::ExternalLinkage, "shmat", &M);

      AttributeList al;
      shm_at->setAttributes(al);
    }

    // declare dso_local i32 @shmdt(i8*)
    Function *shm_dt = M.getFunction("shmdt");
    if (!shm_dt) {
      vector<Type*> param_tys;
      param_tys.push_back(PointerType::get(IntegerType::get(M.getContext(), 8), 0));

      Type* result_ty = IntegerType::get(M.getContext(), 32);
      FunctionType *func_ty = FunctionType::get(result_ty, param_tys, false);
      shm_dt = Function::Create(func_ty, GlobalValue::ExternalLinkage, "shmdt", &M);

      AttributeList al;
      shm_dt->setAttributes(al);
    }

    /*
    // the new basic blocks for instrumentation:
    if (!is_func_recorded) {
      is_func_recorded = true;
      if (cov_sh_mem == 0) {
        x = shmget(...);
        cov_sh_mem = shmat(x, ...);
      }
      cov_sh_mem[...] |= mask;
    }
    entry:
    */

    BasicBlock* record_bb = BasicBlock::Create(M.getContext(), entry_bb->getName() + ".record_cov", &F, entry_bb);
    BasicBlock* get_shm_bb = BasicBlock::Create(M.getContext(), entry_bb->getName() + ".get_shm", &F, record_bb);
    BasicBlock* check_shm_bb = BasicBlock::Create(M.getContext(), entry_bb->getName() + ".check_shm", &F, get_shm_bb);
    BasicBlock* check_record_bb = BasicBlock::Create(M.getContext(), entry_bb->getName() + ".check_record", &F, check_shm_bb);

    // create global variable for recording only once, initialized to 0
    string func_name = F.getName().str();
    string is_func_recorded = "is_" + func_name + "_recorded";
    Type* i8Ty = builder.getInt8Ty();
    GlobalVariable* is_recorded = new GlobalVariable(M, i8Ty, false,
        GlobalValue::PrivateLinkage, ConstantInt::get(i8Ty, 0), is_func_recorded);

    // create global variable for shared memory:sh_mem, initialized to 0
    string cov_sh_mem_name = "cov_sh_mem";
    PointerType* i32PtrTy = PointerType::get(IntegerType::get(M.getContext(), 32), 0);
    //PointerType* i32PtrPtrTy = PointerType::get(i32PtrTy, 0);
    GlobalVariable* cov_sh_mem = M.getGlobalVariable(cov_sh_mem_name);
    if (!cov_sh_mem) {
      cov_sh_mem = new GlobalVariable(M, i32PtrTy, false,
          GlobalVariable::CommonLinkage, ConstantPointerNull::get(i32PtrTy), cov_sh_mem_name);
      MaybeAlign align(4);
      cov_sh_mem->setAlignment(align);
    }

    // if is_func_name_recorded == 0
    builder.SetInsertPoint(check_record_bb);
    Value* load_inst = builder.CreateLoad(i8Ty, is_recorded);
    Value* cmp_inst = builder.CreateICmpEQ(load_inst, ConstantInt::get(i8Ty, 0));
    builder.CreateCondBr(cmp_inst, check_shm_bb, entry_bb);

    // set is_func_name_recorded = 1, record the coverage
    builder.SetInsertPoint(check_shm_bb);
    builder.CreateStore(ConstantInt::get(i8Ty, 1), is_recorded);
    Value* load_cov_sh_mem = builder.CreateLoad(i32PtrTy, cov_sh_mem);
    Value* cmp_cov_sh_mem = builder.CreateICmpEQ(load_cov_sh_mem, ConstantPointerNull::get(i32PtrTy));
    builder.CreateCondBr(cmp_cov_sh_mem, get_shm_bb, record_bb);

    // shmget(i32 key, i64 shm_size_in_byte, i32 shmget_options)
    // %x = call i32 @shmget(285738243, i64 1158796, i32 144)
    builder.SetInsertPoint(get_shm_bb);
    vector<Value*> shm_get_params;
    shm_get_params.push_back(ConstantInt::get(builder.getInt32Ty(), 285738243));

    char* shm_size = getenv("SLIMIUM_SHM_SIZE");
    if (!shm_size)
      outs() << "SLIMIUM_SHM_SIZE is not set. Will use the default size instead." << '\n';

    shm_get_params.push_back(ConstantInt::get(builder.getInt64Ty(), shm_size ? atol(shm_size) : 124464));
    shm_get_params.push_back(ConstantInt::get(builder.getInt32Ty(), 144));

    Value* shmget_call = builder.CreateCall(shm_get, shm_get_params, "call_shmget");
    //%y = call i8* @shmat(i32 %x, i8* null, i32 0)
    vector<Value*> shm_at_params;
    shm_at_params.push_back(shmget_call);
    shm_at_params.push_back(ConstantPointerNull::get(PointerType::get(IntegerType::get(M.getContext(), 8), 0)));
    shm_at_params.push_back(ConstantInt::get(builder.getInt32Ty(), 0));

    Value* shmat_call = builder.CreateCall(shm_at, shm_at_params, "call_shmat");
    Value* shmat_call_int_ptr = builder.CreateBitCast(shmat_call, PointerType::get(IntegerType::get(M.getContext(), 32), 0));
    builder.CreateStore(shmat_call_int_ptr, cov_sh_mem);

    // call i32 @shmdt(i8* %y)
    /*
    vector<Value*> shm_dt_params;
    shm_dt_params.push_back(shmat_call);
    builder.CreateCall(shm_dt, shm_dt_params, "call_shmdt");
    */
    builder.CreateBr(record_bb);

    //  record id
    builder.SetInsertPoint(record_bb);

    //load_cov_sh_mem = builder.CreateLoad(i32PtrTy, cov_sh_mem);
    PHINode* phi_cov_sh_mem = builder.CreatePHI(i32PtrTy, 2);
    phi_cov_sh_mem->addIncoming(shmat_call_int_ptr, get_shm_bb);
    phi_cov_sh_mem->addIncoming(load_cov_sh_mem, check_shm_bb);

    Value* id_val = ConstantInt::get(builder.getInt32Ty(), id);
    Value* which_int = builder.CreateUDiv(id_val, ConstantInt::get(builder.getInt32Ty(), 32));
    Value* which_bit = builder.CreateURem(id_val, ConstantInt::get(builder.getInt32Ty(), 32));
    Value* bit_mask = builder.CreateShl(ConstantInt::get(builder.getInt32Ty(), 1), which_bit);

    vector<Value*> indexes;
    indexes.push_back(which_int);

    Value* shared_mem_val_ptr = builder.CreateInBoundsGEP(phi_cov_sh_mem, indexes);
    Value* shared_mem_val = builder.CreateLoad(builder.getInt32Ty(), shared_mem_val_ptr);
    Value* new_shared_mem_val = builder.CreateOr(shared_mem_val, bit_mask);
    builder.CreateStore(new_shared_mem_val, shared_mem_val_ptr);
    builder.CreateBr(entry_bb);
  }
};
} // end anonymous namespace

char EnableWebAPIProfilingPass::ID = 0;
map<string, map<string, int> > EnableWebAPIProfilingPass::FunctionIndexes = map<string, map<string, int> >();

INITIALIZE_PASS_BEGIN(EnableWebAPIProfilingPass,
    "enable-web-api-profiling", "Profile web api only. ", false, false)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_END(EnableWebAPIProfilingPass,
    "enable-web-api-profiling", "Profile web api only.", false, false)

void EnableWebAPIProfilingPass::instrumentFunction(Function& F, Module& M, int index) {
  record_cov(M, F, index);
}

void EnableWebAPIProfilingPass::read_indexes() {
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
      int idx = stoi(tokens[i*2+1]);
      string func_name = tokens[i*2+2];
      FunctionIndexes[file_name][func_name] =  idx;
    }
  }

  infile.close();
}

bool EnableWebAPIProfilingPass::runOnModule(Module &M) {
  if (FunctionIndexes.size() == 0) {
    read_indexes();
  }

  std::string module_path = M.getName().str();
  if (FunctionIndexes.find(module_path) == FunctionIndexes.end())
    outs() << "Cannot find indexes for " << module_path << '\n';

  size_t basename_buffer_size = 1;
  size_t classname_buffer_size = 1;
  char* basename_buffer = static_cast<char*>(std::malloc(basename_buffer_size));
  char* classname_buffer = static_cast<char*>(std::malloc(classname_buffer_size));

  llvm::ItaniumPartialDemangler Demangler;
  map<string, int> function_index_map = FunctionIndexes[module_path];
  for (Function &F : M)	{
    // skip special functions
    if (F.isDeclaration() || F.isIntrinsic() || F.empty())
      continue;

    std::string func_name = F.getName().str();
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
      outs() << "Cannot find index for " << func_name << '\n';
      continue;
    }

    instrumentFunction(F, M, function_index_map[func_name]);
  }

  std::free(basename_buffer);
  std::free(classname_buffer);
  return true;
}

namespace llvm {
ModulePass* createEnableWebAPIProfilingPass() {
  return new EnableWebAPIProfilingPass();
}
} // end namespace llvm
