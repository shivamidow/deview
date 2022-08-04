#ifndef LLVM_TRANSFORMS_SCALAR_ENABLE_PROFILING_H
#define LLVM_TRANSFORMS_SCALAR_ENABLE_PROFILING_H

#include "llvm/Pass.h"

namespace llvm {
	ModulePass* createEnableProfilingPass();
} // end namespace llvm

#endif
