# 11vm

## Build

1. ```mkdir build & cd build```
2. ```cmake -G "Unix Makefiles" -DLLVM_ENABLE_PROJECTS="clang;lld" -DCMAKE_BUILD_TYPE=Release -LLVM_TARGETS_TO_BUILD=X86 ../llvm```
3. ```make -j`nproc` ```

## Port to newer versions
Check following source code files:
  - `clang/include/clang/Basic/CodeGenOptions.h` (added code)
  - `clang/include/clang/Driver/CC1Options.td` (added code)
  - `clang/include/clang/Driver/Options.td` (added code)
  - `clang/lib/CodeGen/BackendUtil.cpp` (added code)
  - `clang/lib/CodeGen/CodeGenModule.cpp` (added code)
  - `clang/lib/Driver/ToolChains/Clang.cpp` (added code)
  - `clang/lib/Frontend/CompilerInvocation.cpp` (added code)
  - `llvm/lib/Transforms/Scalar/CMakeLists.txt` (line 13, 14, 15)
  - `llvm/include/llvm/Transforms/Scalar/DumpIR.h` (new file)
  - `llvm/lib/Transforms/Scalar/DumpIR.cpp` (new file)
  - `llvm/include/llvm/Transforms/Scalar/EnableProfiling.h` (new file)
  - `llvm/lib/Transforms/Scalar/EnableProfiling.cpp` (new file)
  - `llvm/include/llvm/Transforms/Scalar/EnableMarking.h` (new file)
  - `llvm/lib/Transforms/Scalar/EnableMarking.cpp` (new file)

For the source files that we added code, please search `chenxiong` to find the code between `added by chenxiong start` and `added by chenxiong end`.
