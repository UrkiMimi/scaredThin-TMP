Shader "Hidden/BloomPrePassLine" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader {
		Tags { "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			Tags { "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One One, One One
			BlendOp Max, Max
			ZWrite Off
			Cull Off
			GpuProgramID 45935
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 color : COLOR0;
				float2 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 _VertexTransfromMatrix;
			// $Globals ConstantBuffers for Fragment Shader
			float _PrePassLinesFogDensity;
			float _LineIntensityMultiplier;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                tmp0 = v.vertex.yyyy * _VertexTransfromMatrix._m01_m11_m21_m31;
                tmp0 = _VertexTransfromMatrix._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = _VertexTransfromMatrix._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                o.position = _VertexTransfromMatrix._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                o.color = v.color;
                o.texcoord.xy = v.texcoord.xy;
                o.texcoord1.xyz = v.tangent.xyz / v.tangent.zzz;
                o.texcoord1.w = 1.0 / v.tangent.z;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = 1.0 / inp.texcoord1.w;
                tmp0.xyz = tmp0.xxx * inp.texcoord1.xyz;
                tmp0.x = dot(tmp0.xyz, tmp0.xyz);
                tmp0.x = sqrt(tmp0.x);
                tmp0.x = -tmp0.x * _PrePassLinesFogDensity;
                tmp0.x = tmp0.x * 1.442695;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1 = tmp1 * inp.color;
                tmp0.x = tmp0.x * tmp1.w;
                tmp0.x = tmp0.x * _LineIntensityMultiplier;
                o.sv_target.xyz = tmp0.xxx * tmp1.xyz;
                o.sv_target.w = tmp0.x;
                return o;
			}
			ENDCG
		}
	}
}