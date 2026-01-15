// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/UIBlur"
{
	Properties
	{
		_AddColor("Add Color", Color) = (0,0,0,0)
		_MainTex("Main Texture", 2D) = "white" {}
		_Intensity("Intensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite On
		Offset  1 , 1
		Stencil
		{
			Ref 0
			CompFront Always
			PassFront Keep
			FailFront Keep
			ZFailFront Keep
		}
		Blend SrcAlpha OneMinusSrcAlpha , Zero OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma target 5.0
		#pragma shader_feature ENABLE_QUEST_OPTIMIZATIONS
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float4 vertexColor : COLOR;
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float4 _AddColor;
		uniform float _Intensity;
		uniform sampler2D _GrabBlurTexture;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _StereoCameraEyeOffset;
		uniform float _CustomFogGammaCorrection;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;


		float4 fogcorrection39( float4 input, float offset )
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


		float4 GammaCorrection38( float4 input, float GammaValue )
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
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 input39 = ase_screenPosNorm;
			float offset39 = _StereoCameraEyeOffset;
			float4 localfogcorrection39 = fogcorrection39( input39 , offset39 );
			float4 input38 = tex2D( _BloomPrePassTexture, localfogcorrection39.xy );
			float GammaValue38 = _CustomFogGammaCorrection;
			float4 localGammaCorrection38 = GammaCorrection38( input38 , GammaValue38 );
			#ifdef ENABLE_QUEST_OPTIMIZATIONS
				float4 staticSwitch23 = localGammaCorrection38;
			#else
				float4 staticSwitch23 = tex2D( _GrabBlurTexture, ase_screenPosNorm.xy );
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode18 = tex2D( _MainTex, uv_MainTex );
			o.Emission = ( ( _AddColor * _Intensity ) + ( i.vertexColor * staticSwitch23 * tex2DNode18 ) ).rgb;
			float temp_output_17_0 = ( i.vertexColor.a * tex2DNode18.a );
			o.Alpha = temp_output_17_0;
		}

		ENDCG
	}
	Fallback "Mobile/Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;2564.781;296.6223;1;True;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;31;-1826.345,146.3259;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-2039.242,32.0723;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;39;-1447.724,246.8436;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1238.803,149.113;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-1227.244,262.7259;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;6;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-896,73;Inherit;True;Global;_GrabBlurTexture;_GrabBlurTexture;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;38;-811.8032,261.113;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;21;-1914.244,361.2259;Inherit;False;Property;_AddColor;Add Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.0002776724,0.09945654,0.1409979,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;23;-551.244,104.7259;Inherit;False;Property;_EnableQuestOptimizations;EnableQuestOptimizations;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_QUEST_OPTIMIZATIONS;Toggle;2;Key0;Key1;Create;False;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;16;-362,-79;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;18;-527,251;Inherit;True;Property;_MainTex;Main Texture;7;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-1897.244,542.2259;Inherit;True;Property;_Intensity;Intensity;8;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-136,68;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1633.244,355.2259;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;30.75598,77.72589;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;4.755981,278.7259;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-335,-181;Inherit;False;Fog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;3;-1119.021,-335.2978;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-153,206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;9;-487.021,-189.2978;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;4;-1274.809,-185.3204;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;2;-1374.021,-365.2978;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;7;-863.021,-205.2978;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1083.021,-27.29779;Inherit;False;Property;_FogOffset;Fog Offset;2;0;Create;True;0;0;0;False;0;False;0;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1064.021,-103.2978;Inherit;False;Property;_FogScale;Fog Scale;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;32;-873.244,-23.77411;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1578.021,-332.2978;Inherit;False;Property;_FresnelOffset;Fresnel Offset;4;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;-681.021,-174.2978;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-836.021,-82.29779;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;20;525,4;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/UIBlur;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;1;False;-1;0;False;-1;True;1;False;-1;1;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;True;0;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;Mobile/Diffuse;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;39;0;31;0
WireConnection;39;1;40;0
WireConnection;33;1;39;0
WireConnection;12;1;31;0
WireConnection;38;0;33;0
WireConnection;38;1;37;0
WireConnection;23;1;12;0
WireConnection;23;0;38;0
WireConnection;15;0;16;0
WireConnection;15;1;23;0
WireConnection;15;2;18;0
WireConnection;35;0;21;0
WireConnection;35;1;36;0
WireConnection;22;0;35;0
WireConnection;22;1;15;0
WireConnection;27;0;17;0
WireConnection;11;0;9;0
WireConnection;3;0;2;0
WireConnection;17;0;16;4
WireConnection;17;1;18;4
WireConnection;9;0;8;0
WireConnection;2;3;1;0
WireConnection;7;0;4;0
WireConnection;7;1;5;0
WireConnection;32;0;10;0
WireConnection;8;0;7;0
WireConnection;8;1;6;0
WireConnection;6;0;3;0
WireConnection;6;1;32;0
WireConnection;20;2;22;0
WireConnection;20;9;17;0
ASEEND*/
//CHKSM=0018D935D5442447A41D64A7315BC4F491724DC9