#ifndef LLVM_TRANSFORMS_SCALAR_ENABLE_WEB_API_PROFILING_H
#define LLVM_TRANSFORMS_SCALAR_ENABLE_WEB_API_PROFILING_H

#include "llvm/Pass.h"

namespace llvm {
	ModulePass* createEnableWebAPIProfilingPass();
} // end namespace llvm

#endif
