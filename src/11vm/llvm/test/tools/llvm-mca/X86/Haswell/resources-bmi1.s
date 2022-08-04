# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=haswell -instruction-tables < %s | FileCheck %s

andn        %eax, %ebx, %ecx
andn        (%rax), %ebx, %ecx

andn        %rax, %rbx, %rcx
andn        (%rax), %rbx, %rcx

bextr       %eax, %ebx, %ecx
bextr       %eax, (%rbx), %ecx

bextr       %rax, %rbx, %rcx
bextr       %rax, (%rbx), %rcx

blsi        %eax, %ecx
blsi        (%rax), %ecx

blsi        %rax, %rcx
blsi        (%rax), %rcx

blsmsk      %eax, %ecx
blsmsk      (%rax), %ecx

blsmsk      %rax, %rcx
blsmsk      (%rax), %rcx

blsr        %eax, %ecx
blsr        (%rax), %ecx

blsr        %rax, %rcx
blsr        (%rax), %rcx

tzcnt       %ax, %cx
tzcnt       (%rax), %cx

tzcnt       %eax, %ecx
tzcnt       (%rax), %ecx

tzcnt       %rax, %rcx
tzcnt       (%rax), %rcx

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     0.50                        andnl	%eax, %ebx, %ecx
# CHECK-NEXT:  2      6     0.50    *                   andnl	(%rax), %ebx, %ecx
# CHECK-NEXT:  1      1     0.50                        andnq	%rax, %rbx, %rcx
# CHECK-NEXT:  2      6     0.50    *                   andnq	(%rax), %rbx, %rcx
# CHECK-NEXT:  2      2     0.50                        bextrl	%eax, %ebx, %ecx
# CHECK-NEXT:  3      7     0.50    *                   bextrl	%eax, (%rbx), %ecx
# CHECK-NEXT:  2      2     0.50                        bextrq	%rax, %rbx, %rcx
# CHECK-NEXT:  3      7     0.50    *                   bextrq	%rax, (%rbx), %rcx
# CHECK-NEXT:  1      1     0.50                        blsil	%eax, %ecx
# CHECK-NEXT:  2      6     0.50    *                   blsil	(%rax), %ecx
# CHECK-NEXT:  1      1     0.50                        blsiq	%rax, %rcx
# CHECK-NEXT:  2      6     0.50    *                   blsiq	(%rax), %rcx
# CHECK-NEXT:  1      1     0.50                        blsmskl	%eax, %ecx
# CHECK-NEXT:  2      6     0.50    *                   blsmskl	(%rax), %ecx
# CHECK-NEXT:  1      1     0.50                        blsmskq	%rax, %rcx
# CHECK-NEXT:  2      6     0.50    *                   blsmskq	(%rax), %rcx
# CHECK-NEXT:  1      1     0.50                        blsrl	%eax, %ecx
# CHECK-NEXT:  2      6     0.50    *                   blsrl	(%rax), %ecx
# CHECK-NEXT:  1      1     0.50                        blsrq	%rax, %rcx
# CHECK-NEXT:  2      6     0.50    *                   blsrq	(%rax), %rcx
# CHECK-NEXT:  1      3     1.00                        tzcntw	%ax, %cx
# CHECK-NEXT:  2      8     1.00    *                   tzcntw	(%rax), %cx
# CHECK-NEXT:  1      3     1.00                        tzcntl	%eax, %ecx
# CHECK-NEXT:  2      8     1.00    *                   tzcntl	(%rax), %ecx
# CHECK-NEXT:  1      3     1.00                        tzcntq	%rax, %rcx
# CHECK-NEXT:  2      8     1.00    *                   tzcntq	(%rax), %rcx

# CHECK:      Resources:
# CHECK-NEXT: [0]   - HWDivider
# CHECK-NEXT: [1]   - HWFPDivider
# CHECK-NEXT: [2]   - HWPort0
# CHECK-NEXT: [3]   - HWPort1
# CHECK-NEXT: [4]   - HWPort2
# CHECK-NEXT: [5]   - HWPort3
# CHECK-NEXT: [6]   - HWPort4
# CHECK-NEXT: [7]   - HWPort5
# CHECK-NEXT: [8]   - HWPort6
# CHECK-NEXT: [9]   - HWPort7

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]
# CHECK-NEXT:  -      -     2.00   16.00  6.50   6.50    -     10.00  2.00    -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    Instructions:
# CHECK-NEXT:  -      -      -     0.50    -      -      -     0.50    -      -     andnl	%eax, %ebx, %ecx
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50    -     0.50    -      -     andnl	(%rax), %ebx, %ecx
# CHECK-NEXT:  -      -      -     0.50    -      -      -     0.50    -      -     andnq	%rax, %rbx, %rcx
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50    -     0.50    -      -     andnq	(%rax), %rbx, %rcx
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -     0.50   0.50    -     bextrl	%eax, %ebx, %ecx
# CHECK-NEXT:  -      -     0.50   0.50   0.50   0.50    -     0.50   0.50    -     bextrl	%eax, (%rbx), %ecx
# CHECK-NEXT:  -      -     0.50   0.50    -      -      -     0.50   0.50    -     bextrq	%rax, %rbx, %rcx
# CHECK-NEXT:  -      -     0.50   0.50   0.50   0.50    -     0.50   0.50    -     bextrq	%rax, (%rbx), %rcx
# CHECK-NEXT:  -      -      -     0.50    -      -      -     0.50    -      -     blsil	%eax, %ecx
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50    -     0.50    -      -     blsil	(%rax), %ecx
# CHECK-NEXT:  -      -      -     0.50    -      -      -     0.50    -      -     blsiq	%rax, %rcx
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50    -     0.50    -      -     blsiq	(%rax), %rcx
# CHECK-NEXT:  -      -      -     0.50    -      -      -     0.50    -      -     blsmskl	%eax, %ecx
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50    -     0.50    -      -     blsmskl	(%rax), %ecx
# CHECK-NEXT:  -      -      -     0.50    -      -      -     0.50    -      -     blsmskq	%rax, %rcx
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50    -     0.50    -      -     blsmskq	(%rax), %rcx
# CHECK-NEXT:  -      -      -     0.50    -      -      -     0.50    -      -     blsrl	%eax, %ecx
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50    -     0.50    -      -     blsrl	(%rax), %ecx
# CHECK-NEXT:  -      -      -     0.50    -      -      -     0.50    -      -     blsrq	%rax, %rcx
# CHECK-NEXT:  -      -      -     0.50   0.50   0.50    -     0.50    -      -     blsrq	(%rax), %rcx
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -      -      -     tzcntw	%ax, %cx
# CHECK-NEXT:  -      -      -     1.00   0.50   0.50    -      -      -      -     tzcntw	(%rax), %cx
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -      -      -     tzcntl	%eax, %ecx
# CHECK-NEXT:  -      -      -     1.00   0.50   0.50    -      -      -      -     tzcntl	(%rax), %ecx
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -      -      -     tzcntq	%rax, %rcx
# CHECK-NEXT:  -      -      -     1.00   0.50   0.50    -      -      -      -     tzcntq	(%rax), %rcx