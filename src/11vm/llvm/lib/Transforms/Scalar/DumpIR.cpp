#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Transforms/Scalar/DumpIR.h"
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

#define DEBUG_TYPE "dump-ir"

namespace llvm {
void initializeDumpIRPassPass(PassRegistry&);
} // end namespace llvm

namespace {
class DumpIRPass : public ModulePass {
  APInt Duplicate;
  APInt Amend;

public:
  static char ID;
	static map<string, map<string, int> > FunctionIndexes;
	void read_indexes();

  DumpIRPass()
    : ModulePass(ID) {
    initializeDumpIRPassPass(*PassRegistry::getPassRegistry());
  }

  bool runOnModule(Module &M) override;

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
};
} // end anonymous namespace

char DumpIRPass::ID = 53;
map<string, map<string, int> > DumpIRPass::FunctionIndexes = map<string, map<string, int> >();

INITIALIZE_PASS_BEGIN(DumpIRPass, "dump-ir",
		"Dump IR.",
		false, false)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_END(DumpIRPass, "dump-ir",
                    "Dump IR.",
                    false, false)

bool DumpIRPass::runOnModule(Module &M) {
	
	std::string module_path = M.getName().str();
	outs() << "++++ " << module_path << '\n';

    char* dump_path = getenv("llVM_IR_DUMP_PATH");
    if (!dump_path)
        printf("DumpIRPass::%s(%d) llVM_IR_DUMP_PATH is not set. /tmp is used instead.\n", __FUNCTION__, __LINE__);
    string path_prefix(dump_path ? dump_path : "/tmp");

	replace(module_path, "/", "@");
	replace(module_path, ".", "$");
    module_path.insert(0, path_prefix + "/");

	std::error_code EC;
	llvm::raw_fd_ostream OS(module_path, EC, sys::fs::F_None);
	WriteBitcodeToFile(M, OS);
	OS.flush();

  return true;
}

namespace llvm {
ModulePass* createDumpIRPass() {
  return new DumpIRPass();
}
} // end namespace llvm
