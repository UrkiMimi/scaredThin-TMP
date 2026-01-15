// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Shockwave"
{
	Properties
	{
		_DisplacementIntensity("Displacement Intensity", Float) = 0
		[Toggle(_ENABLEALPHA_ON)] _EnableAlpha("Enable Alpha", Float) = 0
		_MainTex("Main Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		ZTest Always
		GrabPass{ }
		CGPROGRAM
		#pragma target 5.0
		#pragma shader_feature ENABLE_QUEST_OPTIMIZATIONS
		#pragma shader_feature_local _ENABLEALPHA_ON
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _DisplacementIntensity;


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef ENABLE_QUEST_OPTIMIZATIONS
				float3 staticSwitch13 = ( ase_vertex3Pos * float3( 0,0,0 ) );
			#else
				float3 staticSwitch13 = ase_vertex3Pos;
			#endif
			v.vertex.xyz = staticSwitch13;
			v.vertex.w = 1;
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
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 screenColor3 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_screenPosNorm + float4( ( UnpackNormal( tex2D( _MainTex, uv_MainTex ) ) * _DisplacementIntensity * i.vertexColor.a * tex2D( _MainTex, uv_MainTex ).a ) , 0.0 ) ).xy);
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor20 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_grabScreenPos.xy/ase_grabScreenPos.w);
			#ifdef _ENABLEALPHA_ON
				float4 staticSwitch22 = ( ( screenColor20 * ( 1.0 - i.vertexColor.a ) ) + ( screenColor3 * i.vertexColor * i.vertexColor.a ) );
			#else
				float4 staticSwitch22 = ( screenColor3 * i.vertexColor );
			#endif
			#ifdef ENABLE_QUEST_OPTIMIZATIONS
				float4 staticSwitch15 = i.vertexColor;
			#else
				float4 staticSwitch15 = staticSwitch22;
			#endif
			o.Emission = staticSwitch15.rgb;
			o.Alpha = screenColor3.a;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
6.4;5.6;1523;788;1103.901;481.4747;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;25;-769.1279,-35.13989;Inherit;True;Property;_MainTex;Main Texture;3;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;11;-451,157;Inherit;False;Property;_DisplacementIntensity;Displacement Intensity;1;0;Create;True;0;0;0;False;0;False;0;0.025;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-474.1279,-229.1399;Inherit;True;Property;_AlphaTexture;AlphaTexture;1;0;Create;True;0;0;0;False;0;False;-1;None;e417ed688b9bc154a83d8864e108cd08;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-473,-36;Inherit;True;Property;_DistTexture;DistTexture;1;0;Create;True;0;0;0;False;0;False;-1;None;e417ed688b9bc154a83d8864e108cd08;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;1;160,-29;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;7;-173,-203;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-164,-36;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;17,-195;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;20;94.87207,-371.1399;Inherit;False;Global;_GrabScreen1;Grab Screen 0;0;0;Create;True;0;0;0;False;0;False;Instance;3;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;3;161,-201;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;18;383.8721,-215.1399;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;577,-191;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;578.8721,-290.1399;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;761.8721,-213.1399;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;582.8721,-70.13989;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;16;825,62;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;22;923.8721,-219.1399;Inherit;False;Property;_EnableAlpha;Enable Alpha;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;1074,67;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;15;1297,-209;Inherit;False;Property;_EnableQuestOptimizations1;Enable Quest Optimizations;3;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_QUEST_OPTIMIZATIONS;Toggle;2;Key0;Key1;Reference;13;False;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;13;1242,46;Inherit;False;Property;_EnableQuestOptimizations;Enable Quest Optimizations;3;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_QUEST_OPTIMIZATIONS;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1587,-247;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/Shockwave;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;7;False;-1;False;1;False;-1;1;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;27;0;25;0
WireConnection;9;0;25;0
WireConnection;8;0;9;0
WireConnection;8;1;11;0
WireConnection;8;2;1;4
WireConnection;8;3;27;4
WireConnection;5;0;7;0
WireConnection;5;1;8;0
WireConnection;3;0;5;0
WireConnection;18;0;1;4
WireConnection;4;0;3;0
WireConnection;4;1;1;0
WireConnection;4;2;1;4
WireConnection;19;0;20;0
WireConnection;19;1;18;0
WireConnection;21;0;19;0
WireConnection;21;1;4;0
WireConnection;23;0;3;0
WireConnection;23;1;1;0
WireConnection;22;1;23;0
WireConnection;22;0;21;0
WireConnection;17;0;16;0
WireConnection;15;1;22;0
WireConnection;15;0;1;0
WireConnection;13;1;16;0
WireConnection;13;0;17;0
WireConnection;0;2;15;0
WireConnection;0;9;3;4
WireConnection;0;11;13;0
ASEEND*/
//CHKSM=67B6F3D73A2DEABED340FDE1D3D704F4E0EAA99D