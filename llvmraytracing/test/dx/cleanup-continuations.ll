; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --check-globals --version 3
; RUN: opt --verify-each -passes='cleanup-continuations,lint,continuations-lint' -S %s --lint-abort-on-error | FileCheck %s

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-p32:32:32-i1:32-i8:8-i16:16-i32:32-i64:32-f16:16-f32:32-f64:32-v8:8-v16:16-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%continuation.token = type { }
%await_with_ret_value.Frame = type { i32 }
%simple_await.Frame = type { i32 }
%simple_await_entry.Frame = type { }
%phi_of_cont_state.Frame = type { i32, i32 }

declare %continuation.token* @async_fun()
declare { i32 } @lgc.ilcps.getReturnValue__i32() #0
declare void @lgc.cps.complete()
declare void @lgc.cps.jump(...)

define { i8*, %continuation.token* } @simple_await(i32 %dummyRet, i8* %0) !continuation !0 !continuation.registercount !4 {
; CHECK-LABEL: define void @simple_await(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i32 [[DUMMYRET:%.*]]) !continuation [[META1:![0-9]+]] !continuation.registercount [[META2:![0-9]+]] !continuation.stacksize [[META3:![0-9]+]] !continuation.state [[META3]] {
; CHECK-NEXT:  AllocaSpillBB:
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[TMP4]], 8
; CHECK-NEXT:    store i32 [[TMP1]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = inttoptr i32 [[TMP4]] to ptr addrspace(21)
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP2]], i32 0
; CHECK-NEXT:    store i32 -1, ptr addrspace(21) [[TMP3]], align 4
; CHECK-NEXT:    [[CALLEE:%.*]] = ptrtoint ptr @async_fun to i32
; CHECK-NEXT:    [[TMP0:%.*]] = call i32 (...) @lgc.cps.as.continuation.reference(ptr @simple_await.resume.0)
; CHECK-NEXT:    [[TMP5:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[CALLEE]], i32 -1, i32 [[TMP5]], i32 [[TMP0]], i64 2), !continuation.registercount [[META2]], !continuation.returnedRegistercount [[META2]]
; CHECK-NEXT:    unreachable
;
AllocaSpillBB:
  %FramePtr = bitcast i8* %0 to %simple_await.Frame*
  %.spill.addr = getelementptr inbounds %simple_await.Frame, %simple_await.Frame* %FramePtr, i32 0, i32 0
  store i32 -1, i32* %.spill.addr, align 4
  %callee = ptrtoint ptr @async_fun to i32
  %tok = call %continuation.token* @async_fun(i32 %callee, i64 1, i64 2), !continuation.registercount !4, !continuation.returnedRegistercount !4
  %1 = insertvalue { i8*, %continuation.token* } { i8* bitcast ({ i8*, %continuation.token* } (i8*, i1)* @simple_await.resume.0 to i8*), %continuation.token* undef }, %continuation.token* %tok, 1
  ret { i8*, %continuation.token* } %1
}

define internal { i8*, %continuation.token* } @simple_await.resume.0(i8* noalias nonnull align 16 dereferenceable(8) %0, i1 %1) !continuation !0 {
; CHECK-LABEL: define dso_local void @simple_await.resume.0(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i32 [[TMP0:%.*]]) !continuation [[META1]] !continuation.registercount [[META2]] {
; CHECK-NEXT:  entryresume.0:
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = add i32 [[TMP1]], -8
; CHECK-NEXT:    [[TMP3:%.*]] = inttoptr i32 [[TMP2]] to ptr addrspace(21)
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP3]], i32 0
; CHECK-NEXT:    [[DOTRELOAD:%.*]] = load i32, ptr addrspace(21) [[TMP4]], align 4
; CHECK-NEXT:    [[TMP5:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = add i32 [[TMP5]], -8
; CHECK-NEXT:    store i32 [[TMP6]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP7:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[DOTRELOAD]], i32 -1, i32 [[TMP7]], i32 poison), !continuation.registercount [[META2]]
; CHECK-NEXT:    unreachable
;
entryresume.0:
  %FramePtr = bitcast i8* %0 to %simple_await.Frame*
  %vFrame = bitcast %simple_await.Frame* %FramePtr to i8*
  %.reload.addr = getelementptr inbounds %simple_await.Frame, %simple_await.Frame* %FramePtr, i32 0, i32 0
  %.reload = load i32, i32* %.reload.addr, align 4
  call void (...) @lgc.cps.jump(i32 %.reload, i32 -1, i32 poison, i32 poison), !continuation.registercount !4
  unreachable
}

define { i8*, %continuation.token* } @simple_await_entry(i32 %dummyRet, i8* %0) !continuation.entry !2 !continuation !3 !continuation.registercount !4 {
; CHECK-LABEL: define void @simple_await_entry(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i32 [[DUMMYRET:%.*]]) !continuation [[META4:![0-9]+]] !continuation.registercount [[META2]] !continuation.entry [[META5:![0-9]+]] !continuation.stacksize [[META3]] !continuation.state [[META3]] {
; CHECK-NEXT:  AllocaSpillBB:
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = add i32 [[TMP2]], 8
; CHECK-NEXT:    store i32 [[TMP1]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[CALLEE:%.*]] = ptrtoint ptr @async_fun to i32
; CHECK-NEXT:    [[TMP0:%.*]] = call i32 (...) @lgc.cps.as.continuation.reference(ptr @simple_await_entry.resume.0)
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[CALLEE]], i32 -1, i32 [[TMP3]], i32 [[TMP0]], i64 2), !continuation.registercount [[META2]], !continuation.returnedRegistercount [[META2]]
; CHECK-NEXT:    unreachable
;
AllocaSpillBB:
  %FramePtr = bitcast i8* %0 to %simple_await_entry.Frame*
  %callee = ptrtoint ptr @async_fun to i32
  %tok = call %continuation.token* @async_fun(i32 %callee, i64 1, i64 2), !continuation.registercount !4, !continuation.returnedRegistercount !4
  %1 = bitcast { i8*, %continuation.token* } (i8*, i1)* @simple_await_entry.resume.0 to i8*
  %2 = insertvalue { i8*, %continuation.token* } undef, i8* %1, 0
  %3 = insertvalue { i8*, %continuation.token* } %2, %continuation.token* %tok, 1
  ret { i8*, %continuation.token* } %3
}

define internal { i8*, %continuation.token* } @simple_await_entry.resume.0(i8* noalias nonnull align 16 dereferenceable(8) %0, i1 %1) !continuation.entry !2 !continuation !3 {
; CHECK-LABEL: define dso_local void @simple_await_entry.resume.0(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i32 [[TMP0:%.*]]) !continuation [[META4]] !continuation.registercount [[META2]] {
; CHECK-NEXT:  entryresume.0:
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = add i32 [[TMP1]], -8
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = add i32 [[TMP3]], -8
; CHECK-NEXT:    store i32 [[TMP4]], ptr [[CSP]], align 4
; CHECK-NEXT:    ret void
;
entryresume.0:
  %FramePtr = bitcast i8* %0 to %simple_await_entry.Frame*
  %vFrame = bitcast %simple_await_entry.Frame* %FramePtr to i8*
  call void @lgc.cps.complete(), !continuation.registercount !4
  unreachable
}

define { i8*, %continuation.token* } @await_with_ret_value(i32 %dummyRet, i8* %0) !continuation !1 !continuation.registercount !4 {
; CHECK-LABEL: define void @await_with_ret_value(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i32 [[DUMMYRET:%.*]]) !continuation [[META6:![0-9]+]] !continuation.registercount [[META2]] !continuation.stacksize [[META3]] !continuation.state [[META3]] {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP5:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = add i32 [[TMP5]], 8
; CHECK-NEXT:    store i32 [[TMP2]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = inttoptr i32 [[TMP5]] to ptr addrspace(21)
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP3]], i32 0
; CHECK-NEXT:    store i64 -1, ptr addrspace(21) [[TMP4]], align 4
; CHECK-NEXT:    [[CALLEE:%.*]] = ptrtoint ptr @async_fun to i32
; CHECK-NEXT:    [[TMP1:%.*]] = call i32 (...) @lgc.cps.as.continuation.reference(ptr @await_with_ret_value.resume.0)
; CHECK-NEXT:    [[TMP6:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[CALLEE]], i32 -1, i32 [[TMP6]], i32 [[TMP1]], i64 2), !continuation.registercount [[META2]], !continuation.returnedRegistercount [[META2]]
; CHECK-NEXT:    unreachable
;
  %FramePtr = bitcast i8* %0 to %await_with_ret_value.Frame*
  %.spill.addr = getelementptr inbounds %await_with_ret_value.Frame, %await_with_ret_value.Frame* %FramePtr, i32 0, i32 0
  store i64 -1, i64* %.spill.addr, align 4
  %callee = ptrtoint ptr @async_fun to i32
  %tok = call %continuation.token* @async_fun(i32 %callee, i64 1, i64 2), !continuation.registercount !4, !continuation.returnedRegistercount !4
  %res = insertvalue { i8*, %continuation.token* } { i8* bitcast ({ i8*, %continuation.token* } (i8*, i1)* @await_with_ret_value.resume.0 to i8*), %continuation.token* undef }, %continuation.token* %tok, 1
  ret { i8*, %continuation.token* } %res
}

define internal { i8*, %continuation.token* } @await_with_ret_value.resume.0(i8* noalias nonnull align 16 dereferenceable(8) %0, i1 %1) !continuation !1 {
; CHECK-LABEL: define dso_local void @await_with_ret_value.resume.0(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i32 [[TMP0:%.*]], i32 [[TMP1:%.*]]) !continuation [[META6]] !continuation.registercount [[META2]] {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = add i32 [[TMP2]], -8
; CHECK-NEXT:    [[TMP9:%.*]] = insertvalue { i32 } poison, i32 [[TMP1]], 0
; CHECK-NEXT:    [[TMP4:%.*]] = inttoptr i32 [[TMP3]] to ptr addrspace(21)
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP4]], i32 0
; CHECK-NEXT:    [[DOTRELOAD:%.*]] = load i32, ptr addrspace(21) [[TMP5]], align 4
; CHECK-NEXT:    [[RES_2:%.*]] = extractvalue { i32 } [[TMP9]], 0
; CHECK-NEXT:    [[TMP6:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP7:%.*]] = add i32 [[TMP6]], -8
; CHECK-NEXT:    store i32 [[TMP7]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP8:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[DOTRELOAD]], i32 -1, i32 [[TMP8]], i32 poison, i32 [[RES_2]]), !continuation.registercount [[META2]]
; CHECK-NEXT:    unreachable
;
  %FramePtr = bitcast i8* %0 to %await_with_ret_value.Frame*
  %vFrame = bitcast %await_with_ret_value.Frame* %FramePtr to i8*
  %.reload.addr = getelementptr inbounds %await_with_ret_value.Frame, %await_with_ret_value.Frame* %FramePtr, i32 0, i32 0
  %.reload = load i32, i32* %.reload.addr, align 4
  %res = call { i32 } @lgc.ilcps.getReturnValue__i32()
  %res.2 = extractvalue { i32 } %res, 0
  call void (...) @lgc.cps.jump(i32 %.reload, i32 -1, i32 poison, i32 poison, i32 %res.2), !continuation.registercount !4
  unreachable
}

; unreachables in their own block added by switch case statements should be ignored
define { i8*, %continuation.token* } @switch_case_unreachable(i32 %dummyRet, i8* %0) !continuation !6 !continuation.registercount !4 {
; CHECK-LABEL: define void @switch_case_unreachable(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i32 [[DUMMYRET:%.*]]) !continuation [[META7:![0-9]+]] !continuation.registercount [[META2]] !continuation.stacksize [[META3]] !continuation.state [[META3]] {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = add i32 [[TMP1]], 8
; CHECK-NEXT:    store i32 [[TMP2]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = inttoptr i32 [[TMP1]] to ptr addrspace(21)
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP3]], i32 0
; CHECK-NEXT:    store i64 -1, ptr addrspace(21) [[TMP4]], align 4
; CHECK-NEXT:    [[VAL:%.*]] = urem i32 [[DUMMYRET]], 2
; CHECK-NEXT:    switch i32 [[VAL]], label [[UNREACHABLE:%.*]] [
; CHECK-NEXT:      i32 0, label [[A:%.*]]
; CHECK-NEXT:      i32 1, label [[B:%.*]]
; CHECK-NEXT:    ]
; CHECK:       unreachable:
; CHECK-NEXT:    unreachable
; CHECK:       b:
; CHECK-NEXT:    br label [[A]]
; CHECK:       a:
; CHECK-NEXT:    [[TMP5:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = add i32 [[TMP5]], -8
; CHECK-NEXT:    store i32 [[TMP6]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP7:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[DUMMYRET]], i32 -1, i32 [[TMP7]], i32 poison), !continuation.registercount [[META2]]
; CHECK-NEXT:    unreachable
;
  %FramePtr = bitcast i8* %0 to %await_with_ret_value.Frame*
  %.spill.addr = getelementptr inbounds %await_with_ret_value.Frame, %await_with_ret_value.Frame* %FramePtr, i32 0, i32 0
  store i64 -1, i64* %.spill.addr, align 4
  %val = urem i32 %dummyRet, 2
  switch i32 %val, label %unreachable [
  i32 0, label %a
  i32 1, label %b
  ]

unreachable:
  unreachable

b:
  br label %a

a:
  call void (...) @lgc.cps.jump(i32 %dummyRet, i32 -1, i32 poison, i32 poison), !continuation.registercount !4
  unreachable
}

; Check that phis on the continuation state compile
define { i8*, %continuation.token* } @phi_of_cont_state(i32 %dummyRet, ptr %FramePtr) !continuation !7 !continuation.registercount !4 {
; CHECK-LABEL: define void @phi_of_cont_state(
; CHECK-SAME: i32 [[CSPINIT:%.*]], i32 [[DUMMYRET:%.*]]) !continuation [[META8:![0-9]+]] !continuation.registercount [[META2]] !continuation.stacksize [[META3]] !continuation.state [[META3]] {
; CHECK-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = add i32 [[TMP1]], 8
; CHECK-NEXT:    store i32 [[TMP2]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[COND:%.*]] = trunc i32 [[DUMMYRET]] to i1
; CHECK-NEXT:    br i1 [[COND]], label [[LA:%.*]], label [[LB:%.*]]
; CHECK:       la:
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       lb:
; CHECK-NEXT:    [[TMP3:%.*]] = add i32 [[TMP1]], 4
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[C_0:%.*]] = phi i32 [ [[TMP1]], [[LA]] ], [ [[TMP3]], [[LB]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = inttoptr i32 [[C_0]] to ptr addrspace(21)
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP4]], i32 0
; CHECK-NEXT:    store i32 -1, ptr addrspace(21) [[TMP5]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP7:%.*]] = add i32 [[TMP6]], -8
; CHECK-NEXT:    store i32 [[TMP7]], ptr [[CSP]], align 4
; CHECK-NEXT:    [[TMP8:%.*]] = load i32, ptr [[CSP]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 [[DUMMYRET]], i32 -1, i32 [[TMP8]], i32 poison), !continuation.registercount [[META2]]
; CHECK-NEXT:    unreachable
;
  %cond = trunc i32 %dummyRet to i1
  br i1 %cond, label %la, label %lb

la:
  %a = getelementptr inbounds %phi_of_cont_state.Frame, ptr %FramePtr, i32 0, i32 0
  br label %end

lb:
  %b = getelementptr inbounds %phi_of_cont_state.Frame, ptr %FramePtr, i32 0, i32 1
  br label %end

end:
  %c = phi ptr [ %a, %la ], [ %b, %lb ]
  store i32 -1, ptr %c, align 4
  call void (...) @lgc.cps.jump(i32 %dummyRet, i32 -1, i32 poison, i32 poison), !continuation.registercount !4
  unreachable
}

attributes #0 = { nounwind }

!continuation.stackAddrspace = !{!5}

!0 = !{{ i8*, %continuation.token* } (i8*)* @simple_await}
!1 = !{{ i8*, %continuation.token* } (i8*)* @await_with_ret_value}
!2 = !{}
!3 = !{{ i8*, %continuation.token* } (i8*)* @simple_await_entry}
!4 = !{i32 0}
!5 = !{i32 21}
!6 = !{{ i8*, %continuation.token* } (i8*)* @switch_case_unreachable}
!7 = !{{ i8*, %continuation.token* } (i8*)* @phi_of_cont_state}
;.
; CHECK: attributes #[[ATTR0:[0-9]+]] = { nounwind }
; CHECK: attributes #[[ATTR1:[0-9]+]] = { nounwind willreturn memory(inaccessiblemem: readwrite) }
; CHECK: attributes #[[ATTR2:[0-9]+]] = { nounwind willreturn }
; CHECK: attributes #[[ATTR3:[0-9]+]] = { nounwind willreturn memory(inaccessiblemem: read) }
;.
; CHECK: [[META0:![0-9]+]] = !{i32 21}
; CHECK: [[META1]] = !{ptr @simple_await}
; CHECK: [[META2]] = !{i32 0}
; CHECK: [[META3]] = !{i32 8}
; CHECK: [[META4]] = !{ptr @simple_await_entry}
; CHECK: [[META5]] = !{}
; CHECK: [[META6]] = !{ptr @await_with_ret_value}
; CHECK: [[META7]] = !{ptr @switch_case_unreachable}
; CHECK: [[META8]] = !{ptr @phi_of_cont_state}
;.
