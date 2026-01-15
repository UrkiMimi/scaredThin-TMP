Shader "Custom/Urki/ScreenDisplacement" {
	Properties {
		_MainTex ("Displacement Texture", 2D) = "white" {}
		_DisplacementStrength ("Displacement Strength", Float) = 0.01
		[Toggle(_DISPLACEMENT_IN_PIXELS)] _DisplacementInPixels ("Displacement In Pixels", Float) = 0
		[Space] [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("CullMode", Float) = 0
		[Space] [Toggle(_ENABLE_INSTANCED_COLOR)] _EnableInstancedColor ("Enable Instanced Color", Float) = 0
		_TintColor ("Tint Color", Color) = (1,1,1,1)
[MaterialToggle] _CustomColors("Custom Colors", Float) = 0
		_AddColorIntensity ("Add Color Intensity", Float) = 0
		[Space] [Toggle(_SCROLL_UV)] _ScrollUV ("Scroll UV", Float) = 0
		_ScrollUVVelocity ("Scroll UV Velocity", Vector) = (0,0,0,0)
		[Space] [Toggle(_FADE_Z)] _FadeZ ("Fade Z", Float) = 0
		_FadeZThreshold ("Fade Z Threshold", Float) = -1
		_FadeZWidth ("Fade Z Width", Float) = 3
		[Space] [Toggle(_ENABLE_FOG)] _EnableFog ("Enable Fog", Float) = 0
		_FogStartOffset ("Fog Start Offset", Float) = 0
		_FogScale ("Fog Scale", Float) = 1
		[Space] [Toggle(_ZWRITE)] _ZWrite ("Z Write", Float) = 0
		[Space] [Toggle(_CLIP_LOW_ALPHA)] _ClipLowAlpha ("Clip Low Alpha", Float) = 1
		[Space] [Toggle(_SOFT_EDGES)] _SoftEdges ("Soft Edges", Float) = 1
		_SoftFactor ("Soft Factor", Range(0, 5)) = 0
		[Space] [Toggle(_VIEW_ANGLE_AFFECTS_DISTORTION)] _ViewAngleAffectsDistortion ("View Angle Affects Distortion", Float) = 1
		_ViewAngleDistortionParam ("View Angle Distortion Param", Float) = 4
		[Space] [Toggle(_USE_DISTORTED_TEXTURE_ONLY)] _UseDistortedTextureOnly ("Use Distorted Texture Only", Float) = 0
		[Space] [Toggle(_USE_MONO_SCREEN_TEXTURE)] _UseMonoScreenTexture ("Use Mono Screen Texture", Float) = 0
		[Space] [Toggle(_ENABLE_CUTOUT)] _EnableCutout ("Enable Cutout", Float) = 0
		_CutoutTexScale ("Cutout Texture Scale", Float) = 1
		[PerRendererData] _CutoutTexOffset ("Cutout Texture Offset", Vector) = (0,0,0,0)
		[PerRendererData] _Cutout ("Cutout", Range(0, 1)) = 0
		[Space] [Toggle(_ENABLE_CENTER_CUTOUT)] _EnableCenterCutout ("Enable Center Cutout", Float) = 0
	}
	SubShader {
		Tags { "DisableBatching" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
		GrabPass {
			"_GrabTexture2"
		}
		Pass {
			Tags { "DisableBatching" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
			ZWrite Off
			Cull Back
			GpuProgramID 24705
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature ENABLE_QUEST_OPTIMIZATIONS
			struct VertexInput {
                float4 vertex : POSITION;
            };
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
                float4 projPos : TEXCOORD4;
				float3 texcoord3 : TEXCOORD3;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float _DisplacementStrength;
                        float4 _TintColor;
			float _AddColorIntensity;
			float4 _ScrollUVVelocity;
			float _UseDistortedTextureOnly;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			uniform sampler2D _BloomPrePassTexture;
			sampler2D _GrabTexture2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord3.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                tmp0 = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.position = UnityObjectToClipPos( v.vertex );
				o.projPos = ComputeScreenPos (o.position);
				COMPUTE_EYEDEPTH(o.projPos.z);
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord1 = v.color;
                tmp1.xyz = tmp0.xwy * float3(0.5, 0.5, -0.5);
                o.texcoord2.zw = tmp0.zw;
                o.texcoord2.xy = tmp1.yy + tmp1.xz;
                return o;
			}
			// Keywords: 
			
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
				float2 tmp3;
				float2 UVTime;
				float2 sceneUVs = (inp.projPos.xy / inp.projPos.w);
				#ifdef UNITY_UV_STARTS_AT_TOP
				{
					tmp3 = sceneUVs;
				}
				#else
				{
					tmp3 = sceneUVs;
					tmp3.y = 1 - tmp3.y;
				}
				#endif
				
				UVTime.x = _ScrollUVVelocity.x * _Time;
				UVTime.y = _ScrollUVVelocity.y * _Time;
                tmp0 = tex2D(_MainTex, (inp.texcoord.xy + UVTime));
                tmp0.xy = tmp0.xy - float2(0.5, 0.5);
                tmp0.z = tmp0.w * inp.texcoord1.w;
                tmp0.z = tmp0.z * _TintColor.w;
                tmp0.z = tmp0.z * 1.01 + -0.01;
				#ifdef ENABLE_QUEST_OPTIMIZATIONS
				{
					tmp0.xy = tmp0.xy * (_DisplacementStrength.xx * 4);
                	tmp1.xy = (inp.texcoord2.xy / inp.texcoord2.w);
                	tmp0.xy = tmp3.xy + tmp0.xy * float2(0.001, 0.001);
                	tmp1 = tex2D(_BloomPrePassTexture, tmp1.xy);
                	tmp2 = tex2D(_BloomPrePassTexture, tmp0.xy);
					tmp1.xyz = (tmp1.x + tmp1.y + tmp1.z) / 3;
					tmp2.xyz = (tmp2.x + tmp2.y + tmp2.z) / 3;
					tmp1.w = 0;
					tmp2.w = 0;
				}
				#else
				{
					tmp0.xy = tmp0.xy * _DisplacementStrength.xx;
                	tmp1.xy = (inp.texcoord2.xy / inp.texcoord2.w);
                	tmp0.xy = tmp0.xy * float2(0.001, 0.001) + sceneUVs;
                	tmp1 = tex2D(_GrabTexture2, tmp1.xy);
                	tmp2 = tex2D(_GrabTexture2, tmp0.xy);
				}
				#endif
                tmp2 = tmp2 * _TintColor + (_AddColorIntensity * _TintColor * float4(1,1,1,0));
                tmp2 = tmp2 - tmp1;
                o.sv_target = tmp0.zzzz * tmp2 + tmp1;
                return o;
			}
			ENDCG
		}
	}
}