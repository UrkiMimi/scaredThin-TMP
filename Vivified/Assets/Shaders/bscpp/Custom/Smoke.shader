// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Smoke"
{
	Properties
	{
		_SmokeIntensity("Smoke Intensity", Float) = 0
		_MainTex("Smoke Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha One , Zero One
		
		CGPROGRAM
		#pragma target 5.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float4 screenPos;
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

		uniform sampler2D _BloomPrePassTexture;
		uniform float _StereoCameraEyeOffset;
		uniform float _CustomFogGammaCorrection;
		uniform float _SmokeIntensity;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 fogcorrection61( float4 input, float offset )
		{
						#ifdef UNITY_UV_STARTS_AT_TOP
						#else
							input.y = 1 - input.y;
						#endif
						#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)
							if (unity_StereoEyeIndex > 0)
							{
								input.x -= 0.5;
								input.x += offset;
							}
							input.x *=2;
						#endif
						return input;
		}


		float4 GammaCorrection47( float4 input, float GammaValue )
		{
			float4 clr = input;
			clr = log2(clr);
			clr *= GammaValue;
			clr = exp2(clr);
			return clr;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 input61 = ase_grabScreenPosNorm;
			float offset61 = _StereoCameraEyeOffset;
			float4 localfogcorrection61 = fogcorrection61( input61 , offset61 );
			float4 input47 = tex2D( _BloomPrePassTexture, localfogcorrection61.xy );
			float GammaValue47 = _CustomFogGammaCorrection;
			float4 localGammaCorrection47 = GammaCorrection47( input47 , GammaValue47 );
			o.Emission = localGammaCorrection47.xyz;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Alpha = ( i.vertexColor.a * ( 1.0 - 0.0 ) * _SmokeIntensity * tex2D( _MainTex, uv_MainTex ).r );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;1492.897;357.6046;1;True;False
Node;AmplifyShaderEditor.GrabScreenPosition;37;-755.9978,-147.2511;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-825.7062,36.50967;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;61;-480.0881,-119.719;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;17;-148,2;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-232,355;Inherit;False;Property;_SmokeIntensity;Smoke Intensity;3;0;Create;True;0;0;0;False;0;False;0;1E+13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-154.6849,-258.254;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-251,-179;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;1;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;38;-272.6904,161.7245;Inherit;True;Property;_MainTex;Smoke Texture;6;0;Create;False;0;0;0;False;0;False;-1;None;a3490979d075e7d44a16befb7c13e2fc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;49;-384.0766,80.46076;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;56;-1552.779,-108.7857;Inherit;False;Property;_Offsets;Offsets;7;0;Create;True;0;0;0;False;0;False;0,0,0;0.08,-0.5,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1310.12,96.90582;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ZBufferParams;51;-1615.887,263.4458;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;42;-1672.868,51.03745;Inherit;True;Global;_CameraDepthTexture;_CameraDepthTexture;2;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;41;-160.6904,-351.2755;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;40;-449.6904,-384.2755;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;34;-398.8923,-503.1051;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-781.8923,-432.1051;Inherit;False;Property;_FogScale;Fog Scale;5;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;30;-992.6803,-514.1277;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;35;-204.8923,-518.1051;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-800.8923,-356.1051;Inherit;False;Property;_FogOffset;Fog Offset;4;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-580.8923,-534.1051;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1135.984,94.56839;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;149.334,-26.64955;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;47;153.1997,-172.1875;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;436,-218;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/Smoke;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;8;5;False;-1;1;False;-1;1;0;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;61;0;37;0
WireConnection;61;1;62;0
WireConnection;13;1;61;0
WireConnection;59;0;42;1
WireConnection;59;1;51;3
WireConnection;42;1;37;0
WireConnection;41;0;40;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;35;0;34;0
WireConnection;32;0;30;0
WireConnection;32;1;31;0
WireConnection;60;0;59;0
WireConnection;60;1;51;4
WireConnection;39;0;17;4
WireConnection;39;1;49;0
WireConnection;39;2;21;0
WireConnection;39;3;38;1
WireConnection;47;0;13;0
WireConnection;47;1;48;0
WireConnection;0;2;47;0
WireConnection;0;9;39;0
ASEEND*/
//CHKSM=85831B794A1576A28714B85777DB95E4C030ABF8