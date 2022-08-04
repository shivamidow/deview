#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/Scalar/EnableMarking.h"
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

#define DEBUG_TYPE "enable-marking"

namespace llvm {
void initializeEnableMarkingPassPass(PassRegistry&);
} // end namespace llvm

namespace {
class EnableMarkingPass : public ModulePass {
  APInt Duplicate;
  APInt Amend;

public:
  static char ID;
	static map<string, map<string, int> > FunctionIndexes;
	void read_indexes();

  EnableMarkingPass()
    : ModulePass(ID) {
    initializeEnableMarkingPassPass(*PassRegistry::getPassRegistry());
  }

  bool runOnModule(Module &M) override;

	void instrumentFunction(Function& F, Module& M, int idx);
	
	/*	
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<LoopInfoWrapperPass>();
  }
	*/

	void replace(std::string& str, const std::string& from, const std::string& to) {
		if(from.empty())
			return;
		size_t start_pos = 0;
		while((start_pos = str.find(from, start_pos)) != std::string::npos) {
			str.replace(start_pos, from.length(), to);
			start_pos += to.length(); // In case 'to' contains 'from', like replacing 'x' with 'yx'
		}
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
	
	void mark_func(Module& M, Function& F, int id)
	{
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
			cx_global_function_id->setAlignment(4);
		}

		// cx_global_function_id = id
		builder.SetInsertPoint(mark_bb);
		Type* i32Ty = builder.getInt32Ty();
		builder.CreateStore(ConstantInt::get(i32Ty, id), cx_global_function_id);
		builder.CreateBr(entry_bb);

	}	
};
} // end anonymous namespace

char EnableMarkingPass::ID = 42;
map<string, map<string, int> > EnableMarkingPass::FunctionIndexes = map<string, map<string, int> >();

INITIALIZE_PASS_BEGIN(EnableMarkingPass, "enable-marking",
		"Do marking for each function. ",
		false, false)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_END(EnableMarkingPass, "enable-marking",
                    "Do marking for each function.",
                    false, false)

void EnableMarkingPass::instrumentFunction(Function& F, Module& M, int idx)
{
	mark_func(M, F, idx);
}

void EnableMarkingPass::read_indexes()
{
    const char* index_file = getenv("SLIMIUM_UNIQUE_INDEX_PATH");
    if (!index_file) {
      outs() << "SLIMIUM_UNIQUE_INDEX_PATH is not set. Will use /tmp/unique_indexes.txt instead." << '\n';
      index_file = "/tmp/unique_indexes.txt";
    }

	ifstream infile = ifstream(index_file);
	if (!infile.is_open())
		return;
	
	string line;
	while (getline(infile, line))
	{
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

bool EnableMarkingPass::runOnModule(Module &M) {
	
	if (FunctionIndexes.size() == 0)
	{
		read_indexes();
	}

	std::string module_path = M.getName().str();
	if (FunctionIndexes.find(module_path) == FunctionIndexes.end())
		errs() << "Cannot find indexes for " << module_path << '\n';

	map<string, int> function_index_map = FunctionIndexes[module_path];
	
	for (Function &F : M)
	{
		// skip special functions
		if (F.isDeclaration() || F.isIntrinsic() || F.empty())
			continue;

		string func_name = F.getName().str();
		if (function_index_map.find(func_name) == function_index_map.end()) {
			errs() << "Cannot find index for " << func_name << '\n';
			continue;
		}

		instrumentFunction(F, M, function_index_map[func_name]);
	}
	
	/*	
	std::string module_path = M.getName().str();
	errs() << "++++ " << module_path << '\n';

	replace(module_path, "/", "@");
	replace(module_path, ".", "$");
	module_path = "/home/chenxiong/bitcodes/chromium/" + module_path;

	std::error_code EC;
	llvm::raw_fd_ostream OS(module_path, EC, sys::fs::F_None);
	WriteBitcodeToFile(M, OS);
	OS.flush();
	*/

  return true;
}

namespace llvm {
ModulePass* createEnableMarkingPass() {
  return new EnableMarkingPass();
}
} // end namespace llvm
