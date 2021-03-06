//
//  Image.metal
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <simd/simd.h>
#import "../../MCShaderTypes.h"
#import "../Shader.metal"

using namespace metal;

namespace primitive {
	vertex ImageColorInOut vertex_primitive_image(device float4 *positions [[ buffer(MCVertexIndex) ]],
												  device float2 *texCoords [[ buffer(MCTexCoord) ]],
												  const device float4x4 &projectionMat [[buffer(MCProjectionMatrixIndex)]],
												  const device float4x4 &objMat [[buffer(30)]],
												  uint vid [[ vertex_id ]])
	{
		float4x4 mat = projectionMat * objMat;
		
		ImageColorInOut out;
		out.position = mat * positions[vid];
		out.texCoords = texCoords[vid];
		return out;
	}
	
	fragment float4 fragment_primitive_image(ImageColorInOut in [[ stage_in ]],
											 texture2d<float> texture [[ texture(0) ]])
	{
		constexpr sampler colorSampler;
		float4 color = texture.sample(colorSampler, in.texCoords);
		//return float4(color.r, color.g, color.b, color.a * 0.5);
		return color;
	}
}
