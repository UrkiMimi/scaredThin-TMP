// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/GlowMap Sprite"
{
	Properties
	{
		_MainTex("MainTexture", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		[Off][On]_Glow("Glow", Int) = 0
		_FactorOffset("Factor Offset", Int) = 0
		_GlowOffset("Glow Offset", Float) = 0
		[ToggleUI]_UseCutout("Use Cutout", Float) = 1
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
		#pragma shader_feature ENABLE_CENTER_CUTOUT_GLOBAL
		#pragma shader_feature MAIN_EFFECT_ENABLED
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog vertex:vertexDataFunc 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float eyeDepth;
		};

		uniform float _UseCutout;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float _GlowOffset;
		uniform int _Glow;
		uniform int _FactorOffset;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef ENABLE_CENTER_CUTOUT_GLOBAL
				float3 staticSwitch75 = ( ase_vertex3Pos * float3( 0,0,0 ) );
			#else
				float3 staticSwitch75 = ase_vertex3Pos;
			#endif
			v.vertex.xyz = (( _UseCutout )?( staticSwitch75 ):( ase_vertex3Pos ));
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float3 hsvTorgb70 = RGBToHSV( tex2DNode1.rgb );
			float clampResult62 = clamp( tex2DNode1.a , _GlowOffset , 1.0 );
			float temp_output_66_0 = ( ( clampResult62 - _GlowOffset ) / _GlowOffset );
			#ifdef MAIN_EFFECT_ENABLED
				float staticSwitch41 = (float)( 0 * _Glow );
			#else
				float staticSwitch41 = ( temp_output_66_0 * _Glow );
			#endif
			o.Emission = ( ( i.vertexColor * hsvTorgb70.z * _Color ) + staticSwitch41 + ( 0 * _FactorOffset ) ).rgb;
			#ifdef MAIN_EFFECT_ENABLED
				float staticSwitch47 = temp_output_66_0;
			#else
				float staticSwitch47 = tex2DNode1.a;
			#endif
			float clampResult23 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.0 , 1.0 );
			o.Alpha = ( i.vertexColor.a * staticSwitch47 * _Color.a * ( 1.0 - clampResult23 ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
12.8;21.6;1523;772;921.6672;119.4493;1.128153;True;False
Node;AmplifyShaderEditor.RangedFloatNode;24;-1219.13,68.81084;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;17;-1185.57,-153.3928;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1130.782,-3.370193;Inherit;False;Property;_FogOffset;Fog Offset;3;0;Create;True;0;0;0;False;0;False;0;1.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1204.13,-72.18919;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0.015;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-292.565,379.1942;Inherit;False;Property;_GlowOffset;Glow Offset;7;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-548.0425,-1.37185;Inherit;True;Property;_MainTex;MainTexture;1;0;Create;False;0;0;0;False;0;False;-1;e1a181d8749e8ec47941390104766d32;b86bd71e2ce277e42bf72f2cdfb7cc88;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;62;-9.830742,224.073;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-905.13,-34.18919;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-877.13,-145.1892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;229.3376,227.4574;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-729.782,-148.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-726.782,-47.37019;Inherit;False;Property;_FogScale;Fog Scale;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;66;445.9435,231.97;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;77;-811.8052,520.1268;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;36;-1369.96,212.0696;Inherit;False;Property;_Glow;Glow;5;0;Create;True;0;0;0;False;2;Off;On;False;0;1;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-547.782,-117.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-587.7773,592.546;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RGBToHSVNode;70;-251.9519,13.10859;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.IntNode;38;-743,146.5;Inherit;False;Property;_FactorOffset;Factor Offset;6;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1182.771,145.505;Inherit;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;23;-379.782,-140.3702;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-305,191.5;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1193.476,239.7496;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.VertexColorNode;2;-233,-160.5;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;25;-234,-237.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;41;-1032.577,171.9535;Inherit;False;Property;_MainEffectEnabled;Main Effect Enabled;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;47;-14.91864,116.1736;Inherit;False;Property;_MainEffectEnabled;Main Effect Enabled;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Reference;41;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-504.7437,200.7544;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.StaticSwitch;75;-381.6145,516.0972;Inherit;False;Property;_CenterCutout;Center Cutout;20;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_CENTER_CUTOUT_GLOBAL;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;60.5171,-144.854;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;74;-25.96952,481.4157;Inherit;False;Property;_UseCutout;Use Cutout;8;0;Create;True;0;0;0;False;0;False;1;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;266.5497,-19.01628;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;210.5075,-155.2117;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;497.7807,-236.677;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Urki/GlowMap Sprite;False;False;False;False;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;1;True;38;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;1;0;True;36;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;62;0;1;4
WireConnection;62;1;67;0
WireConnection;18;0;15;0
WireConnection;18;1;24;0
WireConnection;19;0;17;0
WireConnection;19;1;16;0
WireConnection;64;0;62;0
WireConnection;64;1;67;0
WireConnection;21;0;19;0
WireConnection;21;1;18;0
WireConnection;66;0;64;0
WireConnection;66;1;67;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;76;0;77;0
WireConnection;70;0;1;0
WireConnection;49;0;66;0
WireConnection;49;1;36;0
WireConnection;23;0;22;0
WireConnection;28;1;36;0
WireConnection;25;0;23;0
WireConnection;41;1;49;0
WireConnection;41;0;28;0
WireConnection;47;1;1;4
WireConnection;47;0;66;0
WireConnection;39;1;38;0
WireConnection;75;1;77;0
WireConnection;75;0;76;0
WireConnection;5;0;2;0
WireConnection;5;1;70;3
WireConnection;5;2;6;0
WireConnection;74;0;77;0
WireConnection;74;1;75;0
WireConnection;7;0;2;4
WireConnection;7;1;47;0
WireConnection;7;2;6;4
WireConnection;7;3;25;0
WireConnection;29;0;5;0
WireConnection;29;1;41;0
WireConnection;29;2;39;0
WireConnection;0;2;29;0
WireConnection;0;9;7;0
WireConnection;0;11;74;0
ASEEND*/
//CHKSM=628C0BCF7D77A1F705444EDB2C4E9AB368ED397B