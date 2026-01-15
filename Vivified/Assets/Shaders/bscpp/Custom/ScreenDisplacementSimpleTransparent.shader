// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/ScreenDisplacementSimpleTransparent"
{
	Properties
	{
		_TintColor("TintColor", Color) = (0,0,0,0)
		_AddColor("AddColor", Color) = (0,0,0,0)
		_TintColorAlpha("TintColorAlpha", Float) = 0.75
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[Toggle]_EnableFog("Enable Fog", Float) = 1
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		_Cutout("Cutout", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+1" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		Blend SrcAlpha OneMinusSrcAlpha , Zero Zero
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.0
		#pragma shader_feature ENABLE_CENTER_CUTOUT_GLOBAL
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog vertex:vertexDataFunc 
		struct Input
		{
			float eyeDepth;
			float4 screenPos;
		};

		uniform float _Cutout;
		uniform float _EnableFog;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _StereoCameraEyeOffset;
		uniform float _CustomFogGammaCorrection;
		uniform float _CullMode;
		uniform float4 _TintColor;
		uniform float4 _AddColor;
		uniform float _TintColorAlpha;


		float4 fogcorrection52( float4 input, float offset )
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


		float4 GammaCorrection48( float4 input, float GammaValue )
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
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 temp_output_45_0 = ( ( 1.0 - _Cutout ) * ase_vertex3Pos );
			#ifdef ENABLE_CENTER_CUTOUT_GLOBAL
				float3 staticSwitch50 = ( temp_output_45_0 * float3( 0,0,0 ) );
			#else
				float3 staticSwitch50 = temp_output_45_0;
			#endif
			v.vertex.xyz = staticSwitch50;
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float clampResult13 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.1 , 1.0 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 input52 = ase_screenPosNorm;
			float offset52 = _StereoCameraEyeOffset;
			float4 localfogcorrection52 = fogcorrection52( input52 , offset52 );
			float4 input48 = tex2D( _BloomPrePassTexture, localfogcorrection52.xy );
			float GammaValue48 = _CustomFogGammaCorrection;
			float4 localGammaCorrection48 = GammaCorrection48( input48 , GammaValue48 );
			o.Emission = ( ( (( _EnableFog )?( clampResult13 ):( 0.0 )) * localGammaCorrection48 ) + ( ( ( _CullMode * 0.0 ) + ( _TintColor * float4( 0.1,0.1,0.1,0.1019608 ) ) + _AddColor ) * ( 1.0 - (( _EnableFog )?( clampResult13 ):( 0.0 )) ) ) ).xyz;
			float clampResult6 = clamp( _TintColorAlpha , 0.0 , 1.0 );
			o.Alpha = clampResult6;
		}

		ENDCG
	}
	Fallback "Mobile/Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;1876.579;899.811;1;True;False
Node;AmplifyShaderEditor.SurfaceDepthNode;16;-1402.656,-379.6341;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1421.216,-298.4305;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1347.868,-229.6115;Inherit;False;Property;_FogOffset;Fog Offset;6;0;Create;True;0;0;0;False;0;False;0;-1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1436.216,-157.4304;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1094.217,-371.4305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-1122.217,-260.4305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-946.8685,-374.6115;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-943.8685,-273.6115;Inherit;False;Property;_FogScale;Fog Scale;7;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;27;-1042,-575.5;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-764.8684,-343.6115;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1250.388,-664.6967;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-110.0825,219.5452;Inherit;False;Property;_Cutout;Cutout;9;0;Create;True;0;0;0;False;0;False;0;-0.59;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-363.9444,-225.4417;Inherit;False;Property;_CullMode;Cull Mode;4;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;52;-840.7697,-526.9254;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;1;-385,-118.5;Inherit;False;Property;_TintColor;TintColor;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.5019608,0.2509804,0.2509804,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;13;-586.3677,-347.7619;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;47;62.18331,219.6797;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-679.0616,-636.2754;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;9;-437.6918,-337.994;Inherit;False;Property;_EnableFog;Enable Fog;5;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;46;30.18442,290.0774;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-161,-115.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.1,0.1,0.1,0.1019608;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-160,-212;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-376,59.5;Inherit;False;Property;_AddColor;AddColor;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1254902,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-655,-547.5;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;8;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;236.0444,213.2799;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;21;-165,-341;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;48;-253.6028,-473.1156;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;15,-128;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;180,-125.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;54.21476,553.3375;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;18,-233.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-111,67.5;Inherit;False;Property;_TintColorAlpha;TintColorAlpha;3;0;Create;True;0;0;0;False;0;False;0.75;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;31;-1315.657,778.4849;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;33;-1306.005,1248.432;Inherit;False;Global;_CutoutTexOffset;_CutoutTexOffset;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VectorFromMatrixNode;39;-1261.006,937.4327;Inherit;False;Row;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;6;74,72.5;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;32;-1091.373,967.1884;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformVariables;40;-1528.005,954.4327;Inherit;False;_Object2World;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-1309.005,1099.432;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;-482.6206,1073.6;Inherit;True;Global;_CutoutTex;_CutoutTex;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-881.0062,1056.432;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-182.7363,1078.22;Inherit;False;CutoutTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-664.006,1123.432;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-974.0063,1157.432;Inherit;False;Property;_CutoutTexScale;Cutout Texture Scale;10;0;Create;False;0;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;382,-122.5;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;50;215.2148,403.3376;Inherit;False;Property;_CenterCutout;Center Cutout;20;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_CENTER_CUTOUT_GLOBAL;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;498,-177;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;Urki/ScreenDisplacementSimpleTransparent;False;False;False;False;True;True;True;True;True;True;False;False;False;True;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;1;True;Custom;Opaque;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;5;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;Mobile/Diffuse;0;-1;-1;-1;0;False;0;0;True;8;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;16;0
WireConnection;14;1;17;0
WireConnection;15;0;19;0
WireConnection;15;1;18;0
WireConnection;10;0;14;0
WireConnection;10;1;15;0
WireConnection;12;0;10;0
WireConnection;12;1;11;0
WireConnection;52;0;27;0
WireConnection;52;1;53;0
WireConnection;13;0;12;0
WireConnection;47;0;42;0
WireConnection;9;1;13;0
WireConnection;3;0;1;0
WireConnection;20;0;8;0
WireConnection;26;1;52;0
WireConnection;45;0;47;0
WireConnection;45;1;46;0
WireConnection;21;0;9;0
WireConnection;48;0;26;0
WireConnection;48;1;49;0
WireConnection;22;0;20;0
WireConnection;22;1;3;0
WireConnection;22;2;2;0
WireConnection;29;0;22;0
WireConnection;29;1;21;0
WireConnection;51;0;45;0
WireConnection;28;0;9;0
WireConnection;28;1;48;0
WireConnection;39;0;40;0
WireConnection;6;0;5;0
WireConnection;32;0;31;0
WireConnection;37;1;36;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;38;0;37;4
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;30;0;28;0
WireConnection;30;1;29;0
WireConnection;50;1;45;0
WireConnection;50;0;51;0
WireConnection;0;2;30;0
WireConnection;0;9;6;0
WireConnection;0;11;50;0
ASEEND*/
//CHKSM=92CE3640E2D8E4C63696F74B572C179D5CE28127