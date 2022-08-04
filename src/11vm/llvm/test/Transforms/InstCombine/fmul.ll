; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

; (-0.0 - X) * C => X * -C
define float @neg_constant(float %x) {
; CHECK-LABEL: @neg_constant(
; CHECK-NEXT:    [[MUL:%.*]] = fmul ninf float [[X:%.*]], -2.000000e+01
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub = fsub float -0.0, %x
  %mul = fmul ninf float %sub, 2.0e+1
  ret float %mul
}

define float @unary_neg_constant(float %x) {
; CHECK-LABEL: @unary_neg_constant(
; CHECK-NEXT:    [[MUL:%.*]] = fmul ninf float [[X:%.*]], -2.000000e+01
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub = fneg float %x
  %mul = fmul ninf float %sub, 2.0e+1
  ret float %mul
}

define <2 x float> @neg_constant_vec(<2 x float> %x) {
; CHECK-LABEL: @neg_constant_vec(
; CHECK-NEXT:    [[MUL:%.*]] = fmul ninf <2 x float> [[X:%.*]], <float -2.000000e+00, float -3.000000e+00>
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub = fsub <2 x float> <float -0.0, float -0.0>, %x
  %mul = fmul ninf <2 x float> %sub, <float 2.0, float 3.0>
  ret <2 x float> %mul
}

define <2 x float> @unary_neg_constant_vec(<2 x float> %x) {
; CHECK-LABEL: @unary_neg_constant_vec(
; CHECK-NEXT:    [[MUL:%.*]] = fmul ninf <2 x float> [[X:%.*]], <float -2.000000e+00, float -3.000000e+00>
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub = fneg <2 x float> %x
  %mul = fmul ninf <2 x float> %sub, <float 2.0, float 3.0>
  ret <2 x float> %mul
}

define <2 x float> @neg_constant_vec_undef(<2 x float> %x) {
; CHECK-LABEL: @neg_constant_vec_undef(
; CHECK-NEXT:    [[MUL:%.*]] = fmul ninf <2 x float> [[X:%.*]], <float -2.000000e+00, float -3.000000e+00>
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub = fsub <2 x float> <float undef, float -0.0>, %x
  %mul = fmul ninf <2 x float> %sub, <float 2.0, float 3.0>
  ret <2 x float> %mul
}

; (0.0 - X) * C => X * -C
define float @neg_nsz_constant(float %x) {
; CHECK-LABEL: @neg_nsz_constant(
; CHECK-NEXT:    [[MUL:%.*]] = fmul nnan float [[X:%.*]], -2.000000e+01
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub = fsub nsz float 0.0, %x
  %mul = fmul nnan float %sub, 2.0e+1
  ret float %mul
}

define float @unary_neg_nsz_constant(float %x) {
; CHECK-LABEL: @unary_neg_nsz_constant(
; CHECK-NEXT:    [[MUL:%.*]] = fmul nnan float [[X:%.*]], -2.000000e+01
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub = fneg nsz float %x
  %mul = fmul nnan float %sub, 2.0e+1
  ret float %mul
}

; (-0.0 - X) * (-0.0 - Y) => X * Y
define float @neg_neg(float %x, float %y) {
; CHECK-LABEL: @neg_neg(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fsub float -0.0, %x
  %sub2 = fsub float -0.0, %y
  %mul = fmul arcp float %sub1, %sub2
  ret float %mul
}

define float @unary_neg_unary_neg(float %x, float %y) {
; CHECK-LABEL: @unary_neg_unary_neg(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fneg float %x
  %sub2 = fneg float %y
  %mul = fmul arcp float %sub1, %sub2
  ret float %mul
}

define float @unary_neg_neg(float %x, float %y) {
; CHECK-LABEL: @unary_neg_neg(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fneg float %x
  %sub2 = fsub float -0.0, %y
  %mul = fmul arcp float %sub1, %sub2
  ret float %mul
}

define float @neg_unary_neg(float %x, float %y) {
; CHECK-LABEL: @neg_unary_neg(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fsub float -0.0, %x
  %sub2 = fneg float %y
  %mul = fmul arcp float %sub1, %sub2
  ret float %mul
}

define <2 x float> @neg_neg_vec(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @neg_neg_vec(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub1 = fsub <2 x float> <float -0.0, float -0.0>, %x
  %sub2 = fsub <2 x float> <float -0.0, float -0.0>, %y
  %mul = fmul arcp <2 x float> %sub1, %sub2
  ret <2 x float> %mul
}

define <2 x float> @unary_neg_unary_neg_vec(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @unary_neg_unary_neg_vec(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub1 = fneg <2 x float> %x
  %sub2 = fneg <2 x float> %y
  %mul = fmul arcp <2 x float> %sub1, %sub2
  ret <2 x float> %mul
}

define <2 x float> @unary_neg_neg_vec(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @unary_neg_neg_vec(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub1 = fneg <2 x float> %x
  %sub2 = fsub <2 x float> <float -0.0, float -0.0>, %y
  %mul = fmul arcp <2 x float> %sub1, %sub2
  ret <2 x float> %mul
}

define <2 x float> @neg_unary_neg_vec(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @neg_unary_neg_vec(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub1 = fsub <2 x float> <float -0.0, float -0.0>, %x
  %sub2 = fneg <2 x float> %y
  %mul = fmul arcp <2 x float> %sub1, %sub2
  ret <2 x float> %mul
}

define <2 x float> @neg_neg_vec_undef(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @neg_neg_vec_undef(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub1 = fsub <2 x float> <float -0.0, float undef>, %x
  %sub2 = fsub <2 x float> <float undef, float -0.0>, %y
  %mul = fmul arcp <2 x float> %sub1, %sub2
  ret <2 x float> %mul
}

define <2 x float> @unary_neg_neg_vec_undef(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @unary_neg_neg_vec_undef(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %neg = fneg <2 x float> %x
  %sub = fsub <2 x float> <float undef, float -0.0>, %y
  %mul = fmul arcp <2 x float> %neg, %sub
  ret <2 x float> %mul
}

define <2 x float> @neg_unary_neg_vec_undef(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @neg_unary_neg_vec_undef(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub = fsub <2 x float> <float -0.0, float undef>, %x
  %neg = fneg <2 x float> %y
  %mul = fmul arcp <2 x float> %sub, %neg
  ret <2 x float> %mul
}

; (0.0 - X) * (0.0 - Y) => X * Y
define float @neg_neg_nsz(float %x, float %y) {
; CHECK-LABEL: @neg_neg_nsz(
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fsub nsz float 0.0, %x
  %sub2 = fsub nsz float 0.0, %y
  %mul = fmul afn float %sub1, %sub2
  ret float %mul
}

declare void @use_f32(float)

define float @neg_neg_multi_use(float %x, float %y) {
; CHECK-LABEL: @neg_neg_multi_use(
; CHECK-NEXT:    [[NX:%.*]] = fsub float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[NY:%.*]] = fsub float -0.000000e+00, [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[X]], [[Y]]
; CHECK-NEXT:    call void @use_f32(float [[NX]])
; CHECK-NEXT:    call void @use_f32(float [[NY]])
; CHECK-NEXT:    ret float [[MUL]]
;
  %nx = fsub float -0.0, %x
  %ny = fsub float -0.0, %y
  %mul = fmul afn float %nx, %ny
  call void @use_f32(float %nx)
  call void @use_f32(float %ny)
  ret float %mul
}

define float @unary_neg_unary_neg_multi_use(float %x, float %y) {
; CHECK-LABEL: @unary_neg_unary_neg_multi_use(
; CHECK-NEXT:    [[NX:%.*]] = fneg float [[X:%.*]]
; CHECK-NEXT:    [[NY:%.*]] = fneg float [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[X]], [[Y]]
; CHECK-NEXT:    call void @use_f32(float [[NX]])
; CHECK-NEXT:    call void @use_f32(float [[NY]])
; CHECK-NEXT:    ret float [[MUL]]
;
  %nx = fneg float %x
  %ny = fneg float %y
  %mul = fmul afn float %nx, %ny
  call void @use_f32(float %nx)
  call void @use_f32(float %ny)
  ret float %mul
}

define float @unary_neg_neg_multi_use(float %x, float %y) {
; CHECK-LABEL: @unary_neg_neg_multi_use(
; CHECK-NEXT:    [[NX:%.*]] = fneg float [[X:%.*]]
; CHECK-NEXT:    [[NY:%.*]] = fsub float -0.000000e+00, [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[X]], [[Y]]
; CHECK-NEXT:    call void @use_f32(float [[NX]])
; CHECK-NEXT:    call void @use_f32(float [[NY]])
; CHECK-NEXT:    ret float [[MUL]]
;
  %nx = fneg float %x
  %ny = fsub float -0.0, %y
  %mul = fmul afn float %nx, %ny
  call void @use_f32(float %nx)
  call void @use_f32(float %ny)
  ret float %mul
}

define float @neg_unary_neg_multi_use(float %x, float %y) {
; CHECK-LABEL: @neg_unary_neg_multi_use(
; CHECK-NEXT:    [[NX:%.*]] = fsub float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[NY:%.*]] = fneg float [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[X]], [[Y]]
; CHECK-NEXT:    call void @use_f32(float [[NX]])
; CHECK-NEXT:    call void @use_f32(float [[NY]])
; CHECK-NEXT:    ret float [[MUL]]
;
  %nx = fsub float -0.0, %x
  %ny = fneg float %y
  %mul = fmul afn float %nx, %ny
  call void @use_f32(float %nx)
  call void @use_f32(float %ny)
  ret float %mul
}

; (-0.0 - X) * Y
define float @neg_mul(float %x, float %y) {
; CHECK-LABEL: @neg_mul(
; CHECK-NEXT:    [[SUB:%.*]] = fsub float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[SUB]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub = fsub float -0.0, %x
  %mul = fmul float %sub, %y
  ret float %mul
}

define float @unary_neg_mul(float %x, float %y) {
; CHECK-LABEL: @unary_neg_mul(
; CHECK-NEXT:    [[NEG:%.*]] = fneg float [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %neg = fneg float %x
  %mul = fmul float %neg, %y
  ret float %mul
}

define <2 x float> @neg_mul_vec(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @neg_mul_vec(
; CHECK-NEXT:    [[SUB:%.*]] = fsub <2 x float> <float -0.000000e+00, float -0.000000e+00>, [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul <2 x float> [[SUB]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub = fsub <2 x float> <float -0.0, float -0.0>, %x
  %mul = fmul <2 x float> %sub, %y
  ret <2 x float> %mul
}

define <2 x float> @unary_neg_mul_vec(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @unary_neg_mul_vec(
; CHECK-NEXT:    [[SUB:%.*]] = fneg <2 x float> [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul <2 x float> [[SUB]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub = fneg <2 x float> %x
  %mul = fmul <2 x float> %sub, %y
  ret <2 x float> %mul
}

define <2 x float> @neg_mul_vec_undef(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @neg_mul_vec_undef(
; CHECK-NEXT:    [[SUB:%.*]] = fsub <2 x float> <float undef, float -0.000000e+00>, [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul <2 x float> [[SUB]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sub = fsub <2 x float> <float undef, float -0.0>, %x
  %mul = fmul <2 x float> %sub, %y
  ret <2 x float> %mul
}

; (0.0 - X) * Y
define float @neg_sink_nsz(float %x, float %y) {
; CHECK-LABEL: @neg_sink_nsz(
; CHECK-NEXT:    [[SUB1:%.*]] = fsub nsz float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[SUB1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fsub nsz float 0.0, %x
  %mul = fmul float %sub1, %y
  ret float %mul
}

define float @neg_sink_multi_use(float %x, float %y) {
; CHECK-LABEL: @neg_sink_multi_use(
; CHECK-NEXT:    [[SUB1:%.*]] = fsub float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[SUB1]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul float [[MUL]], [[SUB1]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %sub1 = fsub float -0.0, %x
  %mul = fmul float %sub1, %y
  %mul2 = fmul float %mul, %sub1
  ret float %mul2
}

define float @unary_neg_mul_multi_use(float %x, float %y) {
; CHECK-LABEL: @unary_neg_mul_multi_use(
; CHECK-NEXT:    [[SUB1:%.*]] = fneg float [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[SUB1]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul float [[MUL]], [[SUB1]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %sub1 = fneg float %x
  %mul = fmul float %sub1, %y
  %mul2 = fmul float %mul, %sub1
  ret float %mul2
}

; Don't crash when attempting to cast a constant FMul to an instruction.
define void @test8(i32* %inout) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[LOCAL_VAR_7_0:%.*]] = phi <4 x float> [ <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, [[ENTRY:%.*]] ], [ [[TMP0:%.*]], [[FOR_BODY:%.*]] ]
; CHECK-NEXT:    br i1 undef, label [[FOR_BODY]], label [[FOR_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[TMP0]] = insertelement <4 x float> [[LOCAL_VAR_7_0]], float 0.000000e+00, i32 2
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %0 = load i32, i32* %inout, align 4
  %conv = uitofp i32 %0 to float
  %vecinit = insertelement <4 x float> <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float undef>, float %conv, i32 3
  %sub = fsub <4 x float> <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, %vecinit
  %1 = shufflevector <4 x float> %sub, <4 x float> undef, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  %mul = fmul <4 x float> zeroinitializer, %1
  br label %for.cond

for.cond:                                         ; preds = %for.body, %entry
  %local_var_7.0 = phi <4 x float> [ %mul, %entry ], [ %2, %for.body ]
  br i1 undef, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = insertelement <4 x float> %local_var_7.0, float 0.000000e+00, i32 2
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; X * -1.0 => -0.0 - X
define float @test9(float %x) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[MUL:%.*]] = fsub float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %mul = fmul float %x, -1.0
  ret float %mul
}

; PR18532
define <4 x float> @test10(<4 x float> %x) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[MUL:%.*]] = fsub arcp afn <4 x float> <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, [[X:%.*]]
; CHECK-NEXT:    ret <4 x float> [[MUL]]
;
  %mul = fmul arcp afn <4 x float> %x, <float -1.0, float -1.0, float -1.0, float -1.0>
  ret <4 x float> %mul
}

define float @test11(float %x, float %y) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[B:%.*]] = fadd fast float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fadd fast float [[B]], 3.000000e+00
; CHECK-NEXT:    ret float [[C]]
;
  %a = fadd fast float %x, 1.0
  %b = fadd fast float %y, 2.0
  %c = fadd fast float %a, %b
  ret float %c
}

declare double @llvm.sqrt.f64(double)

; With unsafe/fast math, sqrt(X) * sqrt(X) is just X,
; but make sure another use of the sqrt is intact.
; Note that the remaining fmul is altered but is not 'fast'
; itself because it was not marked 'fast' originally.
; Thus, we have an overall fast result, but no more indication of
; 'fast'ness in the code.
define double @sqrt_squared2(double %f) {
; CHECK-LABEL: @sqrt_squared2(
; CHECK-NEXT:    [[SQRT:%.*]] = call double @llvm.sqrt.f64(double [[F:%.*]])
; CHECK-NEXT:    [[MUL2:%.*]] = fmul double [[SQRT]], [[F]]
; CHECK-NEXT:    ret double [[MUL2]]
;
  %sqrt = call double @llvm.sqrt.f64(double %f)
  %mul1 = fmul fast double %sqrt, %sqrt
  %mul2 = fmul double %mul1, %sqrt
  ret double %mul2
}

declare float @llvm.fabs.f32(float) nounwind readnone

define float @fabs_squared(float %x) {
; CHECK-LABEL: @fabs_squared(
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[X:%.*]], [[X]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %mul = fmul float %x.fabs, %x.fabs
  ret float %mul
}

define float @fabs_squared_fast(float %x) {
; CHECK-LABEL: @fabs_squared_fast(
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float [[X:%.*]], [[X]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %mul = fmul fast float %x.fabs, %x.fabs
  ret float %mul
}

define float @fabs_x_fabs(float %x, float %y) {
; CHECK-LABEL: @fabs_x_fabs(
; CHECK-NEXT:    [[X_FABS:%.*]] = call float @llvm.fabs.f32(float [[X:%.*]])
; CHECK-NEXT:    [[Y_FABS:%.*]] = call float @llvm.fabs.f32(float [[Y:%.*]])
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[X_FABS]], [[Y_FABS]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %y.fabs = call float @llvm.fabs.f32(float %y)
  %mul = fmul float %x.fabs, %y.fabs
  ret float %mul
}

; (X*Y) * X => (X*X) * Y
; The transform only requires 'reassoc', but test other FMF in
; the commuted variants to make sure FMF propagates as expected.

define float @reassoc_common_operand1(float %x, float %y) {
; CHECK-LABEL: @reassoc_common_operand1(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc float [[X:%.*]], [[X]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul reassoc float [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %mul1 = fmul float %x, %y
  %mul2 = fmul reassoc float %mul1, %x
  ret float %mul2
}

; (Y*X) * X => (X*X) * Y

define float @reassoc_common_operand2(float %x, float %y) {
; CHECK-LABEL: @reassoc_common_operand2(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[X:%.*]], [[X]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul fast float [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %mul1 = fmul float %y, %x
  %mul2 = fmul fast float %mul1, %x
  ret float %mul2
}

; X * (X*Y) => (X*X) * Y

define float @reassoc_common_operand3(float %x1, float %y) {
; CHECK-LABEL: @reassoc_common_operand3(
; CHECK-NEXT:    [[X:%.*]] = fdiv float [[X1:%.*]], 3.000000e+00
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc nnan float [[X]], [[X]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul reassoc nnan float [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %x = fdiv float %x1, 3.0 ; thwart complexity-based canonicalization
  %mul1 = fmul float %x, %y
  %mul2 = fmul reassoc nnan float %x, %mul1
  ret float %mul2
}

; X * (Y*X) => (X*X) * Y

define float @reassoc_common_operand4(float %x1, float %y) {
; CHECK-LABEL: @reassoc_common_operand4(
; CHECK-NEXT:    [[X:%.*]] = fdiv float [[X1:%.*]], 3.000000e+00
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc ninf float [[X]], [[X]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul reassoc ninf float [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %x = fdiv float %x1, 3.0 ; thwart complexity-based canonicalization
  %mul1 = fmul float %y, %x
  %mul2 = fmul reassoc ninf float %x, %mul1
  ret float %mul2
}

; No change if the first fmul has another use.

define float @reassoc_common_operand_multi_use(float %x, float %y) {
; CHECK-LABEL: @reassoc_common_operand_multi_use(
; CHECK-NEXT:    [[MUL1:%.*]] = fmul float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul fast float [[MUL1]], [[X]]
; CHECK-NEXT:    call void @use_f32(float [[MUL1]])
; CHECK-NEXT:    ret float [[MUL2]]
;
  %mul1 = fmul float %x, %y
  %mul2 = fmul fast float %mul1, %x
  call void @use_f32(float %mul1)
  ret float %mul2
}

declare float @llvm.log2.f32(float)

; log2(Y * 0.5) * X = log2(Y) * X - X

define float @log2half(float %x, float %y) {
; CHECK-LABEL: @log2half(
; CHECK-NEXT:    [[LOG2:%.*]] = call fast float @llvm.log2.f32(float [[Y:%.*]])
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[LOG2]], [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fsub fast float [[TMP1]], [[X]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %halfy = fmul float %y, 0.5
  %log2 = call float @llvm.log2.f32(float %halfy)
  %mul = fmul fast float %log2, %x
  ret float %mul
}

define float @log2half_commute(float %x1, float %y) {
; CHECK-LABEL: @log2half_commute(
; CHECK-NEXT:    [[LOG2:%.*]] = call fast float @llvm.log2.f32(float [[Y:%.*]])
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[LOG2]], [[X1:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = fsub fast float [[TMP1]], [[X1]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float [[TMP2]], 0x3FC24924A0000000
; CHECK-NEXT:    ret float [[MUL]]
;
  %x = fdiv float %x1, 7.0 ; thwart complexity-based canonicalization
  %halfy = fmul float %y, 0.5
  %log2 = call float @llvm.log2.f32(float %halfy)
  %mul = fmul fast float %x, %log2
  ret float %mul
}

; C1/X * C2 => (C1*C2) / X

define float @fdiv_constant_numerator_fmul(float %x) {
; CHECK-LABEL: @fdiv_constant_numerator_fmul(
; CHECK-NEXT:    [[T3:%.*]] = fdiv reassoc float 1.200000e+07, [[X:%.*]]
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fdiv float 2.0e+3, %x
  %t3 = fmul reassoc float %t1, 6.0e+3
  ret float %t3
}

; C1/X * C2 => (C1*C2) / X is disabled if C1/X has multiple uses

@fmul2_external = external global float

define float @fdiv_constant_numerator_fmul_extra_use(float %x) {
; CHECK-LABEL: @fdiv_constant_numerator_fmul_extra_use(
; CHECK-NEXT:    [[DIV:%.*]] = fdiv fast float 1.000000e+00, [[X:%.*]]
; CHECK-NEXT:    store float [[DIV]], float* @fmul2_external, align 4
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float [[DIV]], 2.000000e+00
; CHECK-NEXT:    ret float [[MUL]]
;
  %div = fdiv fast float 1.0, %x
  store float %div, float* @fmul2_external
  %mul = fmul fast float %div, 2.0
  ret float %mul
}

; X/C1 * C2 => X * (C2/C1) (if C2/C1 is normal FP)

define float @fdiv_constant_denominator_fmul(float %x) {
; CHECK-LABEL: @fdiv_constant_denominator_fmul(
; CHECK-NEXT:    [[T3:%.*]] = fmul reassoc float [[X:%.*]], 3.000000e+00
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fdiv float %x, 2.0e+3
  %t3 = fmul reassoc float %t1, 6.0e+3
  ret float %t3
}

define <4 x float> @fdiv_constant_denominator_fmul_vec(<4 x float> %x) {
; CHECK-LABEL: @fdiv_constant_denominator_fmul_vec(
; CHECK-NEXT:    [[T3:%.*]] = fmul reassoc <4 x float> [[X:%.*]], <float 3.000000e+00, float 2.000000e+00, float 1.000000e+00, float 1.000000e+00>
; CHECK-NEXT:    ret <4 x float> [[T3]]
;
  %t1 = fdiv <4 x float> %x, <float 2.0e+3, float 3.0e+3, float 2.0e+3, float 1.0e+3>
  %t3 = fmul reassoc <4 x float> %t1, <float 6.0e+3, float 6.0e+3, float 2.0e+3, float 1.0e+3>
  ret <4 x float> %t3
}

; Make sure fmul with constant expression doesn't assert.

define <4 x float> @fdiv_constant_denominator_fmul_vec_constexpr(<4 x float> %x) {
; CHECK-LABEL: @fdiv_constant_denominator_fmul_vec_constexpr(
; CHECK-NEXT:    [[T3:%.*]] = fmul reassoc <4 x float> [[X:%.*]], <float 3.000000e+00, float 2.000000e+00, float 1.000000e+00, float 1.000000e+00>
; CHECK-NEXT:    ret <4 x float> [[T3]]
;
  %constExprMul = bitcast i128 trunc (i160 bitcast (<5 x float> <float 6.0e+3, float 6.0e+3, float 2.0e+3, float 1.0e+3, float undef> to i160) to i128) to <4 x float>
  %t1 = fdiv <4 x float> %x, <float 2.0e+3, float 3.0e+3, float 2.0e+3, float 1.0e+3>
  %t3 = fmul reassoc <4 x float> %t1, %constExprMul
  ret <4 x float> %t3
}

; This shows that at least part of instcombine does not check constant
; values to see if it is creating denorms (0x3800000000000000 is a denorm
; for 32-bit float), so protecting against denorms in other parts is
; probably not doing the intended job.

define float @fmul_constant_reassociation(float %x) {
; CHECK-LABEL: @fmul_constant_reassociation(
; CHECK-NEXT:    [[R:%.*]] = fmul reassoc nsz float [[X:%.*]], 0x3800000000000000
; CHECK-NEXT:    ret float [[R]]
;
  %mul_flt_min = fmul reassoc nsz float %x, 0x3810000000000000
  %r = fmul reassoc nsz float  %mul_flt_min, 0.5
  ret float %r
}

; Canonicalization "X/C1 * C2 => X * (C2/C1)" still applies if C2/C1 is denormal
; (otherwise, we should not have allowed the reassociation in the previous test).
; 0x3810000000000000 == FLT_MIN

define float @fdiv_constant_denominator_fmul_denorm(float %x) {
; CHECK-LABEL: @fdiv_constant_denominator_fmul_denorm(
; CHECK-NEXT:    [[T3:%.*]] = fmul fast float [[X:%.*]], 0x3760620000000000
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fdiv float %x, 2.0e+3
  %t3 = fmul fast float %t1, 0x3810000000000000
  ret float %t3
}

; X / C1 * C2 => X / (C2/C1) if C1/C2 is abnormal, but C2/C1 is a normal value.
; TODO: We don't convert the fast fdiv to fmul because that would be multiplication
; by a denormal, but we could do better when we know that denormals are not a problem.

define float @fdiv_constant_denominator_fmul_denorm_try_harder(float %x) {
; CHECK-LABEL: @fdiv_constant_denominator_fmul_denorm_try_harder(
; CHECK-NEXT:    [[T3:%.*]] = fdiv reassoc float [[X:%.*]], 0x47E8000000000000
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fdiv float %x, 3.0
  %t3 = fmul reassoc float %t1, 0x3810000000000000
  ret float %t3
}

; Negative test: we should not have 2 divisions instead of the 1 we started with.

define float @fdiv_constant_denominator_fmul_denorm_try_harder_extra_use(float %x) {
; CHECK-LABEL: @fdiv_constant_denominator_fmul_denorm_try_harder_extra_use(
; CHECK-NEXT:    [[T1:%.*]] = fdiv float [[X:%.*]], 3.000000e+00
; CHECK-NEXT:    [[T3:%.*]] = fmul fast float [[T1]], 0x3810000000000000
; CHECK-NEXT:    [[R:%.*]] = fadd float [[T1]], [[T3]]
; CHECK-NEXT:    ret float [[R]]
;
  %t1 = fdiv float %x, 3.0e+0
  %t3 = fmul fast float %t1, 0x3810000000000000
  %r = fadd float %t1, %t3
  ret float %r
}

; (X + C1) * C2 --> (X * C2) + C1*C2

define float @fmul_fadd_distribute(float %x) {
; CHECK-LABEL: @fmul_fadd_distribute(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc float [[X:%.*]], 3.000000e+00
; CHECK-NEXT:    [[T3:%.*]] = fadd reassoc float [[TMP1]], 6.000000e+00
; CHECK-NEXT:    ret float [[T3]]
;
  %t2 = fadd float %x, 2.0
  %t3 = fmul reassoc float %t2, 3.0
  ret float %t3
}

; (X - C1) * C2 --> (X * C2) - C1*C2

define float @fmul_fsub_distribute1(float %x) {
; CHECK-LABEL: @fmul_fsub_distribute1(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc float [[X:%.*]], 3.000000e+00
; CHECK-NEXT:    [[T3:%.*]] = fadd reassoc float [[TMP1]], -6.000000e+00
; CHECK-NEXT:    ret float [[T3]]
;
  %t2 = fsub float %x, 2.0
  %t3 = fmul reassoc float %t2, 3.0
  ret float %t3
}

; (C1 - X) * C2 --> C1*C2 - (X * C2)

define float @fmul_fsub_distribute2(float %x) {
; CHECK-LABEL: @fmul_fsub_distribute2(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc float [[X:%.*]], 3.000000e+00
; CHECK-NEXT:    [[T3:%.*]] = fsub reassoc float 6.000000e+00, [[TMP1]]
; CHECK-NEXT:    ret float [[T3]]
;
  %t2 = fsub float 2.0, %x
  %t3 = fmul reassoc float %t2, 3.0
  ret float %t3
}

; FIXME: This should only need 'reassoc'.
; ((X*C1) + C2) * C3 => (X * (C1*C3)) + (C2*C3)

define float @fmul_fadd_fmul_distribute(float %x) {
; CHECK-LABEL: @fmul_fadd_fmul_distribute(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[X:%.*]], 3.000000e+01
; CHECK-NEXT:    [[T3:%.*]] = fadd fast float [[TMP1]], 1.000000e+01
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fmul float %x, 6.0
  %t2 = fadd float %t1, 2.0
  %t3 = fmul fast float %t2, 5.0
  ret float %t3
}

define float @fmul_fadd_distribute_extra_use(float %x) {
; CHECK-LABEL: @fmul_fadd_distribute_extra_use(
; CHECK-NEXT:    [[T1:%.*]] = fmul float [[X:%.*]], 6.000000e+00
; CHECK-NEXT:    [[T2:%.*]] = fadd float [[T1]], 2.000000e+00
; CHECK-NEXT:    [[T3:%.*]] = fmul fast float [[T2]], 5.000000e+00
; CHECK-NEXT:    call void @use_f32(float [[T2]])
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fmul float %x, 6.0
  %t2 = fadd float %t1, 2.0
  %t3 = fmul fast float %t2, 5.0
  call void @use_f32(float %t2)
  ret float %t3
}

; (X/C1 + C2) * C3 => X/(C1/C3) + C2*C3
; 0x10000000000000 = DBL_MIN
; TODO: We don't convert the fast fdiv to fmul because that would be multiplication
; by a denormal, but we could do better when we know that denormals are not a problem.

define double @fmul_fadd_fdiv_distribute2(double %x) {
; CHECK-LABEL: @fmul_fadd_fdiv_distribute2(
; CHECK-NEXT:    [[TMP1:%.*]] = fdiv reassoc double [[X:%.*]], 0x7FE8000000000000
; CHECK-NEXT:    [[T3:%.*]] = fadd reassoc double [[TMP1]], 0x34000000000000
; CHECK-NEXT:    ret double [[T3]]
;
  %t1 = fdiv double %x, 3.0
  %t2 = fadd double %t1, 5.0
  %t3 = fmul reassoc double %t2, 0x10000000000000
  ret double %t3
}

; 5.0e-1 * DBL_MIN yields denormal, so "(f1*3.0 + 5.0e-1) * DBL_MIN" cannot
; be simplified into f1 * (3.0*DBL_MIN) + (5.0e-1*DBL_MIN)

define double @fmul_fadd_fdiv_distribute3(double %x) {
; CHECK-LABEL: @fmul_fadd_fdiv_distribute3(
; CHECK-NEXT:    [[TMP1:%.*]] = fdiv reassoc double [[X:%.*]], 0x7FE8000000000000
; CHECK-NEXT:    [[T3:%.*]] = fadd reassoc double [[TMP1]], 0x34000000000000
; CHECK-NEXT:    ret double [[T3]]
;
  %t1 = fdiv double %x, 3.0
  %t2 = fadd double %t1, 5.0
  %t3 = fmul reassoc double %t2, 0x10000000000000
  ret double %t3
}

; FIXME: This should only need 'reassoc'.
; (C2 - (X*C1)) * C3 => (C2*C3) - (X * (C1*C3))

define float @fmul_fsub_fmul_distribute(float %x) {
; CHECK-LABEL: @fmul_fsub_fmul_distribute(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[X:%.*]], 3.000000e+01
; CHECK-NEXT:    [[T3:%.*]] = fsub fast float 1.000000e+01, [[TMP1]]
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fmul float %x, 6.0
  %t2 = fsub float 2.0, %t1
  %t3 = fmul fast float %t2, 5.0
  ret float %t3
}

define float @fmul_fsub_fmul_distribute_extra_use(float %x) {
; CHECK-LABEL: @fmul_fsub_fmul_distribute_extra_use(
; CHECK-NEXT:    [[T1:%.*]] = fmul float [[X:%.*]], 6.000000e+00
; CHECK-NEXT:    [[T2:%.*]] = fsub float 2.000000e+00, [[T1]]
; CHECK-NEXT:    [[T3:%.*]] = fmul fast float [[T2]], 5.000000e+00
; CHECK-NEXT:    call void @use_f32(float [[T2]])
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fmul float %x, 6.0
  %t2 = fsub float 2.0, %t1
  %t3 = fmul fast float %t2, 5.0
  call void @use_f32(float %t2)
  ret float %t3
}

; FIXME: This should only need 'reassoc'.
; ((X*C1) - C2) * C3 => (X * (C1*C3)) - C2*C3

define float @fmul_fsub_fmul_distribute2(float %x) {
; CHECK-LABEL: @fmul_fsub_fmul_distribute2(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[X:%.*]], 3.000000e+01
; CHECK-NEXT:    [[T3:%.*]] = fadd fast float [[TMP1]], -1.000000e+01
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fmul float %x, 6.0
  %t2 = fsub float %t1, 2.0
  %t3 = fmul fast float %t2, 5.0
  ret float %t3
}

define float @fmul_fsub_fmul_distribute2_extra_use(float %x) {
; CHECK-LABEL: @fmul_fsub_fmul_distribute2_extra_use(
; CHECK-NEXT:    [[T1:%.*]] = fmul float [[X:%.*]], 6.000000e+00
; CHECK-NEXT:    [[T2:%.*]] = fsub float 2.000000e+00, [[T1]]
; CHECK-NEXT:    [[T3:%.*]] = fmul fast float [[T2]], 5.000000e+00
; CHECK-NEXT:    call void @use_f32(float [[T2]])
; CHECK-NEXT:    ret float [[T3]]
;
  %t1 = fmul float %x, 6.0
  %t2 = fsub float 2.0, %t1
  %t3 = fmul fast float %t2, 5.0
  call void @use_f32(float %t2)
  ret float %t3
}

; "(X*Y) * X => (X*X) * Y" is disabled if "X*Y" has multiple uses

define float @common_factor(float %x, float %y) {
; CHECK-LABEL: @common_factor(
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL1:%.*]] = fmul fast float [[MUL]], [[X]]
; CHECK-NEXT:    [[ADD:%.*]] = fadd float [[MUL1]], [[MUL]]
; CHECK-NEXT:    ret float [[ADD]]
;
  %mul = fmul float %x, %y
  %mul1 = fmul fast float %mul, %x
  %add = fadd float %mul1, %mul
  ret float %add
}

define double @fmul_fdiv_factor_squared(double %x, double %y) {
; CHECK-LABEL: @fmul_fdiv_factor_squared(
; CHECK-NEXT:    [[DIV:%.*]] = fdiv fast double [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[SQUARED:%.*]] = fmul fast double [[DIV]], [[DIV]]
; CHECK-NEXT:    ret double [[SQUARED]]
;
  %div = fdiv fast double %x, %y
  %squared = fmul fast double %div, %div
  ret double %squared
}

define double @fmul_fdivs_factor_common_denominator(double %x, double %y, double %z) {
; CHECK-LABEL: @fmul_fdivs_factor_common_denominator(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast double [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = fmul fast double [[Z:%.*]], [[Z]]
; CHECK-NEXT:    [[MUL:%.*]] = fdiv fast double [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret double [[MUL]]
;
  %div1 = fdiv double %x, %z
  %div2 = fdiv double %y, %z
  %mul = fmul fast double %div1, %div2
  ret double %mul
}

define double @fmul_fdivs_factor(double %x, double %y, double %z, double %w) {
; CHECK-LABEL: @fmul_fdivs_factor(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc double [[Z:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = fdiv reassoc double [[TMP1]], [[W:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fdiv reassoc double [[TMP2]], [[Y:%.*]]
; CHECK-NEXT:    ret double [[MUL]]
;
  %div1 = fdiv double %x, %y
  %div2 = fdiv double %z, %w
  %mul = fmul reassoc double %div1, %div2
  ret double %mul
}

define double @fmul_fdiv_factor(double %x, double %y, double %z) {
; CHECK-LABEL: @fmul_fdiv_factor(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc double [[X:%.*]], [[Z:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fdiv reassoc double [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret double [[MUL]]
;
  %div = fdiv double %x, %y
  %mul = fmul reassoc double %div, %z
  ret double %mul
}

define double @fmul_fdiv_factor_constant1(double %x, double %y) {
; CHECK-LABEL: @fmul_fdiv_factor_constant1(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc double [[X:%.*]], 4.200000e+01
; CHECK-NEXT:    [[MUL:%.*]] = fdiv reassoc double [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret double [[MUL]]
;
  %div = fdiv double %x, %y
  %mul = fmul reassoc double %div, 42.0
  ret double %mul
}

define <2 x float> @fmul_fdiv_factor_constant2(<2 x float> %x, <2 x float> %y) {
; CHECK-LABEL: @fmul_fdiv_factor_constant2(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc <2 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fdiv reassoc <2 x float> [[TMP1]], <float 4.200000e+01, float 1.200000e+01>
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %div = fdiv <2 x float> %x, <float 42.0, float 12.0>
  %mul = fmul reassoc <2 x float> %div, %y
  ret <2 x float> %mul
}

define float @fmul_fdiv_factor_extra_use(float %x, float %y) {
; CHECK-LABEL: @fmul_fdiv_factor_extra_use(
; CHECK-NEXT:    [[DIV:%.*]] = fdiv float [[X:%.*]], 4.200000e+01
; CHECK-NEXT:    call void @use_f32(float [[DIV]])
; CHECK-NEXT:    [[MUL:%.*]] = fmul reassoc float [[DIV]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %div = fdiv float %x, 42.0
  call void @use_f32(float %div)
  %mul = fmul reassoc float %div, %y
  ret float %mul
}

; Avoid infinite looping by moving negation out of a constant expression.

@g = external global {[2 x i8*]}, align 1

define double @fmul_negated_constant_expression(double %x) {
; CHECK-LABEL: @fmul_negated_constant_expression(
; CHECK-NEXT:    [[R:%.*]] = fmul double [[X:%.*]], fsub (double -0.000000e+00, double bitcast (i64 ptrtoint (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @g, i64 0, inrange i32 0, i64 2) to i64) to double))
; CHECK-NEXT:    ret double [[R]]
;
  %r = fmul double %x, fsub (double -0.000000e+00, double bitcast (i64 ptrtoint (i8** getelementptr inbounds ({ [2 x i8*] }, { [2 x i8*] }* @g, i64 0, inrange i32 0, i64 2) to i64) to double))
  ret double %r
}

define float @negate_if_true(float %x, i1 %cond) {
; CHECK-LABEL: @negate_if_true(
; CHECK-NEXT:    [[TMP1:%.*]] = fneg float [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = select i1 [[COND:%.*]], float [[TMP1]], float [[X]]
; CHECK-NEXT:    ret float [[TMP2]]
;
  %sel = select i1 %cond, float -1.0, float 1.0
  %r = fmul float %sel, %x
  ret float %r
}

define float @negate_if_false(float %x, i1 %cond) {
; CHECK-LABEL: @negate_if_false(
; CHECK-NEXT:    [[TMP1:%.*]] = fneg arcp float [[X:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = select arcp i1 [[COND:%.*]], float [[X]], float [[TMP1]]
; CHECK-NEXT:    ret float [[TMP2]]
;
  %sel = select i1 %cond, float 1.0, float -1.0
  %r = fmul arcp float %sel, %x
  ret float %r
}

define <2 x double> @negate_if_true_commute(<2 x double> %px, i1 %cond) {
; CHECK-LABEL: @negate_if_true_commute(
; CHECK-NEXT:    [[X:%.*]] = fdiv <2 x double> <double 4.200000e+01, double 4.200000e+01>, [[PX:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = fneg ninf <2 x double> [[X]]
; CHECK-NEXT:    [[TMP2:%.*]] = select ninf i1 [[COND:%.*]], <2 x double> [[TMP1]], <2 x double> [[X]]
; CHECK-NEXT:    ret <2 x double> [[TMP2]]
;
  %x = fdiv <2 x double> <double 42.0, double 42.0>, %px  ; thwart complexity-based canonicalization
  %sel = select i1 %cond, <2 x double> <double -1.0, double -1.0>, <2 x double> <double 1.0, double 1.0>
  %r = fmul ninf <2 x double> %x, %sel
  ret <2 x double> %r
}

define <2 x double> @negate_if_false_commute(<2 x double> %px, <2 x i1> %cond) {
; CHECK-LABEL: @negate_if_false_commute(
; CHECK-NEXT:    [[X:%.*]] = fdiv <2 x double> <double 4.200000e+01, double 5.100000e+00>, [[PX:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = fneg <2 x double> [[X]]
; CHECK-NEXT:    [[TMP2:%.*]] = select <2 x i1> [[COND:%.*]], <2 x double> [[X]], <2 x double> [[TMP1]]
; CHECK-NEXT:    ret <2 x double> [[TMP2]]
;
  %x = fdiv <2 x double> <double 42.0, double 5.1>, %px  ; thwart complexity-based canonicalization
  %sel = select <2 x i1> %cond, <2 x double> <double 1.0, double 1.0>, <2 x double> <double -1.0, double -1.0>
  %r = fmul <2 x double> %x, %sel
  ret <2 x double> %r
}

; Negative test

define float @negate_if_true_extra_use(float %x, i1 %cond) {
; CHECK-LABEL: @negate_if_true_extra_use(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[COND:%.*]], float -1.000000e+00, float 1.000000e+00
; CHECK-NEXT:    call void @use_f32(float [[SEL]])
; CHECK-NEXT:    [[R:%.*]] = fmul float [[SEL]], [[X:%.*]]
; CHECK-NEXT:    ret float [[R]]
;
  %sel = select i1 %cond, float -1.0, float 1.0
  call void @use_f32(float %sel)
  %r = fmul float %sel, %x
  ret float %r
}

; Negative test

define <2 x double> @negate_if_true_wrong_constant(<2 x double> %px, i1 %cond) {
; CHECK-LABEL: @negate_if_true_wrong_constant(
; CHECK-NEXT:    [[X:%.*]] = fdiv <2 x double> <double 4.200000e+01, double 4.200000e+01>, [[PX:%.*]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[COND:%.*]], <2 x double> <double -1.000000e+00, double 0.000000e+00>, <2 x double> <double 1.000000e+00, double 1.000000e+00>
; CHECK-NEXT:    [[R:%.*]] = fmul <2 x double> [[X]], [[SEL]]
; CHECK-NEXT:    ret <2 x double> [[R]]
;
  %x = fdiv <2 x double> <double 42.0, double 42.0>, %px  ; thwart complexity-based canonicalization
  %sel = select i1 %cond, <2 x double> <double -1.0, double 0.0>, <2 x double> <double 1.0, double 1.0>
  %r = fmul <2 x double> %x, %sel
  ret <2 x double> %r
}

; X *fast (C ? 1.0 : 0.0) -> C ? X : 0.0
define float @fmul_select(float %x, i1 %c) {
; CHECK-LABEL: @fmul_select(
; CHECK-NEXT:    [[MUL:%.*]] = select fast i1 [[C:%.*]], float [[X:%.*]], float 0.000000e+00
; CHECK-NEXT:    ret float [[MUL]]
;
  %sel = select i1 %c, float 1.0, float 0.0
  %mul = fmul fast float %sel, %x
  ret float %mul
}

; X *fast (C ? 1.0 : 0.0) -> C ? X : 0.0
define <2 x float> @fmul_select_vec(<2 x float> %x, i1 %c) {
; CHECK-LABEL: @fmul_select_vec(
; CHECK-NEXT:    [[MUL:%.*]] = select fast i1 [[C:%.*]], <2 x float> [[X:%.*]], <2 x float> zeroinitializer
; CHECK-NEXT:    ret <2 x float> [[MUL]]
;
  %sel = select i1 %c, <2 x float> <float 1.0, float 1.0>, <2 x float> zeroinitializer
  %mul = fmul fast <2 x float> %sel, %x
  ret <2 x float> %mul
}

; Without fast math flags we can't optimize X * (C ? 1.0 : 0.0) -> C ? X : 0.0
define float @fmul_select_strict(float %x, i1 %c) {
; CHECK-LABEL: @fmul_select_strict(
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[C:%.*]], float 1.000000e+00, float 0.000000e+00
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[SEL]], [[X:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sel = select i1 %c, float 1.0, float 0.0
  %mul = fmul float %sel, %x
  ret float %mul
}

; sqrt(X) *fast (C ? sqrt(X) : 1.0) -> C ? X : sqrt(X)
define double @fmul_sqrt_select(double %x, i1 %c) {
; CHECK-LABEL: @fmul_sqrt_select(
; CHECK-NEXT:    [[SQR:%.*]] = call double @llvm.sqrt.f64(double [[X:%.*]])
; CHECK-NEXT:    [[MUL:%.*]] = select fast i1 [[C:%.*]], double [[X]], double [[SQR]]
; CHECK-NEXT:    ret double [[MUL]]
;
  %sqr = call double @llvm.sqrt.f64(double %x)
  %sel = select i1 %c, double %sqr, double 1.0
  %mul = fmul fast double %sqr, %sel
  ret double %mul
}
