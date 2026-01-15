Shader "Custom/Urki/ParametricBoxFakeGlow" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_AlphaMulti ("Alpha Multiplier", Float) = 1
		[Space] _MainTex ("Main Texture", 2D) = "white" {}
		[Space] _FogStartOffset ("Fog Start Offset", Float) = 1
		_FogScale ("Fog Scale", Float) = 1
		_SizeParams ("Size Parameters", Vector) = (0,0,0,0)
		_WhiteBoost ("White Boost", Float) = 1
		[Toggle(ENABLE_CUTOUT)] _EnableCutout ("Enable Cutout", Float) = 0
		[Space] [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcFactor ("Blend Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstFactor ("Blend Dst", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrcFactorA ("Blend Src Factor A", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDstFactorA ("Blend Dst Factor A", Float) = 1
		[HideInInspector]_Cutout ("Cutout", Float) = 1

	}
	SubShader {
		Tags { "DisableBatching" = "true" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			Tags { "DisableBatching" = "true" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend [_BlendSrcFactor] [_BlendDstFactor] , [_BlendSrcFactorA] [_BlendSrcFactorA]
			ZWrite Off
			Cull Off
			GpuProgramID 16338
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature MAIN_EFFECT_ENABLED
			#pragma shader_feature ENABLE_CENTER_CUTOUT_GLOBAL
			#pragma shader_feature ENABLE_CUTOUT
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float3 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float _StereoCameraEyeOffset;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _CustomFogColor;
			float _CustomFogColorMultiplier;
			float _CustomFogAttenuation;
			float _CustomFogOffset;
			float _FogStartOffset;
			float _FogScale;
            float4 _SizeParams;
            float _Cutout;
			float _AlphaMulti;
			float _WhiteBoost;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(Props)
				float4 _Color;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
				float4 fogVal;
				float4 worldPos;
                tmp0.xyz = v.vertex.xyz > float3(0.0, 0.0, 0.0);
                tmp1.xyz = v.vertex.xyz < float3(0.0, 0.0, 0.0);
                tmp0.xyz = tmp1.xyz - tmp0.xyz;
                tmp0.xyz = floor(tmp0.xyz);
                tmp1.xyz = v.vertex.xyz + tmp0.xyz;
                tmp1.xyz = tmp1.xyz + tmp1.xyz;
                tmp1.xyz = tmp1.xyz * -_SizeParams.www;
                tmp1.xyz = tmp1.xyz / _SizeParams.xyz;
                tmp0.xyz = tmp0.xyz + tmp1.xyz;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp0.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp2 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp2 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp2;
                tmp2 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp2;
                tmp1 = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp2;
				#ifdef ENABLE_CUTOUT
					tmp1 *= (1 - _Cutout);
				#endif
                o.position = tmp1;
				
				// fog 
				o.worldPos = mul(unity_ObjectToWorld, tmp1);
		        o.texcoord1.xyz = tmp0.xyz;
                o.texcoord2.xy = v.texcoord.xy;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 glowTex;
                float dumbFog;
				float glowMap;
				glowTex = tex2D(_MainTex, inp.texcoord2.xy);
				glowTex.a *= _AlphaMulti;
				#ifdef MAIN_EFFECT_ENABLED
					glowTex = (0,0,0,0);
				#endif
				//Glow map part
				glowMap = ( clamp(glowTex.a , _WhiteBoost, 1.0) - _WhiteBoost ) / _WhiteBoost;
				glowTex = (glowTex.a * _Color) + glowMap;

				// fog
				float3 fogDistance = inp.worldPos - _WorldSpaceCameraPos;
				float fogIntensity = max(sqrt(dot(fogDistance, fogDistance)) - _FogStartOffset, 0);
				fogIntensity = min(max(fogIntensity * _FogScale + -_CustomFogOffset, 0), 9999);
				fogIntensity = (-fogIntensity * _CustomFogAttenuation) * 1.44269502;
				fogIntensity = 1 - max(1 - exp2(fogIntensity), 0);
				
				//multiply fog with color 
				glowTex *= fogIntensity;
				#ifdef ENABLE_CUTOUT
					glowTex.a *= (1 - _Cutout);
				#endif

				// pause Cutout
				#ifdef ENABLE_CENTER_CUTOUT_GLOBAL
					glowTex = 0;
				#endif
                o.sv_target = glowTex * (1 - _Cutout);
                return o;
			}
			ENDCG
		}
	}
}