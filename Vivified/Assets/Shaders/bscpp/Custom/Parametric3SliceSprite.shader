// Upgrade NOTE: upgraded instancing buffer 'UrkiParametric3SliceSprite' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Parametric3SliceSprite"
{
	Properties
	{
		_Color("Tint Color", Color) = (1,0,0,1)
		_MainTex("Sprite Texture", 2D) = "white" {}
		_GlowOffset("Glow Offset", Float) = 0
		_StretchFactor("Stretch", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Stencil
		{
			Ref 0
			PassFront Keep
			FailFront Keep
		}
		Blend One One , One One
		
		CGPROGRAM
		#pragma target 4.0
		#pragma multi_compile_instancing
		#pragma shader_feature MAIN_EFFECT_ENABLED
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float _GlowOffset;

		UNITY_INSTANCING_BUFFER_START(UrkiParametric3SliceSprite)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
#define _Color_arr UrkiParametric3SliceSprite
			UNITY_DEFINE_INSTANCED_PROP(float, _StretchFactor)
#define _StretchFactor_arr UrkiParametric3SliceSprite
		UNITY_INSTANCING_BUFFER_END(UrkiParametric3SliceSprite)

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef MAIN_EFFECT_ENABLED
				float3 staticSwitch48 = ( float3( 0,0,0 ) * ase_vertex3Pos );
			#else
				float3 staticSwitch48 = ase_vertex3Pos;
			#endif
			v.vertex.xyz = staticSwitch48;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 _Color_Instance = UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color);
			float3 _Red = float3(1,0,0);
			float3 _Green = float3(0,1,0);
			float _StretchFactor_Instance = UNITY_ACCESS_INSTANCED_PROP(_StretchFactor_arr, _StretchFactor);
			float temp_output_82_0 = ( _StretchFactor_Instance < 1.0 ? 1.0 : _StretchFactor_Instance );
			float temp_output_67_0 = ( i.uv_texcoord.x * temp_output_82_0 );
			float temp_output_79_0 = ( temp_output_67_0 + ( 1.0 - temp_output_82_0 ) );
			float4 tex2DNode28 = tex2D( _MainTex, ( ( _Red * i.uv_texcoord.y ) + ( _Green * ( temp_output_67_0 < 0.5 ? temp_output_67_0 : ( temp_output_79_0 > 0.5 ? temp_output_79_0 : 0.5 ) ) ) ).xy );
			float clampResult42 = clamp( tex2DNode28.a , _GlowOffset , 1.0 );
			o.Emission = ( ( ( _Color_Instance * i.vertexColor ) * tex2DNode28 * tex2DNode28.a * _Color_Instance.a ) + ( ( clampResult42 - _GlowOffset ) / _GlowOffset ) ).rgb;
			o.Alpha = ( tex2DNode28 * tex2DNode28.a * _Color_Instance.a * i.vertexColor.a ).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;73.6;1099;702;776.4135;671.1797;1.287853;True;False
Node;AmplifyShaderEditor.CommentaryNode;83;-2352.53,-506.1095;Inherit;False;1475.873;458.7272;UV Mess;8;58;61;82;67;76;79;80;81;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2302.53,-418.7614;Inherit;False;InstancedProperty;_StretchFactor;Stretch;5;0;Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;58;-2012.413,-272.3822;Inherit;True;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;82;-2053.813,-456.1094;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1668.906,-411.0348;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;76;-1867.237,-412.3221;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-1526.826,-324.7481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;80;-1354.253,-364.6716;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;14;-1797.669,3.716758;Inherit;False;542.8;235.6;Amplify component mask is retarded;3;11;20;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;11;-1590.668,65.71694;Inherit;False;Constant;_Green;Green;2;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;19;-1758.465,64.05807;Inherit;False;Constant;_Red;Red;2;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Compare;81;-1056.256,-427.7764;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-516.9305,-253.8132;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-526.6532,-352.2602;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-323.6814,-269.6133;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;28;-179.8575,-241.0819;Inherit;True;Property;_MainTex;Sprite Texture;3;0;Create;False;0;0;0;False;0;False;-1;None;54b6f90712abdd247870aaee78d8759a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;45;-115.8869,13.71943;Inherit;False;Property;_GlowOffset;Glow Offset;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;52;-92.58791,-602.0233;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-104.2621,-424.4385;Inherit;False;InstancedProperty;_Color;Tint Color;0;0;Create;False;0;0;0;True;0;False;1,0,0,1;1,1,1,0.6980392;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;42;190.9364,-98.4053;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;173.584,-395.4061;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;43;450.767,-124.1903;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;47;284.1854,137.5451;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;589.2499,154.5607;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;32;-1320.557,259.5589;Inherit;False;1214.404;497.7589;Vertex stuff;11;18;25;26;27;24;23;15;9;5;3;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;811.5116,-369.7748;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;700.189,-161.0011;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;197.6347,-256.6131;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-569.353,364.0589;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-864.3527,310.5589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-729.3529,504.5589;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-1022.039,423.8467;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;48;766.698,108.3756;Inherit;False;Property;_MainEffect;Main Effect;5;0;Create;True;0;0;0;False;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;20;-1430.466,67.05807;Inherit;False;Constant;_Blue;Blue;2;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;3;-1278.415,505.5409;Inherit;False;InstancedProperty;_SizeParams;Size Length and Center;1;0;Create;False;0;0;0;False;0;False;0.2,2,0.5;1,1.03,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-236.6071,342.012;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;5;-1312.003,328.6291;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;50;993.9771,-356.5136;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-1821.682,-683.0399;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-737.3528,405.5589;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-737.3528,309.5589;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-871.3528,409.0589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-865.3527,505.5589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1215.515,-434.7697;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;Urki/Parametric3SliceSprite;False;False;False;False;True;True;True;True;True;True;True;True;False;True;True;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;-10;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;True;0;False;-1;255;False;-1;255;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;4;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;False;Absolute;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;82;0;61;0
WireConnection;82;3;61;0
WireConnection;67;0;58;1
WireConnection;67;1;82;0
WireConnection;76;0;82;0
WireConnection;79;0;67;0
WireConnection;79;1;76;0
WireConnection;80;0;79;0
WireConnection;80;2;79;0
WireConnection;81;0;67;0
WireConnection;81;2;67;0
WireConnection;81;3;80;0
WireConnection;40;0;19;0
WireConnection;40;1;58;2
WireConnection;39;0;11;0
WireConnection;39;1;81;0
WireConnection;41;0;40;0
WireConnection;41;1;39;0
WireConnection;28;1;41;0
WireConnection;42;0;28;4
WireConnection;42;1;45;0
WireConnection;53;0;2;0
WireConnection;53;1;52;0
WireConnection;43;0;42;0
WireConnection;43;1;45;0
WireConnection;49;1;47;0
WireConnection;35;0;53;0
WireConnection;35;1;28;0
WireConnection;35;2;28;4
WireConnection;35;3;2;4
WireConnection;44;0;43;0
WireConnection;44;1;45;0
WireConnection;29;0;28;0
WireConnection;29;1;28;4
WireConnection;29;2;2;4
WireConnection;29;3;52;4
WireConnection;18;0;25;0
WireConnection;18;1;26;0
WireConnection;18;2;27;0
WireConnection;23;0;5;1
WireConnection;23;1;3;1
WireConnection;27;0;20;0
WireConnection;27;1;24;0
WireConnection;9;0;5;2
WireConnection;9;1;3;3
WireConnection;48;1;47;0
WireConnection;48;0;49;0
WireConnection;34;1;18;0
WireConnection;50;0;35;0
WireConnection;50;1;44;0
WireConnection;26;0;11;0
WireConnection;26;1;15;0
WireConnection;25;0;19;0
WireConnection;25;1;23;0
WireConnection;15;0;9;0
WireConnection;15;1;3;2
WireConnection;24;0;3;1
WireConnection;24;1;5;3
WireConnection;0;2;50;0
WireConnection;0;9;29;0
WireConnection;0;11;48;0
ASEEND*/
//CHKSM=1EC88C6504D207895BF71C2E67F12978395B5499