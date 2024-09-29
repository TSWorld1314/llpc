; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
;
; RUN: opt --verify-each -passes='value-specialization-test' -S %s | FileCheck %s
;
; Intentionally align i64 to 64 bits so we can test specializations within types with padding,
; and align float to 16 bits to test misaligned dword-sized scalars.
target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-p32:32:32-i1:32-i8:8-i16:16-i32:32-i64:64-f16:16-f32:16-f64:32-v8:8-v16:16-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

; Syntax:
; call void @specialize(i32 %flags, <ty> %val, i32 %dw0Kind, i32 %dw0Constant, [...])
; flag bits:
;   skip value tracking check:  0x1
;   allow replacement failures: 0x2 (if not set, fail if any dword replacement on this value fails)
; Kind values:
;   None: 0
;   Constant: 1
;   FrozenPoison: 2
declare void @specialize(...)
declare void @use(...)

define void @SimpleScalars(i32 %arg0, i32 %arg1, i32 %arg2, float %arg3) {
; CHECK-LABEL: define void @SimpleScalars(
; CHECK-SAME: i32 [[ARG0:%.*]], i32 [[ARG1:%.*]], i32 [[ARG2:%.*]], float [[ARG3:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = freeze i32 poison
; CHECK-NEXT:    call void (...) @use(i32 [[ARG0]], i32 42, i32 [[TMP1]], float 0x3744E40000000000)
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, i32 %arg0, i32 0, i32 poison)
  call void @specialize(i32 0, i32 %arg1, i32 1, i32 42)
  call void @specialize(i32 0, i32 %arg2, i32 2, i32 poison)
  call void @specialize(i32 0, float %arg3, i32 1, i32 1337)
  call void (...) @use(i32 %arg0, i32 %arg1, i32 %arg2, float %arg3)
  ret void
}

; I64 specialization is "special", as we potentially specialize low and high dwords separately.
; Test all non-trivial combinations:
;          (low dword)    (high dword)
;  * arg0: None         + Constant
;  * arg1: None         + FrozenPoison
;  * arg2: Constant     + None
;  * arg3: Constant     + FrozenPoison
;  * arg4: FrozenPoison + None
;  * arg5: FrozenPoison + Constant
; as well as uniform ones:
;  * arg6: Constant     + Constant
;  * arg7: FrozenPoison + FrozenPoison
;
; Don't check with value tracking (flags=1) as it does not support the used bitwise operations.
define void @I64s(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3, i64 %arg4, i64 %arg5, i64 %arg6, i64 %arg7) {
; CHECK-LABEL: define void @I64s(
; CHECK-SAME: i64 [[ARG0:%.*]], i64 [[ARG1:%.*]], i64 [[ARG2:%.*]], i64 [[ARG3:%.*]], i64 [[ARG4:%.*]], i64 [[ARG5:%.*]], i64 [[ARG6:%.*]], i64 [[ARG7:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[ARG0]], 4294967295
; CHECK-NEXT:    [[ARG0_SPECIALIZED:%.*]] = or i64 [[TMP1]], 4294967296
; CHECK-NEXT:    [[TMP2:%.*]] = and i64 [[ARG1]], 4294967295
; CHECK-NEXT:    [[TMP3:%.*]] = freeze i64 poison
; CHECK-NEXT:    [[TMP4:%.*]] = and i64 [[TMP3]], -4294967296
; CHECK-NEXT:    [[ARG1_SPECIALIZED:%.*]] = or i64 [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP5:%.*]] = and i64 [[ARG2]], -4294967296
; CHECK-NEXT:    [[ARG2_SPECIALIZED:%.*]] = or i64 2, [[TMP5]]
; CHECK-NEXT:    [[TMP6:%.*]] = freeze i64 poison
; CHECK-NEXT:    [[TMP7:%.*]] = and i64 [[TMP6]], -4294967296
; CHECK-NEXT:    [[ARG3_SPECIALIZED:%.*]] = or i64 3, [[TMP7]]
; CHECK-NEXT:    [[TMP8:%.*]] = freeze i64 poison
; CHECK-NEXT:    [[TMP9:%.*]] = and i64 [[TMP8]], 4294967295
; CHECK-NEXT:    [[TMP10:%.*]] = and i64 [[ARG4]], -4294967296
; CHECK-NEXT:    [[ARG4_SPECIALIZED:%.*]] = or i64 [[TMP9]], [[TMP10]]
; CHECK-NEXT:    [[TMP11:%.*]] = freeze i64 poison
; CHECK-NEXT:    [[TMP12:%.*]] = and i64 [[TMP11]], 4294967295
; CHECK-NEXT:    [[ARG5_SPECIALIZED:%.*]] = or i64 [[TMP12]], 17179869184
; CHECK-NEXT:    [[TMP13:%.*]] = freeze i64 poison
; CHECK-NEXT:    call void (...) @use(i64 [[ARG0_SPECIALIZED]], i64 [[ARG1_SPECIALIZED]], i64 [[ARG2_SPECIALIZED]], i64 [[ARG3_SPECIALIZED]], i64 [[ARG4_SPECIALIZED]], i64 [[ARG5_SPECIALIZED]], i64 25769803781, i64 [[TMP13]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 1, i64 %arg0, i32 0, i32 poison, i32 1, i32 1)
  call void @specialize(i32 1, i64 %arg1, i32 0, i32 poison, i32 2, i32 poison)
  call void @specialize(i32 1, i64 %arg2, i32 1, i32 2,      i32 0, i32 poison)
  call void @specialize(i32 1, i64 %arg3, i32 1, i32 3,      i32 2, i32 poison)
  call void @specialize(i32 1, i64 %arg4, i32 2, i32 poison, i32 0, i32 poison)
  call void @specialize(i32 1, i64 %arg5, i32 2, i32 poison, i32 1, i32 4)
  call void @specialize(i32 1, i64 %arg6, i32 1, i32 5,      i32 1, i32 6)
  call void @specialize(i32 1, i64 %arg7, i32 2, i32 poison, i32 2, i32 poison)
  call void (...) @use(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3, i64 %arg4, i64 %arg5, i64 %arg6, i64 %arg7)
  ret void
}

define void @Double(double %arg) {
; CHECK-LABEL: define void @Double(
; CHECK-SAME: double [[ARG:%.*]]) {
; CHECK-NEXT:    call void (...) @use(double 2.075080e-322)
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 1, double %arg, i32 1, i32 42, i32 1, i32 0)
  call void (...) @use(double %arg)
  ret void
}

; ptr is 64 bits wide, ptr addrspace (20) is 32 bits wide
define void @Pointers(ptr %arg0, ptr addrspace(20) %arg1) {
; CHECK-LABEL: define void @Pointers(
; CHECK-SAME: ptr [[ARG0:%.*]], ptr addrspace(20) [[ARG1:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = ptrtoint ptr [[ARG0]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = and i64 [[TMP1]], -4294967296
; CHECK-NEXT:    [[TMP3:%.*]] = or i64 42, [[TMP2]]
; CHECK-NEXT:    [[ARG0_SPECIALIZED:%.*]] = inttoptr i64 [[TMP3]] to ptr
; CHECK-NEXT:    call void (...) @use(ptr [[ARG0_SPECIALIZED]], ptr addrspace(20) inttoptr (i32 43 to ptr addrspace(20)))
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 1, ptr %arg0, i32 1, i32 42, i32 0, i32 poison)
  call void @specialize(i32 1, ptr addrspace(20) %arg1, i32 1, i32 43)
  call void (...) @use(ptr %arg0, ptr addrspace(20) %arg1)
  ret void
}

define void @Array([3 x i32] %args) {
; CHECK-LABEL: define void @Array(
; CHECK-SAME: [3 x i32] [[ARGS:%.*]]) {
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue [3 x i32] [[ARGS]], i32 42, 1
; CHECK-NEXT:    [[TMP1:%.*]] = freeze i32 poison
; CHECK-NEXT:    [[ARGS_SPECIALIZED1:%.*]] = insertvalue [3 x i32] [[ARGS_SPECIALIZED]], i32 [[TMP1]], 2
; CHECK-NEXT:    call void (...) @use([3 x i32] [[ARGS_SPECIALIZED1]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, [3 x i32] %args, i32 0, i32 poison, i32 1, i32 42, i32 2, i32 poison)
  call void (...) @use([3 x i32] %args)
  ret void
}

define void @Struct({ i32, i32, i32 } %args) {
; CHECK-LABEL: define void @Struct(
; CHECK-SAME: { i32, i32, i32 } [[ARGS:%.*]]) {
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { i32, i32, i32 } [[ARGS]], i32 42, 1
; CHECK-NEXT:    [[TMP1:%.*]] = freeze i32 poison
; CHECK-NEXT:    [[ARGS_SPECIALIZED1:%.*]] = insertvalue { i32, i32, i32 } [[ARGS_SPECIALIZED]], i32 [[TMP1]], 2
; CHECK-NEXT:    call void (...) @use({ i32, i32, i32 } [[ARGS_SPECIALIZED1]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, { i32, i32, i32 } %args, i32 0, i32 poison, i32 1, i32 42, i32 2, i32 poison)
  call void (...) @use({ i32, i32, i32 } %args)
  ret void
}

define void @Vector(<3 x i32> %args) {
; CHECK-LABEL: define void @Vector(
; CHECK-SAME: <3 x i32> [[ARGS:%.*]]) {
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertelement <3 x i32> [[ARGS]], i32 42, i64 1
; CHECK-NEXT:    [[TMP1:%.*]] = freeze i32 poison
; CHECK-NEXT:    [[ARGS_SPECIALIZED1:%.*]] = insertelement <3 x i32> [[ARGS_SPECIALIZED]], i32 [[TMP1]], i64 2
; CHECK-NEXT:    call void (...) @use(<3 x i32> [[ARGS_SPECIALIZED1]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, <3 x i32> %args, i32 0, i32 poison, i32 1, i32 42, i32 2, i32 poison)
  call void (...) @use(<3 x i32> %args)
  ret void
}

; Test that when replacing some but not all dwords of a nested struct, we directly insertvalue into the outer struct
define void @NestedStructPartialReplace({ i32, { i32, i32 } } %args) {
; CHECK-LABEL: define void @NestedStructPartialReplace(
; CHECK-SAME: { i32, { i32, i32 } } [[ARGS:%.*]]) {
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { i32, { i32, i32 } } [[ARGS]], i32 42, 1, 0
; CHECK-NEXT:    call void (...) @use({ i32, { i32, i32 } } [[ARGS_SPECIALIZED]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, { i32, { i32, i32 } } %args, i32 0, i32 poison, i32 1, i32 42, i32 0, i32 poison)
  call void (...) @use({ i32, { i32, i32 } } %args)
  ret void
}

; Test that when replacing some but not all dwords of a nested vector, we first extract the old vector,
; insert replacements, and then insert the replaced vector
define void @NestedVectorWithPartialReplace({ i32, <2 x i32>} %args) {
; CHECK-LABEL: define void @NestedVectorWithPartialReplace(
; CHECK-SAME: { i32, <2 x i32> } [[ARGS:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue { i32, <2 x i32> } [[ARGS]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x i32> [[TMP1]], i32 42, i64 0
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { i32, <2 x i32> } [[ARGS]], <2 x i32> [[TMP2]], 1
; CHECK-NEXT:    call void (...) @use({ i32, <2 x i32> } [[ARGS_SPECIALIZED]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, { i32, <2 x i32>} %args, i32 0, i32 poison, i32 1, i32 42, i32 0, i32 poison)
  call void (...) @use({ i32, <2 x i32>} %args)
  ret void
}

; Test that when replacing multiple but not all dwords of a nested vector, we first extract the old vector,
; insert all replacements, and then insert the replaced vector just once
define void @NestedVectorWithPartialMultiReplace({ i32, <3 x i32>} %args) {
; CHECK-LABEL: define void @NestedVectorWithPartialMultiReplace(
; CHECK-SAME: { i32, <3 x i32> } [[ARGS:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue { i32, <3 x i32> } [[ARGS]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <3 x i32> [[TMP1]], i32 42, i64 0
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <3 x i32> [[TMP2]], i32 43, i64 1
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { i32, <3 x i32> } [[ARGS]], <3 x i32> [[TMP3]], 1
; CHECK-NEXT:    call void (...) @use({ i32, <3 x i32> } [[ARGS_SPECIALIZED]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, { i32, <3 x i32>} %args, i32 0, i32 poison, i32 1, i32 42, i32 1, i32 43, i32 0, i32 poison)
  call void (...) @use({ i32, <3 x i32>} %args)
  ret void
}

; Test that when replacing all dwords of a nested vector, we inserted the replacement values
; into a new frozen poison vector, and then insertvalue that into the struct.
define void @NestedVectorWithFullReplace({ i32, <2 x i32>} %args) {
; CHECK-LABEL: define void @NestedVectorWithFullReplace(
; CHECK-SAME: { i32, <2 x i32> } [[ARGS:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = freeze <2 x i32> poison
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x i32> [[TMP1]], i32 42, i64 0
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x i32> [[TMP2]], i32 43, i64 1
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { i32, <2 x i32> } [[ARGS]], <2 x i32> [[TMP3]], 1
; CHECK-NEXT:    call void (...) @use({ i32, <2 x i32> } [[ARGS_SPECIALIZED]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, { i32, <2 x i32>} %args, i32 0, i32 poison, i32 1, i32 42, i32 1, i32 43)
  call void (...) @use({ i32, <2 x i32>} %args)
  ret void
}

; There is a padding dword before the nested struct, because i64 is 64-bit aligned.
; Check that replacing dword index 4 correctly replaces the nested i32.
define void @NestedStructWithPadding({ i32, { i64, i32 } } %args) {
; CHECK-LABEL: define void @NestedStructWithPadding(
; CHECK-SAME: { i32, { i64, i32 } } [[ARGS:%.*]]) {
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { i32, { i64, i32 } } [[ARGS]], i32 42, 1, 1
; CHECK-NEXT:    call void (...) @use({ i32, { i64, i32 } } [[ARGS_SPECIALIZED]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, { i32, { i64, i32 } } %args, i32 0, i32 poison, i32 0, i32 poison, i32 0, i32 poison, i32 0, i32 poison, i32 1, i32 42, i32 0, i32 poison)
  call void (...) @use({ i32 , { i64, i32 } } %args)
  ret void
}

define void @NestedAll({ i32, [ 2 x { i32, <2 x i32> } ] } %args) {
; CHECK-LABEL: define void @NestedAll(
; CHECK-SAME: { i32, [2 x { i32, <2 x i32> }] } [[ARGS:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = extractvalue { i32, [2 x { i32, <2 x i32> }] } [[ARGS]], 1, 1, 1
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x i32> [[TMP1]], i32 42, i64 1
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { i32, [2 x { i32, <2 x i32> }] } [[ARGS]], <2 x i32> [[TMP2]], 1, 1, 1
; CHECK-NEXT:    call void (...) @use({ i32, [2 x { i32, <2 x i32> }] } [[ARGS_SPECIALIZED]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 0, { i32, [ 2 x { i32, <2 x i32> } ] } %args, i32 0, i32 poison, i32 0, i32 poison, i32 0, i32 poison, i32 0, i32 poison, i32 0, i32 poison, i32 0, i32 poison, i32 1, i32 42)
  call void (...) @use({ i32, [ 2 x { i32, <2 x i32> } ] } %args)
  ret void
}

define void @FailSmallTypes(i1 %arg0, i8 %arg1, i16 %arg2, half %arg3) {
; CHECK-LABEL: define void @FailSmallTypes(
; CHECK-SAME: i1 [[ARG0:%.*]], i8 [[ARG1:%.*]], i16 [[ARG2:%.*]], half [[ARG3:%.*]]) {
; CHECK-NEXT:    call void (...) @use(i1 [[ARG0]], i8 [[ARG1]], i16 [[ARG2]], half [[ARG3]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 3, i1 %arg0, i32 1, i32 1)
  call void @specialize(i32 3, i8 %arg1, i32 1, i32 1)
  call void @specialize(i32 3, i16 %arg2, i32 1, i32 1)
  call void @specialize(i32 3, half %arg3, i32 1, i32 1)
  call void (...) @use(i1 %arg0, i8 %arg1, i16 %arg2, half %arg3)
  ret void
}

; These are not supported yet, but we could add support later. It would require splitting constant values though.
define void @FailSmallTypesInAggregates(<2 x i16> %arg0, [2 x i16] %arg1) {
; CHECK-LABEL: define void @FailSmallTypesInAggregates(
; CHECK-SAME: <2 x i16> [[ARG0:%.*]], [2 x i16] [[ARG1:%.*]]) {
; CHECK-NEXT:    call void (...) @use(<2 x i16> [[ARG0]], [2 x i16] [[ARG1]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 3, <2 x i16> %arg0, i32 1, i32 1)
  call void @specialize(i32 3, [2 x i16] %arg1, i32 1, i32 1)
  call void (...) @use(<2 x i16> %arg0, [2 x i16] %arg1)
  ret void
}

; Test that replacing into the storage of a misaligned dword-sized scalar fails
; Replacing the first float succeeds, because it is dword-aligned, the second replacement should fail.
define void @FailMisalignedDwordScalar({ float, i16, float, float, i16 } %args) {
; CHECK-LABEL: define void @FailMisalignedDwordScalar(
; CHECK-SAME: { float, i16, float, float, i16 } [[ARGS:%.*]]) {
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { float, i16, float, float, i16 } [[ARGS]], float 0x36F5000000000000, 0
; CHECK-NEXT:    call void (...) @use({ float, i16, float, float, i16 } [[ARGS_SPECIALIZED]])
; CHECK-NEXT:    ret void
;
  call void @specialize(i32 3, { float, i16, float, float, i16 } %args, i32 1, i32 42, i32 0, i32 poison, i32 1, i32 43, i32 0, i32 poison)
  call void (...) @use({ float, i16, float, float, i16 } %args)
  ret void
}

; Specialize a value in control flow, testing that we insert instructions at the correct place.
define void @ControlFlow([2 x i32] %arg0, i1 %arg1, i1 %arg2) {
; CHECK-LABEL: define void @ControlFlow(
; CHECK-SAME: [2 x i32] [[ARG0:%.*]], i1 [[ARG1:%.*]], i1 [[ARG2:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[ARG1]], label [[LOOP:%.*]], label [[EXIT:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[LOOPDEP:%.*]] = phi [2 x i32] [ [[ARG0]], [[ENTRY:%.*]] ], [ [[INSERTED_SPECIALIZED:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[EXTRACT:%.*]] = extractvalue [2 x i32] [[LOOPDEP]], 0
; CHECK-NEXT:    [[INCR:%.*]] = add i32 [[EXTRACT]], 1
; CHECK-NEXT:    [[INSERTED:%.*]] = insertvalue [2 x i32] [[LOOPDEP]], i32 [[INCR]], 0
; CHECK-NEXT:    [[INSERTED_SPECIALIZED]] = insertvalue [2 x i32] [[INSERTED]], i32 42, 1
; CHECK-NEXT:    call void (...) @use([2 x i32] [[INSERTED_SPECIALIZED]])
; CHECK-NEXT:    br i1 [[ARG2]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br i1 %arg1, label %loop, label %exit
loop:
  %loopdep = phi [2 x i32] [ %arg0, %entry ], [ %inserted, %loop ]
  %extract = extractvalue [2 x i32] %loopdep, 0
  %incr = add i32 %extract, 1
  %inserted = insertvalue [2 x i32] %loopdep, i32 %incr, 0
  call void @specialize(i32 0, [2 x i32] %inserted, i32 0, i32 poison, i32 1, i32 42)
  call void (...) @use([2 x i32] %inserted)
  br i1 %arg2, label %loop, label %exit
exit:
  ret void
}
