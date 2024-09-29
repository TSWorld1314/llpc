// NOTE: Assertions have been autogenerated by tool/update_llpc_test_checks.py UTC_ARGS: --function-signature --check-globals
// RUN: amdllpc -o - -gfxip 10.1 -emit-lgc %s | FileCheck -check-prefixes=CHECK %s
#version 450

out gl_PerVertex
{
    vec4 gl_Position;
    layout(xfb_offset = 0) float gl_PointSize;
};

layout(location = 0) in vec4 pos;
layout(location = 1) in float pointSize;


void main()
{
    gl_Position = pos;
    gl_PointSize = pointSize;
}
// CHECK-LABEL: define {{[^@]+}}@lgc.shader.VS.main
// CHECK-SAME: () local_unnamed_addr #[[ATTR0:[0-9]+]] !spirv.ExecutionModel !10 !lgc.shaderstage !1 !lgc.xfb.state !11 {
// CHECK-NEXT:  .entry:
// CHECK-NEXT:    [[TMP0:%.*]] = call float (...) @lgc.create.read.generic.input.f32(i32 1, i32 0, i32 0, i32 0, i32 0, i32 poison)
// CHECK-NEXT:    [[TMP1:%.*]] = call <4 x float> (...) @lgc.create.read.generic.input.v4f32(i32 0, i32 0, i32 0, i32 0, i32 0, i32 poison)
// CHECK-NEXT:    call void (...) @lgc.create.write.builtin.output(<4 x float> [[TMP1]], i32 0, i32 0, i32 poison, i32 poison)
// CHECK-NEXT:    call void (...) @lgc.create.write.xfb.output(float [[TMP0]], i1 true, i32 1, i32 0, i32 4, i32 0, i32 0)
// CHECK-NEXT:    call void (...) @lgc.create.write.builtin.output(float [[TMP0]], i32 1, i32 0, i32 poison, i32 poison)
// CHECK-NEXT:    ret void
//
//.
// CHECK: attributes #[[ATTR0]] = { alwaysinline nounwind "denormal-fp-math-f32"="preserve-sign" }
// CHECK: attributes #[[ATTR1:[0-9]+]] = { nounwind willreturn memory(read) }
// CHECK: attributes #[[ATTR2:[0-9]+]] = { nounwind }
//.
// CHECK: [[META0:![0-9]+]] = !{!"Vulkan"}
// CHECK: [[META1:![0-9]+]] = !{i32 1}
