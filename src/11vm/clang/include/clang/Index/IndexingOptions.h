//===--- IndexingOptions.h - Options for indexing ---------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_INDEX_INDEXINGOPTIONS_H
#define LLVM_CLANG_INDEX_INDEXINGOPTIONS_H

#include "clang/Frontend/FrontendOptions.h"
#include <memory>
#include <string>

namespace clang {
namespace index {

struct IndexingOptions {
  enum class SystemSymbolFilterKind {
    None,
    DeclarationsOnly,
    All,
  };

  SystemSymbolFilterKind SystemSymbolFilter =
      SystemSymbolFilterKind::DeclarationsOnly;
  bool IndexFunctionLocals = false;
  bool IndexImplicitInstantiation = false;
  // Whether to index macro definitions in the Preprocesor when preprocessor
  // callback is not available (e.g. after parsing has finished). Note that
  // macro references are not available in Proprocessor.
  bool IndexMacrosInPreprocessor = false;
  // Has no effect if IndexFunctionLocals are false.
  bool IndexParametersInDeclarations = false;
  bool IndexTemplateParameters = false;
};

} // namespace index
} // namespace clang

#endif // LLVM_CLANG_INDEX_INDEXINGOPTIONS_H
