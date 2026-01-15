// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/MirrorTestNew"
{
	Properties
	{
		_TintColor("Tint Color", Color) = (0,0,0,0)
		[HideInInspector]_ReflectionTex("ReflectionTex", 2D) = "black" {}
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		[Normal]_NormalTexture("Normal Texture", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Float) = 0
		_DirtTexture("Dirt Texture", 2D) = "white" {}
		_DirtIntensity("Dirt Intensity", Float) = 0
		_WorldUVTile("World UV Tile", Float) = 0
		[Toggle(_USEWORLDUV_ON)] _UseWorldUV("Use World UV", Float) = 0
		_FogDepthMultiplier("Fog Depth Multiplier", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+450" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma shader_feature_local _USEWORLDUV_ON
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float eyeDepth;
			float2 uv_texcoord;
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform sampler2D _DirtTexture;
		uniform float4 _DirtTexture_ST;
		uniform float _WorldUVTile;
		uniform float _DirtIntensity;
		uniform sampler2D _ReflectionTex;
		uniform sampler2D _NormalTexture;
		uniform float4 _NormalTexture_ST;
		uniform float _NormalIntensity;
		uniform float4 _TintColor;
		uniform float _FogDepthMultiplier;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _StereoCameraEyeOffset;
		uniform float4 _CustomFogColor;
		uniform float _CustomFogColorMultiplier;
		uniform float _CustomFogGammaCorrection;


		float4 fogcorrection109( float4 input, float offset )
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


		float4 GammaCorrection78( float4 input, float GammaValue )
		{
			float4 clr = input;
			clr = log2(clr);
			clr *= GammaValue;
			clr = exp2(clr);
			return clr;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_DirtTexture = i.uv_texcoord * _DirtTexture_ST.xy + _DirtTexture_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float2 temp_output_63_0 = ( ( ase_worldPos.x * float2( 1,0 ) * _WorldUVTile ) + ( float2( 0,1 ) * ase_worldPos.z * _WorldUVTile ) );
			#ifdef _USEWORLDUV_ON
				float2 staticSwitch65 = temp_output_63_0;
			#else
				float2 staticSwitch65 = uv_DirtTexture;
			#endif
			float4 tex2DNode46 = tex2D( _DirtTexture, staticSwitch65 );
			float clampResult76 = clamp( ( ( tex2DNode46 * _DirtIntensity ).r - 0.1 ) , 0.0 , 1.0 );
			float clampResult26 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , clampResult76 , 1.0 );
			float temp_output_7_0 = ( 1.0 - clampResult26 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 MirrorUV94 = ase_screenPosNorm;
			float2 uv_NormalTexture = i.uv_texcoord * _NormalTexture_ST.xy + _NormalTexture_ST.zw;
			#ifdef _USEWORLDUV_ON
				float2 staticSwitch66 = temp_output_63_0;
			#else
				float2 staticSwitch66 = uv_NormalTexture;
			#endif
			float4 tex2DNode2 = tex2D( _ReflectionTex, ( MirrorUV94 + float4( ( UnpackNormal( tex2D( _NormalTexture, staticSwitch66 ) ) * _NormalIntensity ) , 0.0 ) ).xy );
			float clampResult101 = clamp( ( _FogDepthMultiplier * i.eyeDepth ) , 0.0 , 1.0 );
			float4 input109 = ase_screenPosNorm;
			float offset109 = _StereoCameraEyeOffset;
			float4 localfogcorrection109 = fogcorrection109( input109 , offset109 );
			float4 input78 = ( tex2D( _BloomPrePassTexture, localfogcorrection109.xy ) + ( _CustomFogColor * _CustomFogColorMultiplier ) );
			float GammaValue78 = _CustomFogGammaCorrection;
			float4 localGammaCorrection78 = GammaCorrection78( input78 , GammaValue78 );
			o.Emission = ( ( temp_output_7_0 * ( ( ( tex2DNode2 * _TintColor * ( 1.0 - ( ( 1.0 - tex2DNode46 ) * _DirtIntensity ) ) ) * ( 1.0 - clampResult101 ) * ( 1.0 - tex2DNode2.a ) ) + ( tex2DNode2 * tex2DNode2.a ) ) ) + ( localGammaCorrection78 * clampResult26 ) ).rgb;
			o.Alpha = ( temp_output_7_0 * tex2DNode2.a * _TintColor.a );
		}

		ENDCG
	}
	Fallback "Mobile/Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;1977.649;-19.94678;1;True;False
Node;AmplifyShaderEditor.Vector2Node;61;-1751.076,-725.7845;Inherit;False;Constant;_Red;Red;10;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;60;-1750.076,-593.7845;Inherit;False;Constant;_Green;Green;10;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;57;-1762.076,-383.7845;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;64;-1747.076,-466.7845;Inherit;False;Property;_WorldUVTile;World UV Tile;10;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-1438.076,-299.7845;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1437.076,-405.7845;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-1285,-472;Inherit;False;0;46;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-1252.076,-320.7845;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;67;-1613.512,127.7236;Inherit;False;0;34;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;90;-1042.914,995.575;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;66;-1392.512,143.7236;Inherit;False;Property;_UseWorldUV;Use World UV;11;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;65;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;65;-1059.076,-442.7845;Inherit;False;Property;_UseWorldUV;Use World UV;11;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-951,18;Inherit;False;Property;_NormalIntensity;Normal Intensity;7;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-553,-598;Inherit;False;Property;_DirtIntensity;Dirt Intensity;9;0;Create;True;0;0;0;False;0;False;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;46;-830,-504;Inherit;True;Property;_DirtTexture;Dirt Texture;8;0;Create;True;0;0;0;False;0;False;-1;None;b8bb4920a4f49cd47b2a3e5bd27befe2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-414.9143,896.5753;Inherit;False;MirrorUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;34;-1119.827,91.83064;Inherit;True;Property;_NormalTexture;Normal Texture;6;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;e93ebd564fad4404385cb11e91ff84f6;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;99;-173.8266,482.9542;Inherit;False;Property;_FogDepthMultiplier;Fog Depth Multiplier;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-724,79;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;49;-514,-486;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-663.9143,-79.42468;Inherit;False;94;MirrorUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-994.13,-90.18916;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-200.1737,-627.0558;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-905.782,-162.3702;Inherit;False;Property;_FogOffset;Fog Offset;4;0;Create;True;0;0;0;False;0;False;0;-1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-979.13,-231.1892;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;20;-960.5699,-312.3928;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-421,-65;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;69.03878,391.2285;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-356,-477;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-652.13,-304.1892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;73;36.4165,-477.6833;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;110;-1504.458,686.0612;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;9;-1276.244,284.9196;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-680.13,-193.1892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;101;217.0504,371.1638;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-286,-93;Inherit;True;Property;_ReflectionTex;ReflectionTex;2;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-501.782,-206.3702;Inherit;False;Property;_FogScale;Fog Scale;5;0;Create;True;0;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-931.4177,546.6775;Inherit;False;Global;_CustomFogColorMultiplier;_CustomFogColorMultiplier;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;109;-951.8403,283.8324;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;29;-861.4177,377.6775;Inherit;False;Global;_CustomFogColor;_CustomFogColor;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;50;-219.2964,-515.4072;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-504.782,-307.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-190.9224,280.1075;Inherit;False;Property;_TintColor;Tint Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.5,0.5,0.5,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;162.731,-466.1779;Inherit;True;2;0;FLOAT;0.1;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;256.9015,-135.5927;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-591.4177,359.6775;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;104;63.82348,25.70846;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-692.4177,174.1774;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;3;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-333.782,-318.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;76;-323.481,-215.53;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;100;375.4858,355.8674;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-369.0246,200.5092;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;26;-127.7396,-280.9468;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;490.1405,30.92016;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;491.1861,-90.51448;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-955.5692,634.0244;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;78;-219.7101,157.8348;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;668.3806,-66.01744;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;7;-125,-165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;264.1981,26.55045;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;812.2237,-65.75701;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;55;-1546,-83;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;108;960.2365,-65.757;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;248.6897,125.7622;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;93;-675.9143,903.575;Inherit;False;float4 UV = ScreenPos@$UV.x += Offset@$UV.x /= 2@$return UV@;4;Create;2;True;ScreenPos;FLOAT4;0,0,0,0;In;;Inherit;False;True;Offset;FLOAT;0;In;;Inherit;False;StereoEye;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;83;-997.615,920.8995;Inherit;False;return unity_StereoEyeIndex@;1;Create;1;True;In0;FLOAT;0;In;;Inherit;False;UnityStereoEyeIndex;True;False;0;;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1113.871,-115.5766;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/MirrorTestNew;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;7;Custom;0.5;True;False;450;True;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;Mobile/Diffuse;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;62;0;60;0
WireConnection;62;1;57;3
WireConnection;62;2;64;0
WireConnection;59;0;57;1
WireConnection;59;1;61;0
WireConnection;59;2;64;0
WireConnection;63;0;59;0
WireConnection;63;1;62;0
WireConnection;66;1;67;0
WireConnection;66;0;63;0
WireConnection;65;1;52;0
WireConnection;65;0;63;0
WireConnection;46;1;65;0
WireConnection;94;0;90;0
WireConnection;34;1;66;0
WireConnection;33;0;34;0
WireConnection;33;1;35;0
WireConnection;49;0;46;0
WireConnection;77;0;46;0
WireConnection;77;1;48;0
WireConnection;32;0;95;0
WireConnection;32;1;33;0
WireConnection;98;0;99;0
WireConnection;98;1;20;0
WireConnection;47;0;49;0
WireConnection;47;1;48;0
WireConnection;22;0;20;0
WireConnection;22;1;19;0
WireConnection;73;0;77;0
WireConnection;21;0;18;0
WireConnection;21;1;27;0
WireConnection;101;0;98;0
WireConnection;2;1;32;0
WireConnection;109;0;9;0
WireConnection;109;1;110;0
WireConnection;50;0;47;0
WireConnection;24;0;22;0
WireConnection;24;1;21;0
WireConnection;74;0;73;0
WireConnection;4;0;2;0
WireConnection;4;1;11;0
WireConnection;4;2;50;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;104;0;2;4
WireConnection;3;1;109;0
WireConnection;25;0;24;0
WireConnection;25;1;23;0
WireConnection;76;0;74;0
WireConnection;100;0;101;0
WireConnection;28;0;3;0
WireConnection;28;1;30;0
WireConnection;26;0;25;0
WireConnection;26;1;76;0
WireConnection;105;0;2;0
WireConnection;105;1;2;4
WireConnection;96;0;4;0
WireConnection;96;1;100;0
WireConnection;96;2;104;0
WireConnection;78;0;28;0
WireConnection;78;1;79;0
WireConnection;106;0;96;0
WireConnection;106;1;105;0
WireConnection;7;0;26;0
WireConnection;6;0;78;0
WireConnection;6;1;26;0
WireConnection;107;0;7;0
WireConnection;107;1;106;0
WireConnection;108;0;107;0
WireConnection;108;1;6;0
WireConnection;10;0;7;0
WireConnection;10;1;2;4
WireConnection;10;2;11;4
WireConnection;93;0;90;0
WireConnection;93;1;83;0
WireConnection;0;2;108;0
WireConnection;0;9;10;0
ASEEND*/
//CHKSM=6209079CCEE6CAD557A43FC8AA53915594D775CB