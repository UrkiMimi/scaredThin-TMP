// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/CustomUI"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_TintColor("Tint Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Stencil
		{
			Ref 0
			PassFront Keep
			FailFront Keep
			ZFailFront Keep
		}
		Blend SrcAlpha OneMinusSrcAlpha , Zero OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma target 5.0
		#pragma multi_compile __ UNITY_UI_CLIP_RECT
		#pragma multi_compile __ UNITY_UI_ALPHACLIP
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _TintColor;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			o.Emission = ( tex2DNode1 * _TintColor * i.vertexColor ).rgb;
			o.Alpha = ( tex2DNode1.a * _TintColor.a * i.vertexColor.a );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;49;1680;917;1113.877;289.3488;1;True;True
Node;AmplifyShaderEditor.VertexColorNode;2;-235,128.5;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-272,-35.5;Inherit;False;Property;_TintColor;Tint Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-365,-232.5;Inherit;True;Property;_MainTex;Main Texture;1;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;27,-127.5;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;21,-16.5;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;24;206,-99;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/CustomUI;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;True;0;False;-1;255;False;-1;255;False;-1;0;False;-1;1;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;2;Pragma;multi_compile __ UNITY_UI_CLIP_RECT;False;;Custom;Pragma;multi_compile __ UNITY_UI_ALPHACLIP;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;1;0
WireConnection;4;1;3;0
WireConnection;4;2;2;0
WireConnection;15;0;1;4
WireConnection;15;1;3;4
WireConnection;15;2;2;4
WireConnection;24;2;4;0
WireConnection;24;9;15;0
ASEEND*/
//CHKSM=D0C1FD0E04CD897F864E4838CDFE3E5CF757BBC9