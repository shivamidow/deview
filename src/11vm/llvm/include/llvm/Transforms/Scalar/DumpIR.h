#ifndef LLVM_TRANSFORMS_SCALAR_DUMP_IR_H
#define LLVM_TRANSFORMS_SCALAR_DUMP_IR_H

#include "llvm/Pass.h"

namespace llvm {
	ModulePass* createDumpIRPass();
} // end namespace llvm

#endif
