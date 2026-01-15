Shader "Hidden/HM/KawaseBlur" {
	Properties {
		_MainTex ("Main Texture", 2D) = "" {}
	}
	SubShader {
		Pass {
			Name "ALPHAWEIGHTS"
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 57789
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float _WeightScale;
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
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.x = saturate(tmp0.w * _WeightScale);
                o.sv_target.xyz = tmp0.xyz * tmp1.xxx;
                o.sv_target.w = tmp0.w;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "KAWASEBLUR"
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 110652
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Offset;
			float _Boost;
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
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0 = inp.texcoord.xyxy + _Offset;
                tmp1 = tex2D(_MainTex, tmp0.xy);
                tmp0 = tex2D(_MainTex, tmp0.zw);
                tmp2 = inp.texcoord.xyxy - _Offset;
                tmp3 = tex2D(_MainTex, tmp2.xy);
                tmp2 = tex2D(_MainTex, tmp2.zw);
                tmp1.xyz = tmp1.xyz + tmp3.xyz;
                tmp0.xyz = tmp0.xyz + tmp1.xyz;
                tmp0.xyz = tmp2.xyz + tmp0.xyz;
                tmp0.w = _Boost + 0.25;
                o.sv_target.xyz = saturate(tmp0.www * tmp0.xyz);
                o.sv_target.w = saturate(0.0);
                return o;
			}
			ENDCG
		}
		Pass {
			Name "KAWASEBLURADD"
			Blend One One, One One
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 185243
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Offset;
			float _Boost;
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
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0 = inp.texcoord.xyxy + _Offset;
                tmp1 = tex2D(_MainTex, tmp0.xy);
                tmp0 = tex2D(_MainTex, tmp0.zw);
                tmp2 = inp.texcoord.xyxy - _Offset;
                tmp3 = tex2D(_MainTex, tmp2.xy);
                tmp2 = tex2D(_MainTex, tmp2.zw);
                tmp1.xyz = tmp1.xyz + tmp3.xyz;
                tmp0.xyz = tmp0.xyz + tmp1.xyz;
                tmp0.xyz = tmp2.xyz + tmp0.xyz;
                tmp0.w = _Boost + 0.25;
                o.sv_target.xyz = saturate(tmp0.www * tmp0.xyz);
                o.sv_target.w = saturate(0.0);
                return o;
			}
			ENDCG
		}
		Pass {
			Name "KAWASEBLURWITHALPHAWEIGHTS"
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 199742
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Offset;
			float _Boost;
			float _WeightScale;
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
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0 = inp.texcoord.xyxy - _Offset;
                tmp1 = tex2D(_MainTex, tmp0.xy);
                tmp0 = tex2D(_MainTex, tmp0.zw);
                tmp1.w = saturate(tmp1.w * _WeightScale);
                tmp1.xyz = tmp1.www * tmp1.xyz;
                tmp2 = inp.texcoord.xyxy + _Offset;
                tmp3 = tex2D(_MainTex, tmp2.xy);
                tmp2 = tex2D(_MainTex, tmp2.zw);
                tmp1.w = saturate(tmp3.w * _WeightScale);
                tmp1.xyz = tmp3.xyz * tmp1.www + tmp1.xyz;
                tmp1.w = saturate(tmp2.w * _WeightScale);
                tmp1.xyz = tmp2.xyz * tmp1.www + tmp1.xyz;
                tmp0.w = saturate(tmp0.w * _WeightScale);
                tmp0.xyz = tmp0.xyz * tmp0.www + tmp1.xyz;
                tmp0.w = _Boost + 0.25;
                o.sv_target.xyz = saturate(tmp0.www * tmp0.xyz);
                o.sv_target.w = saturate(0.0);
                return o;
			}
			ENDCG
		}
	}
}