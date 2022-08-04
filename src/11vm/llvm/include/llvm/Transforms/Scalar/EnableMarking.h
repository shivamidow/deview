#ifndef LLVM_TRANSFORMS_SCALAR_ENABLE_MARKING_H
#define LLVM_TRANSFORMS_SCALAR_ENABLE_MARKING_H

#include "llvm/Pass.h"

namespace llvm {
	ModulePass* createEnableMarkingPass();
} // end namespace llvm

#endif
