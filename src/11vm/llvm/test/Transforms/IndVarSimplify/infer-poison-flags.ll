; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -indvars -S | FileCheck %s

@A = external global i32

define void @add_cr_nsw_nuw() {
; CHECK-LABEL: @add_cr_nsw_nuw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 1000
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %i.next = add i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 1000
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

define void @add_cr_nuw() {
; CHECK-LABEL: @add_cr_nuw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = add nuw i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], -1
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %i.next = add i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, -1
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

define void @add_cr_nsw() {
; CHECK-LABEL: @add_cr_nsw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ -10, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 10
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ -10, %entry ], [ %i.next, %loop ]
  %i.next = add i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 10
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

define void @add_cr_none() {
; CHECK-LABEL: @add_cr_none(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 10, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = add i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 0
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 10, %entry ], [ %i.next, %loop ]
  %i.next = add i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 0
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

define void @add_unknown_none(i32 %n) {
; CHECK-LABEL: @add_unknown_none(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = add i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %i.next = add i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, %n
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

define void @sub_cr_nsw_nuw() {
; CHECK-LABEL: @sub_cr_nsw_nuw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = sub nsw i32 [[I]], -1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 1000
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %i.next = sub i32 %i, -1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 1000
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}


define void @sub_unknown_none(i32 %n) {
; CHECK-LABEL: @sub_unknown_none(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = sub i32 [[I]], -1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], [[N:%.*]]
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %i.next = sub i32 %i, -1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, %n
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}


; NOTE: For the rest of these, it looks like we're failing to use a statically
; computable backedge taken count to infer a range on the IV and thus fail to
; prove flags via constant range reasoning.

; TODO
define void @mul_cr_nsw_nuw() {
; CHECK-LABEL: @mul_cr_nsw_nuw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 1, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = mul i32 [[I]], 2
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 1024
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 1, %entry ], [ %i.next, %loop ]
  %i.next = mul i32 %i, 2
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 1024
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

;; TODO
define void @shl_cr_nsw_nuw() {
; CHECK-LABEL: @shl_cr_nsw_nuw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 1, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = shl i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 1024
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 1, %entry ], [ %i.next, %loop ]
  %i.next = shl i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 1024
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

; TODO
define void @lshr_cr_nsw_nuw() {
; CHECK-LABEL: @lshr_cr_nsw_nuw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 1024, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = lshr i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 0
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 1024, %entry ], [ %i.next, %loop ]
  %i.next = lshr i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 0
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

; TODO
define void @lshr_cr_nuw() {
; CHECK-LABEL: @lshr_cr_nuw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ -1, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = lshr i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 0
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ -1, %entry ], [ %i.next, %loop ]
  %i.next = lshr i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 0
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

; TODO
define void @ashr_cr_nsw_nuw() {
; CHECK-LABEL: @ashr_cr_nsw_nuw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 1024, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = ashr i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 0
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ 1024, %entry ], [ %i.next, %loop ]
  %i.next = ashr i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 0
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}

; TODO
define void @ashr_cr_nsw() {
; CHECK-LABEL: @ashr_cr_nsw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ -1024, [[ENTRY:%.*]] ], [ [[I_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[I_NEXT]] = ashr i32 [[I]], 1
; CHECK-NEXT:    store i32 [[I]], i32* @A
; CHECK-NEXT:    [[C:%.*]] = icmp ne i32 [[I_NEXT]], 1
; CHECK-NEXT:    br i1 [[C]], label [[LOOP]], label [[LOOPEXIT:%.*]]
; CHECK:       loopexit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %i = phi i32 [ -1024, %entry ], [ %i.next, %loop ]
  %i.next = ashr i32 %i, 1
  store i32 %i, i32* @A
  %c = icmp ne i32 %i.next, 1
  br i1 %c, label %loop, label %loopexit

loopexit:
  ret void
}


