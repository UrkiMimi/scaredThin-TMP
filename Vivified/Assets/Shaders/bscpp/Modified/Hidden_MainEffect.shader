Shader "Hidden/MainEffect" {
	Properties {
		[HideInInspector] _MainTex ("Main Texture", 2D) = "white" {}
		[HideInInspector] _NoiseTex ("Noise Texture", 2D) = "white" {}
	}
	SubShader {
		Pass {
			Name "MAIN"
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 14379
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature STEREO_ENABLED
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float4 projPos : TEXCOORD2;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float2 _MainTex_TexelSize;
			float4 _GlobalBlueNoiseParams;
			// $Globals ConstantBuffers for Fragment Shader
			float _BaseColorBoost;
			float _BaseColorBoostThreshold;
			float _BloomIntensity;
			float _FadeAmount;
			float _GlobalRandomValue;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _BloomTex;
			sampler2D _CameraDepthTexture;
			sampler2D _GlobalBlueNoiseTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.yzw = v.texcoord.xyx * _MainTex_ST.xyx + _MainTex_ST.zwz;
                tmp1.x = 1.0 - tmp0.z;
                o.texcoord1.y = tmp0.x ? tmp1.x : tmp0.z;
                o.texcoord1 = tmp0.yzw;
				o.projPos = ComputeScreenPos (o.position);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
				float4 blueNoise;
				float2 sceneUVs = (inp.projPos.xy / inp.projPos.w);
				float2 uvInvert = sceneUVs;
				#ifdef STEREO_ENABLED
					#ifdef UNITY_UV_STARTS_AT_TOP
					{
						uvInvert.y = 1 - uvInvert.y;
					}
					#else
					{
						//uvInvert.y = 1 - uvInvert.y;
					}
					#endif
				#endif
                tmp0 = tex2D(_MainTex, sceneUVs);
                tmp1.x = saturate(tmp0.w * _BaseColorBoost + -_BaseColorBoostThreshold);
                tmp2 = float4(1.0, 1.0, 1.0, 1.0) - tmp0;
                tmp0 = tmp1.xxxx * tmp2 + tmp0;
                tmp1 = tex2D(_BloomTex, uvInvert);
                tmp0 = tmp1 * _BloomIntensity.xxxx + tmp0;
                tmp0.xyz = saturate(tmp0.xyz);
				//bluenoise
				//blueNoise = tex2D(_GlobalBlueNoiseTex, _GlobalBlueNoiseParams);
				//tmp0 -= blueNoise;
                o.sv_target.w = tmp0.w;
                o.sv_target.xyz = tmp0.xyz * _FadeAmount.xxxx;
                return o;
			}
			ENDCG
		}
	}
}