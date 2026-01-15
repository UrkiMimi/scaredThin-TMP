// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/LegacyFont"
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
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha , [_Glow] OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local MAIN_EFFECT_OVERRIDE
		#pragma shader_feature MAIN_EFFECT_ENABLED
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float eyeDepth;
		};

		uniform float4 _Color;
		uniform int _Glow;
		uniform int _FactorOffset;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _FogOffset;
		uniform float _FogScale;

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
			#ifdef MAIN_EFFECT_ENABLED
				float staticSwitch41 = (float)( 0 * _Glow );
			#else
				float staticSwitch41 = (float)_Glow;
			#endif
			#ifdef MAIN_EFFECT_OVERRIDE
				float staticSwitch43 = 0.0;
			#else
				float staticSwitch43 = staticSwitch41;
			#endif
			o.Emission = ( ( i.vertexColor * _Color ) + staticSwitch43 + ( 0 * _FactorOffset ) ).rgb;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float clampResult23 = clamp( ( ( i.eyeDepth - ( _FogOffset + 0.0 ) ) / _FogScale ) , 0.0 , 1.0 );
			o.Alpha = ( i.vertexColor.a * tex2D( _MainTex, uv_MainTex ).a * _Color.a * ( 1.0 - clampResult23 ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;0;1536;795;1406.916;459.6821;1.29037;True;False
Node;AmplifyShaderEditor.RangedFloatNode;15;-1130.782,-3.370193;Inherit;False;Property;_FogOffset;Fog Offset;3;0;Create;True;0;0;0;False;0;False;0;-0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;17;-1185.57,-153.3928;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-905.13,-34.18919;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-726.782,-47.37019;Inherit;False;Property;_FogScale;Fog Scale;4;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;36;-1369.96,212.0696;Inherit;False;Property;_Glow;Glow;5;0;Create;True;0;0;0;False;2;Off;On;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-729.782,-148.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-547.782,-117.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1211.541,176.5214;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.ColorNode;6;-305,191.5;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.5990566,0.9330316,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;38;-743,146.5;Inherit;False;Property;_FactorOffset;Factor Offset;6;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.ClampOpNode;23;-379.782,-140.3702;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;2;-233,-160.5;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;41;-1050.643,165.5016;Inherit;False;Property;_MainEffectEnabled;Main Effect Enabled;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-234,-237.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;36,-165.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-507,154.5;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.StaticSwitch;43;-700.4388,31.30376;Inherit;False;Property;_OverrideMainEffect;Override Main Effect Settings;7;0;Create;False;0;0;0;False;0;False;0;0;0;True;MAIN_EFFECT_OVERRIDE;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-342.3866,-2.5;Inherit;True;Property;_MainTex;MainTexture;1;0;Create;False;0;0;0;False;0;False;-1;None;ed939057cabbd0c43bb9cd40f3cd5bfd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;29;171,-161;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;33,-39.5;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;321,-247;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Urki/LegacyFont;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;1;True;38;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;1;0;True;36;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;18;0;15;0
WireConnection;21;0;17;0
WireConnection;21;1;18;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;28;1;36;0
WireConnection;23;0;22;0
WireConnection;41;1;36;0
WireConnection;41;0;28;0
WireConnection;25;0;23;0
WireConnection;5;0;2;0
WireConnection;5;1;6;0
WireConnection;39;1;38;0
WireConnection;43;1;41;0
WireConnection;29;0;5;0
WireConnection;29;1;43;0
WireConnection;29;2;39;0
WireConnection;7;0;2;4
WireConnection;7;1;1;4
WireConnection;7;2;6;4
WireConnection;7;3;25;0
WireConnection;0;2;29;0
WireConnection;0;9;7;0
ASEEND*/
//CHKSM=588C26400AE334D590C6D0796B825C5BA0150278