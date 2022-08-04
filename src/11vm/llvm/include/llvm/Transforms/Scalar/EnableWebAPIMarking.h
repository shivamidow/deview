#ifndef LLVM_TRANSFORMS_SCALAR_ENABLE_WEB_API_MARKING_H
#define LLVM_TRANSFORMS_SCALAR_ENABLE_WEB_API_MARKING_H

#include "llvm/Pass.h"

namespace llvm {
	ModulePass* createEnableWebAPIMarkingPass();
} // end namespace llvm

#endif
