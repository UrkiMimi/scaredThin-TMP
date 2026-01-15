// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Sprite"
{
	Properties
	{
		_MainTex("MainTexture", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		[Off][On]_Glow("Glow", Int) = 0
		_FactorOffset("Factor Offset", Int) = 0
		[Toggle(MAIN_EFFECT_OVERRIDE)] _OverrideMainEffect("Override Main Effect Settings", Float) = 0
		_Fade("Fade", Float) = 0
		[Toggle]_EnableFading("Enable Fading", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Stencil
		{
			Ref 0
		}
		Blend SrcAlpha OneMinusSrcAlpha , [_Glow] OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.0
		#pragma shader_feature_local MAIN_EFFECT_OVERRIDE
		#pragma shader_feature MAIN_EFFECT_ENABLED
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float eyeDepth;
			float4 screenPosition;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform int _Glow;
		uniform int _FactorOffset;
		uniform float _FogOffset;
		uniform float _FogScale;
		uniform float _EnableFading;
		uniform float _Fade;


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			int temp_output_28_0 = ( 0 * _Glow );
			#ifdef MAIN_EFFECT_ENABLED
				float staticSwitch41 = (float)temp_output_28_0;
			#else
				float staticSwitch41 = (float)temp_output_28_0;
			#endif
			#ifdef MAIN_EFFECT_OVERRIDE
				float staticSwitch43 = 0.0;
			#else
				float staticSwitch43 = staticSwitch41;
			#endif
			o.Emission = ( ( i.vertexColor * tex2DNode1 * _Color ) + staticSwitch43 + ( 0 * _FactorOffset ) ).rgb;
			float clampResult23 = clamp( ( ( i.eyeDepth - ( _FogOffset + 0.0 ) ) / _FogScale ) , 0.0 , 1.0 );
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 ditherCustomScreenPos47 = ( ase_screenPosNorm / float4( 2,2,2,2 ) );
			float2 clipScreen47 = ditherCustomScreenPos47.xy * _ScreenParams.xy;
			float dither47 = Dither8x8Bayer( fmod(clipScreen47.x, 8), fmod(clipScreen47.y, 8) );
			o.Alpha = ( i.vertexColor.a * tex2DNode1.a * _Color.a * ( 1.0 - clampResult23 ) * ( _EnableFading == 1.0 ? step( _Fade , dither47 ) : 1.0 ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
6;5.5;1428;824;1752.736;359.0334;1.29037;True;False
Node;AmplifyShaderEditor.RangedFloatNode;15;-1130.782,-3.370193;Inherit;False;Property;_FogOffset;Fog Offset;3;0;Create;True;0;0;0;False;0;False;0;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;17;-1185.57,-153.3928;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-905.13,-34.18919;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;44;-1167.334,494.6467;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-726.782,-47.37019;Inherit;False;Property;_FogScale;Fog Scale;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-729.782,-148.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;45;-958.3336,504.6467;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;2,2,2,2;False;1;FLOAT4;0
Node;AmplifyShaderEditor.IntNode;36;-1375.122,156.5837;Inherit;False;Property;_Glow;Glow;5;0;Create;True;0;0;0;False;2;Off;On;False;0;1;False;0;1;INT;0
Node;AmplifyShaderEditor.DitheringNode;47;-796.3336,470.6467;Inherit;False;1;True;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1214.122,190.7155;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-883.3336,390.6467;Inherit;False;Property;_Fade;Fade;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-547.782,-117.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-305,191.5;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-333.3541,-7.66148;Inherit;True;Property;_MainTex;MainTexture;1;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;48;-516.3334,608.1467;Inherit;False;Property;_EnableFading;Enable Fading;9;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;38;-743,146.5;Inherit;False;Property;_FactorOffset;Factor Offset;6;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.StepOpNode;49;-519.3334,389.6467;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;2;-233,-160.5;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;23;-379.782,-140.3702;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;41;-1050.643,165.5016;Inherit;False;Property;_MainEffectEnabled;Main Effect Enabled;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;36,-165.5;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;25;-234,-237.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-494.0963,139.0156;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.StaticSwitch;43;-699.1485,32.59413;Inherit;False;Property;_OverrideMainEffect;Override Main Effect Settings;7;0;Create;False;0;0;0;False;0;False;0;0;0;True;MAIN_EFFECT_OVERRIDE;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;50;-274.3335,382.1467;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;171,-161;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;33,-39.5;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;321,-247;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;Urki/Sprite;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;1;True;38;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;True;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;1;0;True;36;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;18;0;15;0
WireConnection;21;0;17;0
WireConnection;21;1;18;0
WireConnection;45;0;44;0
WireConnection;47;2;45;0
WireConnection;28;1;36;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;49;0;46;0
WireConnection;49;1;47;0
WireConnection;23;0;22;0
WireConnection;41;1;28;0
WireConnection;41;0;28;0
WireConnection;5;0;2;0
WireConnection;5;1;1;0
WireConnection;5;2;6;0
WireConnection;25;0;23;0
WireConnection;39;1;38;0
WireConnection;43;1;41;0
WireConnection;50;0;48;0
WireConnection;50;2;49;0
WireConnection;29;0;5;0
WireConnection;29;1;43;0
WireConnection;29;2;39;0
WireConnection;7;0;2;4
WireConnection;7;1;1;4
WireConnection;7;2;6;4
WireConnection;7;3;25;0
WireConnection;7;4;50;0
WireConnection;0;2;29;0
WireConnection;0;9;7;0
ASEEND*/
//CHKSM=D377FF7050E5B7F4D147C0A123D97CE1F051240E