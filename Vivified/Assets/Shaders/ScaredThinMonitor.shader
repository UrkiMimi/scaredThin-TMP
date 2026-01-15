// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/ScaredThin/Monitor"
{
	Properties
	{
		_MainTex("Camera", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_CameraThreshold("Camera Threshold", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha , Zero OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _CameraThreshold;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = _Color.rgb;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 desaturateInitialColor4 = tex2D( _MainTex, uv_MainTex ).rgb;
			float desaturateDot4 = dot( desaturateInitialColor4, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar4 = lerp( desaturateInitialColor4, desaturateDot4.xxx, 0.0 );
			float3 clampResult8 = clamp( ( desaturateVar4 * _CameraThreshold ) , float3( 0,0,0 ) , float3( 1,0,0 ) );
			o.Alpha = clampResult8.x;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;629;1497;362;916.29;240.3596;1;True;False
Node;AmplifyShaderEditor.SamplerNode;1;-652,-246.5;Inherit;True;Property;_MainTex;Camera;0;0;Create;False;0;0;0;False;0;False;-1;None;cedc4e32c1ff4424cb1d45c8c2cdb7fd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;4;-312,-141.5;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-367.29,-28.35962;Inherit;False;Property;_CameraThreshold;Camera Threshold;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-99.28998,-118.3596;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;2;-143,-238.5;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;6;-600.2896,-41.35962;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;8;69.71002,-107.3596;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;267,-294;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Urki/ScaredThin/Monitor;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;1;0
WireConnection;7;0;4;0
WireConnection;7;1;9;0
WireConnection;8;0;7;0
WireConnection;0;2;6;0
WireConnection;0;9;8;0
ASEEND*/
//CHKSM=56D592282FFE1FEC68356A832E212D5ACD381BB1