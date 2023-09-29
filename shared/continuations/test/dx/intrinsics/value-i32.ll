; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt --verify-each -passes='dxil-cont-post-process,lint' -S %s 2>%t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

%struct.Payload = type { float, i32, i64, i32 }

declare !types !0 i32 @_AmdValueI32Count(%struct.Payload*)

declare !types !2 i32 @_AmdValueGetI32(%struct.Payload*, i32)

declare !types !3 void @_AmdValueSetI32(%struct.Payload*, i32, i32)

define i32 @count(%struct.Payload* %pl) !types !0 {
; CHECK-LABEL: define i32 @count
; CHECK-SAME: (ptr [[PL:%.*]]) !types !0 {
; CHECK-NEXT:    ret i32 5
;
  %val = call i32 @_AmdValueI32Count(%struct.Payload* %pl)
  ret i32 %val
}

define i32 @get(%struct.Payload* %pl) !types !0 {
; CHECK-LABEL: define i32 @get
; CHECK-SAME: (ptr [[PL:%.*]]) !types !0 {
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i32, ptr [[PL]], i32 2
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, ptr [[TMP1]], align 4
; CHECK-NEXT:    ret i32 [[TMP2]]
;
  %val = call i32 @_AmdValueGetI32(%struct.Payload* %pl, i32 2)
  ret i32 %val
}

define void @set(%struct.Payload* %pl, i32 %val) !types !4 {
; CHECK-LABEL: define void @set
; CHECK-SAME: (ptr [[PL:%.*]], i32 [[VAL:%.*]]) !types !2 {
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i32, ptr [[PL]], i32 2
; CHECK-NEXT:    store i32 [[VAL]], ptr [[TMP1]], align 4
; CHECK-NEXT:    ret void
;
  call void @_AmdValueSetI32(%struct.Payload* %pl, i32 2, i32 %val)
  ret void
}

!0 = !{!"function", i32 poison, !1}
!1 = !{i32 0, %struct.Payload poison}
!2 = !{!"function", i32 poison, !1, i32 poison}
!3 = !{!"function", !"void", !1, i32 poison, i32 poison}
!4 = !{!"function", !"void", !1, i32 poison}
