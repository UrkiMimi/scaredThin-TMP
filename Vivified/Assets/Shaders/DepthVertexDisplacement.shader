// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Test/DepthVertexDisplacement"
{
	Properties
	{
		_TintColor("TintColor", Color) = (1,1,1,1)
		_MultFactor("Texture Multiplication Factor", Vector) = (0,0,0,0)
		_DesaturationFactor("Desaturation Factor", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _MultFactor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_ST;
		uniform float _DesaturationFactor;
		uniform float4 _TintColor;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float2 uv_CameraDepthTexture = v.texcoord * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
			float3 desaturateInitialColor11 = tex2Dlod( _CameraDepthTexture, float4( uv_CameraDepthTexture, 0, 0.0) ).rgb;
			float desaturateDot11 = dot( desaturateInitialColor11, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar11 = lerp( desaturateInitialColor11, desaturateDot11.xxx, _DesaturationFactor );
			v.vertex.xyz = ( float4( ase_vertex3Pos , 0.0 ) + ( _MultFactor * float4( desaturateVar11 , 0.0 ) ) ).xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_CameraDepthTexture = i.uv_texcoord * _CameraDepthTexture_ST.xy + _CameraDepthTexture_ST.zw;
			float3 desaturateInitialColor11 = tex2D( _CameraDepthTexture, uv_CameraDepthTexture ).rgb;
			float desaturateDot11 = dot( desaturateInitialColor11, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar11 = lerp( desaturateInitialColor11, desaturateDot11.xxx, _DesaturationFactor );
			o.Emission = ( _TintColor * float4( desaturateVar11 , 0.0 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;0;1536;795;1676;191;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;12;-680,262;Inherit;False;Property;_DesaturationFactor;Desaturation Factor;3;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-754,65;Inherit;True;Global;_CameraDepthTexture;_CameraDepthTexture;1;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;8;-525,-108;Inherit;False;Property;_MultFactor;Texture Multiplication Factor;2;0;Create;False;0;0;0;False;0;False;0,0,0,0;0,-2.32,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;11;-428,90;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;5;-362,284;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1;-237,-119;Inherit;False;Property;_TintColor;TintColor;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-209,88;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1012,441;Inherit;False;Property;_Division;Division;4;0;Create;True;0;0;0;False;0;False;0;10000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-787,340;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;21,-104;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-22,258;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;14;-1031,123;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;240,-169;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Urki/Test/DepthVertexDisplacement;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;0;4;0
WireConnection;11;1;12;0
WireConnection;9;0;8;0
WireConnection;9;1;11;0
WireConnection;15;1;16;0
WireConnection;3;0;1;0
WireConnection;3;1;11;0
WireConnection;7;0;5;0
WireConnection;7;1;9;0
WireConnection;0;2;3;0
WireConnection;0;11;7;0
ASEEND*/
//CHKSM=887BCD467C9177DC66D23ECAE9E4125C2B375B8B