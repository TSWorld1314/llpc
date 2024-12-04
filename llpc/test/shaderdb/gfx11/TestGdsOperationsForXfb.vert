// Test to check GDS operations that are required to support GFX11 transform feedback. Also, check
// ds_ordered_count is followed by s_waitcnt lgkmcnt(0), which is required by HW on GFX11.

// RUN: amdllpc %gfxip %s -v | FileCheck -check-prefix=SHADERTEST %s

// SHADERTEST-LABEL: {{^// LLPC}} final pipeline module info
// SHADERTEST: .prepareXfb:
// SHADERTEST: [[orderedWaveId0:%.*]] = inttoptr i32 %orderedWaveId to ptr addrspace(2)
// SHADERTEST-NEXT: call i32 @llvm.amdgcn.ds.ordered.add(ptr addrspace(2) [[orderedWaveId0]], i32 0, i32 0, i32 0, i1 false, i32 16777216, i1 false, i1 false)
// SHADERTEST: call i32 @llvm.amdgcn.ds.add.gs.reg.rtn.i32(i32 %{{.*}}, i32 0)
// SHADERTEST-NEXT: call i32 @llvm.amdgcn.ds.add.gs.reg.rtn.i32(i32 0, i32 4)
// SHADERTEST: [[orderedWaveId1:%.*]] = inttoptr i32 %orderedWaveId to ptr addrspace(2)
// SHADERTEST-NEXT: call i32 @llvm.amdgcn.ds.ordered.add(ptr addrspace(2) [[orderedWaveId1]], i32 %{{.*}}, i32 0, i32 0, i1 false, i32 16777217, i1 true, i1 true)

// SHADERTEST-LABEL: {{^// LLPC}} final ELF info
// SHADERTEST: ds_ordered_count {{v[0-9]*}}, {{v[0-9]*}} gds
// SHADERTEST: s_waitcnt lgkmcnt(0)
// SHADERTEST: ds_add_gs_reg_rtn {{v[[0-9]*:[0-9]*]}}, {{v[0-9]*}} gds                                                                             ; D9EA0000 03000300
// SHADERTEST: s_waitcnt lgkmcnt(0)                                                                                         ; BF89FC07
// SHADERTEST: ds_add_gs_reg_rtn {{v[[0-9]*:[0-9]*]}}, {{v[0-9]*}} offset:4 gds                                                                    ; D9EA0004 04000600
// SHADERTEST: s_waitcnt lgkmcnt(0)
// SHADERTEST: ds_ordered_count {{v[0-9]*}}, {{v[0-9]*}} offset:772 gds
// SHADERTEST: s_waitcnt lgkmcnt(0)

#version 450 core

layout(location = 0, xfb_buffer = 0, xfb_offset = 0, xfb_stride = 16) out vec4 data0;
layout(location = 1, xfb_buffer = 1, xfb_offset = 0, xfb_stride = 16) out vec4 data1;

void main() {
  data0 = vec4(0.0);
  data1 = vec4(1.0);
}