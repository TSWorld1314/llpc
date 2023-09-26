; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint' -S %s 2>%t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

%struct.DispatchSystemData = type { i32 }

declare i64 @_AmdGetFuncAddrMyFunc()
declare i32 @_AmdGetFuncAddrMyFunc2()

declare %struct.DispatchSystemData @_cont_SetupRayGen()

declare !types !8 i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)

define { i64, i32 } @main() {
; CHECK-LABEL: define { i64, i32 } @main() !continuation.entry !12 !continuation.registercount !6 !continuation !13 {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA:%.*]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @continuations.getSystemData.s_struct.DispatchSystemDatas()
; CHECK-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; CHECK-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; CHECK-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; CHECK-NEXT:    [[V0:%.*]] = insertvalue { i64, i32 } undef, i64 ptrtoint (ptr @MyFunc to i64), 0
; CHECK-NEXT:    [[V1:%.*]] = insertvalue { i64, i32 } undef, i32 ptrtoint (ptr @MyFunc2 to i32), 1
; CHECK-NEXT:    ret { i64, i32 } [[V1]]
;
entry:
  %val = call i64 @_AmdGetFuncAddrMyFunc()
  %val2 = call i32 @_AmdGetFuncAddrMyFunc2()
  %v0 = insertvalue { i64, i32 } undef, i64 %val, 0
  %v1 = insertvalue { i64, i32 } undef, i32 %val2, 1
  ret { i64, i32 } %v1
}

define i32 @MyFunc() {
; CHECK-LABEL: define i32 @MyFunc() {
; CHECK-NEXT:    ret i32 5
;
  ret i32 5
}

define i32 @MyFunc2() {
; CHECK-LABEL: define i32 @MyFunc2() {
; CHECK-NEXT:    ret i32 5
;
  ret i32 5
}

!dx.entryPoints = !{!0, !3}
!continuation.stackAddrspace = !{!7}

!0 = !{null, !"", null, !1, !6}
!1 = !{!2, null, null, null}
!2 = !{!3}
!3 = !{i1 ()* @main, !"main", null, null, !4}
!4 = !{i32 8, i32 7, i32 6, i32 16, i32 7, i32 8, i32 5, !5}
!5 = !{i32 0}
!6 = !{i32 0, i64 65536}
!7 = !{i32 21}
!8 = !{!"function", i32 poison, !9}
!9 = !{i32 0, %struct.DispatchSystemData poison}