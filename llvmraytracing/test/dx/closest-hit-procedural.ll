; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
; RUN: opt --verify-each -passes='dxil-cont-intrinsic-prepare,lint,dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,remove-types-metadata' -S %s 2> %t0.stderr | FileCheck -check-prefix=LOWERRAYTRACINGPIPELINE %s
; RUN: opt --verify-each -passes='dxil-cont-intrinsic-prepare,lint,dxil-cont-lgc-rt-op-converter,lint,inline,lint,lower-raytracing-pipeline,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,register-buffer,lint,dxil-cont-post-process,lint,remove-types-metadata' -S %s 2> %t1.stderr | FileCheck -check-prefix=DXILCONTPOSTPROCESS %s
; RUN: count 0 < %t1.stderr

; Check a procedural closest hit shader with hit attributes that does not fit into system data alone

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-p32:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%dx.types.Handle = type { i8* }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.DispatchSystemData = type { <3 x i32> }
%struct.TraversalData = type { %struct.SystemData, %struct.HitData, <3 x float>, <3 x float>, float }
%struct.HitData = type { float, i32 }
%struct.AnyHitTraversalData = type { %struct.TraversalData, %struct.HitData }
%struct.RayPayload = type { <4 x float> }
%struct.HitAttributes = type { <4 x float> }
%dx.types.ResourceProperties = type { i32, i32 }
%struct.RaytracingAccelerationStructure = type { i32 }
%"class.RWTexture2D<vector<float, 4> >" = type { <4 x float> }

@"\01?Scene@@3URaytracingAccelerationStructure@@A" = external constant %dx.types.Handle, align 4
@"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" = external constant %dx.types.Handle, align 4

declare i64 @_cont_GetTraversalAddr() #0

declare i32 @_cont_GetContinuationStackAddr() #0

declare !types !15 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.SystemData*) #0

declare !types !17 void @_cont_SetTriangleHitAttributes(%struct.SystemData*, %struct.BuiltInTriangleIntersectionAttributes) #0

declare !types !18 i1 @_cont_IsEndSearch(%struct.TraversalData*) #0

declare %struct.DispatchSystemData @_cont_Traversal(%struct.TraversalData) #0

declare %struct.DispatchSystemData @_cont_SetupRayGen() #0

declare %struct.AnyHitTraversalData @_AmdAwaitAnyHit(i64, %struct.AnyHitTraversalData, float, i32) #0

declare !types !20 %struct.HitData @_cont_GetCandidateState(%struct.AnyHitTraversalData*) #0

declare !types !22 %struct.HitData @_cont_GetCommittedState(%struct.SystemData*) #0

define i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData* %data) #0 !types !23 {
; LOWERRAYTRACINGPIPELINE-LABEL: define i32 @_cont_GetLocalRootIndex(
; LOWERRAYTRACINGPIPELINE-SAME: ptr [[DATA:%.*]]) #[[ATTR0:[0-9]+]] {
; LOWERRAYTRACINGPIPELINE-NEXT:    ret i32 5
;
; DXILCONTPOSTPROCESS-LABEL: define i32 @_cont_GetLocalRootIndex(
; DXILCONTPOSTPROCESS-SAME: ptr [[DATA:%.*]]) #[[ATTR0:[0-9]+]] {
; DXILCONTPOSTPROCESS-NEXT:    ret i32 5
;
  ret i32 5
}

define void @_cont_TraceRay(%struct.DispatchSystemData* %data, i64 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, float %6, float %7, float %8, float %9, float %10, float %11, float %12, float %13) #0 !types !25 {
  %dis_data = load %struct.DispatchSystemData, %struct.DispatchSystemData* %data, align 4
  %sys_data = insertvalue %struct.SystemData undef, %struct.DispatchSystemData %dis_data, 0
  %trav_data = insertvalue %struct.TraversalData undef, %struct.SystemData %sys_data, 0
  %newdata = call %struct.DispatchSystemData @_cont_Traversal(%struct.TraversalData %trav_data)
  store %struct.DispatchSystemData %newdata, %struct.DispatchSystemData* %data, align 4
  ret void
}

define i1 @_cont_ReportHit(%struct.AnyHitTraversalData* %data, float %t, i32 %hitKind) #0 !types !26 {
  %trav_data = load %struct.AnyHitTraversalData, %struct.AnyHitTraversalData* %data, align 4
  %newdata = call %struct.AnyHitTraversalData @_AmdAwaitAnyHit(i64 3, %struct.AnyHitTraversalData %trav_data, float %t, i32 %hitKind)
  store %struct.AnyHitTraversalData %newdata, %struct.AnyHitTraversalData* %data, align 4
  ret i1 true
}

; Function Attrs: nounwind memory(none)
declare !types !27 i32 @_cont_DispatchRaysIndex(%struct.DispatchSystemData* nocapture readnone, i32) #1

; Function Attrs: nounwind memory(none)
declare !types !27 i32 @_cont_DispatchRaysDimensions(%struct.DispatchSystemData* nocapture readnone, i32) #1

; Function Attrs: nounwind memory(none)
declare !types !28 float @_cont_WorldRayOrigin(%struct.DispatchSystemData* nocapture readnone, i32) #1

; Function Attrs: nounwind memory(none)
declare !types !28 float @_cont_WorldRayDirection(%struct.DispatchSystemData* nocapture readnone, i32) #1

; Function Attrs: nounwind memory(none)
declare !types !29 float @_cont_RayTMin(%struct.DispatchSystemData* nocapture readnone) #1

; Function Attrs: nounwind memory(read)
declare !types !30 float @_cont_RayTCurrent(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*) #2

; Function Attrs: nounwind memory(none)
declare !types !23 i32 @_cont_RayFlags(%struct.DispatchSystemData* nocapture readnone) #1

; Function Attrs: nounwind memory(none)
declare !types !32 i32 @_cont_InstanceIndex(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*) #1

; Function Attrs: nounwind memory(none)
declare !types !32 i32 @_cont_InstanceID(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*) #1

; Function Attrs: nounwind memory(none)
declare !types !32 i32 @_cont_PrimitiveIndex(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*) #1

; Function Attrs: nounwind memory(none)
declare !types !33 float @_cont_ObjectRayOrigin(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*, i32) #1

; Function Attrs: nounwind memory(none)
declare !types !33 float @_cont_ObjectRayDirection(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*, i32) #1

; Function Attrs: nounwind memory(none)
declare !types !34 float @_cont_ObjectToWorld(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*, i32, i32) #1

; Function Attrs: nounwind memory(none)
declare !types !34 float @_cont_WorldToObject(%struct.DispatchSystemData* nocapture readnone, %struct.HitData*, i32, i32) #1

; Function Attrs: nounwind memory(none)
declare !types !35 i32 @_cont_HitKind(%struct.SystemData* nocapture readnone, %struct.HitData*) #1

; Function Attrs: nounwind
define void @ClosestHit(%struct.RayPayload* noalias nocapture %payload, %struct.HitAttributes* nocapture readonly %attr) #3 !types !36 {
; LOWERRAYTRACINGPIPELINE-LABEL: define %struct.DispatchSystemData @ClosestHit(
; LOWERRAYTRACINGPIPELINE-SAME: [[STRUCT_SYSTEMDATA:%.*]] [[TMP0:%.*]]) #[[ATTR4:[0-9]+]] !lgc.rt.shaderstage [[META19:![0-9]+]] !continuation [[META20:![0-9]+]] !continuation.registercount [[META16:![0-9]+]] {
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP2:%.*]] = alloca [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES:%.*]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_SYSTEMDATA]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP3:%.*]] = alloca [[STRUCT_RAYPAYLOAD:%.*]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[HITATTRS:%.*]] = alloca [[STRUCT_HITATTRIBUTES:%.*]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_SYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [[STRUCT_RAYPAYLOAD]], ptr [[TMP3]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP8:%.*]] = load i32, ptr addrspace(20) @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP8]], ptr [[TMP5]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP9:%.*]] = getelementptr inbounds i32, ptr [[TMP5]], i32 1
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP11:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @PAYLOAD, i32 7), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP11]], ptr [[TMP9]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP12:%.*]] = getelementptr inbounds i32, ptr [[TMP9]], i32 1
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP13:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @PAYLOAD, i32 8), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP13]], ptr [[TMP12]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP14:%.*]] = getelementptr inbounds i32, ptr [[TMP9]], i32 2
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP15:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @PAYLOAD, i32 9), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP15]], ptr [[TMP14]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP16:%.*]] = call [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES]] [[_CONT_GETTRIANGLEHITATTRIBUTES:@[a-zA-Z0-9_$\"\\.-]*[a-zA-Z_$\"\\.-][a-zA-Z0-9_$\"\\.-]*]](ptr [[SYSTEM_DATA_ALLOCA]])
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES]] [[TMP16]], ptr [[TMP2]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP17:%.*]] = load i32, ptr [[TMP2]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP17]], ptr [[HITATTRS]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP20:%.*]] = getelementptr inbounds i32, ptr [[HITATTRS]], i32 1
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP21:%.*]] = getelementptr inbounds i32, ptr [[TMP2]], i32 1
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP22:%.*]] = load i32, ptr [[TMP21]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP22]], ptr [[TMP20]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP23:%.*]] = getelementptr inbounds i32, ptr [[HITATTRS]], i32 2
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP24:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds ([[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_3_CLOSESTHIT_IN_PAYLOAD_ATTR_2_I32S:%.*]], ptr addrspace(20) @PAYLOAD, i32 0, i32 0, i32 1), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP24]], ptr [[TMP23]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP25:%.*]] = getelementptr inbounds i32, ptr [[HITATTRS]], i32 3
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP26:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds ([[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_3_CLOSESTHIT_IN_PAYLOAD_ATTR_2_I32S]], ptr addrspace(20) @PAYLOAD, i32 0, i32 0, i32 2), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP26]], ptr [[TMP25]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP27:%.*]] = getelementptr inbounds [[STRUCT_RAYPAYLOAD]], ptr [[TMP3]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP30:%.*]] = load i32, ptr [[TMP27]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP30]], ptr addrspace(20) @PAYLOAD, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP31:%.*]] = getelementptr inbounds i32, ptr [[TMP27]], i32 1
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP33:%.*]] = load i32, ptr [[TMP31]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP33]], ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @PAYLOAD, i32 7), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP34:%.*]] = getelementptr inbounds i32, ptr [[TMP31]], i32 1
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP35:%.*]] = load i32, ptr [[TMP34]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP35]], ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @PAYLOAD, i32 8), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP36:%.*]] = getelementptr inbounds i32, ptr [[TMP31]], i32 2
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP37:%.*]] = load i32, ptr [[TMP36]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP37]], ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @PAYLOAD, i32 9), align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP38:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP39:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[TMP38]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    ret [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP39]], !continuation.registercount [[META16]]
;
; DXILCONTPOSTPROCESS-LABEL: define void @ClosestHit(
; DXILCONTPOSTPROCESS-SAME: i32 [[CSPINIT:%.*]], i64 [[RETURNADDR:%.*]], [[STRUCT_SYSTEMDATA:%.*]] [[TMP0:%.*]]) #[[ATTR1:[0-9]+]] !lgc.rt.shaderstage [[META18:![0-9]+]] !continuation [[META19:![0-9]+]] !continuation.registercount [[META16:![0-9]+]] !continuation.state [[META14:![0-9]+]] {
; DXILCONTPOSTPROCESS-NEXT:  AllocaSpillBB:
; DXILCONTPOSTPROCESS-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_SYSTEMDATA]], align 8
; DXILCONTPOSTPROCESS-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; DXILCONTPOSTPROCESS-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; DXILCONTPOSTPROCESS-NEXT:    [[DOTFCA_0_0_EXTRACT:%.*]] = extractvalue [[STRUCT_SYSTEMDATA]] [[TMP0]], 0, 0
; DXILCONTPOSTPROCESS-NEXT:    [[DOTFCA_0_0_GEP:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0, i32 0
; DXILCONTPOSTPROCESS-NEXT:    store <3 x i32> [[DOTFCA_0_0_EXTRACT]], ptr [[DOTFCA_0_0_GEP]], align 4
; DXILCONTPOSTPROCESS-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; DXILCONTPOSTPROCESS-NEXT:    [[TMP2:%.*]] = load i32, ptr addrspace(20) @REGISTERS, align 4
; DXILCONTPOSTPROCESS-NEXT:    [[TMP3:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @REGISTERS, i32 7), align 4
; DXILCONTPOSTPROCESS-NEXT:    [[TMP4:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @REGISTERS, i32 8), align 4
; DXILCONTPOSTPROCESS-NEXT:    [[TMP5:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @REGISTERS, i32 9), align 4
; DXILCONTPOSTPROCESS-NEXT:    [[TMP6:%.*]] = call [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES:%.*]] [[_CONT_GETTRIANGLEHITATTRIBUTES:@[a-zA-Z0-9_$\"\\.-]*[a-zA-Z_$\"\\.-][a-zA-Z0-9_$\"\\.-]*]](ptr [[SYSTEM_DATA_ALLOCA]])
; DXILCONTPOSTPROCESS-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_BUILTINTRIANGLEINTERSECTIONATTRIBUTES]] [[TMP6]], 0
; DXILCONTPOSTPROCESS-NEXT:    [[DOTSROA_02_0_VEC_EXTRACT:%.*]] = extractelement <2 x float> [[DOTFCA_0_EXTRACT]], i32 0
; DXILCONTPOSTPROCESS-NEXT:    [[TMP7:%.*]] = bitcast float [[DOTSROA_02_0_VEC_EXTRACT]] to i32
; DXILCONTPOSTPROCESS-NEXT:    [[DOTSROA_02_4_VEC_EXTRACT:%.*]] = extractelement <2 x float> [[DOTFCA_0_EXTRACT]], i32 1
; DXILCONTPOSTPROCESS-NEXT:    [[TMP8:%.*]] = bitcast float [[DOTSROA_02_4_VEC_EXTRACT]] to i32
; DXILCONTPOSTPROCESS-NEXT:    [[TMP9:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds ([[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_3_CLOSESTHIT_IN_PAYLOAD_ATTR_2_I32S:%.*]], ptr addrspace(20) @REGISTERS, i32 0, i32 0, i32 1), align 4
; DXILCONTPOSTPROCESS-NEXT:    [[TMP10:%.*]] = load i32, ptr addrspace(20) getelementptr inbounds ([[STRUCT_RAYPAYLOAD_ATTR_MAX_8_I32S_LAYOUT_3_CLOSESTHIT_IN_PAYLOAD_ATTR_2_I32S]], ptr addrspace(20) @REGISTERS, i32 0, i32 0, i32 2), align 4
; DXILCONTPOSTPROCESS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; DXILCONTPOSTPROCESS-NEXT:    store i32 [[TMP2]], ptr addrspace(20) @REGISTERS, align 4
; DXILCONTPOSTPROCESS-NEXT:    store i32 [[TMP3]], ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @REGISTERS, i32 7), align 4
; DXILCONTPOSTPROCESS-NEXT:    store i32 [[TMP4]], ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @REGISTERS, i32 8), align 4
; DXILCONTPOSTPROCESS-NEXT:    store i32 [[TMP5]], ptr addrspace(20) getelementptr inbounds (i32, ptr addrspace(20) @REGISTERS, i32 9), align 4
; DXILCONTPOSTPROCESS-NEXT:    [[TMP11:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; DXILCONTPOSTPROCESS-NEXT:    [[DOTFCA_0_GEP:%.*]] = getelementptr inbounds [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[TMP11]], i32 0, i32 0
; DXILCONTPOSTPROCESS-NEXT:    [[DOTFCA_0_LOAD:%.*]] = load <3 x i32>, ptr [[DOTFCA_0_GEP]], align 4
; DXILCONTPOSTPROCESS-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, <3 x i32> [[DOTFCA_0_LOAD]], 0
; DXILCONTPOSTPROCESS-NEXT:    [[TMP12:%.*]] = load i32, ptr [[CSP]], align 4
; DXILCONTPOSTPROCESS-NEXT:    call void (i64, ...) @continuation.continue(i64 [[RETURNADDR]], i32 [[TMP12]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT]]), !continuation.registercount [[META16]]
; DXILCONTPOSTPROCESS-NEXT:    unreachable
;
  ret void
}

; Function Attrs: nounwind memory(read)
declare !types !39 void @dx.op.traceRay.struct.RayPayload(i32, %dx.types.Handle, i32, i32, i32, i32, i32, float, float, float, float, float, float, float, float, %struct.RayPayload*) #2

; Function Attrs: nounwind memory(none)
declare %dx.types.Handle @dx.op.annotateHandle(i32, %dx.types.Handle, %dx.types.ResourceProperties) #1

declare %dx.types.Handle @dx.op.createHandleForLib.dx.types.Handle(i32, %dx.types.Handle)

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare !types !40 void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare !types !40 void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #4

attributes #0 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="0" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind memory(none) }
attributes #2 = { nounwind memory(read) }
attributes #3 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="0" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }

!llvm.ident = !{!0}
!dx.version = !{!1}
!dx.valver = !{!1}
!dx.shaderModel = !{!2}
!dx.resources = !{!3}
!dx.typeAnnotations = !{}
!dx.entryPoints = !{!10, !12}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final)"}
!1 = !{i32 1, i32 6}
!2 = !{!"lib", i32 6, i32 6}
!3 = !{!4, !7, null, null}
!4 = !{!5}
!5 = !{i32 0, %struct.RaytracingAccelerationStructure* bitcast (%dx.types.Handle* @"\01?Scene@@3URaytracingAccelerationStructure@@A" to %struct.RaytracingAccelerationStructure*), !"Scene", i32 0, i32 0, i32 1, i32 16, i32 0, !6}
!6 = !{i32 0, i32 4}
!7 = !{!8}
!8 = !{i32 0, %"class.RWTexture2D<vector<float, 4> >"* bitcast (%dx.types.Handle* @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" to %"class.RWTexture2D<vector<float, 4> >"*), !"RenderTarget", i32 0, i32 0, i32 1, i32 2, i1 false, i1 false, i1 false, !9}
!9 = !{i32 0, i32 9}
!10 = !{null, !"", null, !3, !11}
!11 = !{i32 0, i64 65536}
!12 = !{void (%struct.RayPayload*, %struct.HitAttributes*)* @ClosestHit, !"ClosestHit", null, null, !13}
!13 = !{i32 8, i32 10, i32 5, !14}
!14 = !{i32 0}
!15 = !{!"function", %struct.BuiltInTriangleIntersectionAttributes poison, !16}
!16 = !{i32 0, %struct.SystemData poison}
!17 = !{!"function", !"void", !16, %struct.BuiltInTriangleIntersectionAttributes poison}
!18 = !{!"function", i1 poison, !19}
!19 = !{i32 0, %struct.TraversalData poison}
!20 = !{!"function", %struct.HitData poison, !21}
!21 = !{i32 0, %struct.AnyHitTraversalData poison}
!22 = !{!"function", %struct.HitData poison, !16}
!23 = !{!"function", i32 poison, !24}
!24 = !{i32 0, %struct.DispatchSystemData poison}
!25 = !{!"function", !"void", !24, i64 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, float poison, float poison, float poison, float poison, float poison, float poison, float poison, float poison}
!26 = !{!"function", i1 poison, !21, float poison, i32 poison}
!27 = !{!"function", i32 poison, !24, i32 poison}
!28 = !{!"function", float poison, !24, i32 poison}
!29 = !{!"function", float poison, !24}
!30 = !{!"function", float poison, !24, !31}
!31 = !{i32 0, %struct.HitData poison}
!32 = !{!"function", i32 poison, !24, !31}
!33 = !{!"function", float poison, !24, !31, i32 poison}
!34 = !{!"function", float poison, !24, !31, i32 poison, i32 poison}
!35 = !{!"function", i32 poison, !16, !31}
!36 = !{!"function", !"void", !37, !38}
!37 = !{i32 0, %struct.RayPayload poison}
!38 = !{i32 0, %struct.HitAttributes poison}
!39 = !{!"function", !"void", i32 poison, %dx.types.Handle poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, float poison, float poison, float poison, float poison, float poison, float poison, float poison, float poison, !37}
!40 = !{!"function", !"void", i64 poison, !41}
!41 = !{i32 0, i8 poison}