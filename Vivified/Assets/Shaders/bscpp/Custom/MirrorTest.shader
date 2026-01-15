// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/MirrorTest"
{
	Properties
	{
		_TintColor("Tint Color", Color) = (0,0,0,0)
		[HideInInspector]_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		_NormalTexture("Normal Texture", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		Blend One Zero
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#include "UnityCG.cginc"
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
			float eyeDepth;
		};

		uniform sampler2D _ReflectionTex;
		uniform sampler2D _NormalTexture;
		uniform float4 _NormalTexture_ST;
		uniform float _NormalIntensity;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform float4 _TintColor;
		uniform sampler2D _BloomPrePassTexture;
		uniform float4 _CustomFogColor;
		uniform float _CustomFogColorMultiplier;


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
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 uv_NormalTexture = i.uv_texcoord * _NormalTexture_ST.xy + _NormalTexture_ST.zw;
			float4 tex2DNode2 = tex2D( _ReflectionTex, ( ase_grabScreenPosNorm + float4( ( UnpackNormal( tex2D( _NormalTexture, uv_NormalTexture ) ) * _NormalIntensity ) , 0.0 ) ).xy );
			float clampResult26 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.1 , 1.0 );
			float temp_output_7_0 = ( 1.0 - clampResult26 );
			o.Emission = ( ( tex2DNode2 * temp_output_7_0 * _TintColor ) + ( clampResult26 * ( tex2D( _BloomPrePassTexture, ase_grabScreenPosNorm.xy ) + ( _CustomFogColor * _CustomFogColorMultiplier ) ) ) ).rgb;
			o.Alpha = ( temp_output_7_0 * tex2DNode2.a * _TintColor.a );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
263;26;1273;715;1413.233;401.3232;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;27;-994.13,-90.18916;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-905.782,-162.3702;Inherit;False;Property;_FogOffset;Fog Offset;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-979.13,-231.1892;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;20;-960.5699,-312.3928;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-680.13,-193.1892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-652.13,-302.1892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-504.782,-307.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-501.782,-206.3702;Inherit;False;Property;_FogScale;Fog Scale;5;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;34;-1057,89;Inherit;True;Property;_NormalTexture;Normal Texture;6;0;Create;True;0;0;0;False;0;False;-1;None;ea400335b033eab4b94d3f6f809f6242;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-951,18;Inherit;False;Property;_NormalIntensity;Normal Intensity;7;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-345.782,-300.3702;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;36;-760.256,-89.3439;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-764,475.5;Inherit;False;Global;_CustomFogColorMultiplier;_CustomFogColorMultiplier;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-724,79;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;29;-694,306.5;Inherit;False;Global;_CustomFogColor;_CustomFogColor;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-424,288.5;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;26;-128.782,-291.3702;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-421,-65;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;3;-525,103;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-176,105.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-282,-90;Inherit;True;Property;_ReflectionTex;ReflectionTex;2;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-222,237;Inherit;False;Property;_TintColor;Tint Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.5019608,0.5019608,0.5019608,0.5019608;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;7;18,-282;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;92,1;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;102,-134;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;246,-67;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;88,99;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;495,-126;Float;False;True;-1;7;ASEMaterialInspector;0;0;Standard;Urki/MirrorTest;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;1;1;False;-1;0;False;-1;0;10;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;1;Include;UnityCG.cginc;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;18;0
WireConnection;21;1;27;0
WireConnection;22;0;20;0
WireConnection;22;1;19;0
WireConnection;24;0;22;0
WireConnection;24;1;21;0
WireConnection;25;0;24;0
WireConnection;25;1;23;0
WireConnection;33;0;34;0
WireConnection;33;1;35;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;26;0;25;0
WireConnection;32;0;36;0
WireConnection;32;1;33;0
WireConnection;3;1;36;0
WireConnection;28;0;3;0
WireConnection;28;1;30;0
WireConnection;2;1;32;0
WireConnection;7;0;26;0
WireConnection;6;0;26;0
WireConnection;6;1;28;0
WireConnection;4;0;2;0
WireConnection;4;1;7;0
WireConnection;4;2;11;0
WireConnection;8;0;4;0
WireConnection;8;1;6;0
WireConnection;10;0;7;0
WireConnection;10;1;2;4
WireConnection;10;2;11;4
WireConnection;0;2;8;0
WireConnection;0;9;10;0
ASEEND*/
//CHKSM=2FF62415A6D30D95A6CA8619180FE401538DF448