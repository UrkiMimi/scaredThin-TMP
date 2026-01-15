// Upgrade NOTE: upgraded instancing buffer 'UrkiParametric3SliceSpriteObstacle' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Parametric3SliceSpriteObstacle"
{
	Properties
	{
		_TintColor("Tint Color", Color) = (1,0,0,1)
		_MainTex("Sprite Texture", 2D) = "white" {}
		_SizeParams("_SizeParams", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Stencil
		{
			Ref 0
			CompFront Always
			PassFront Keep
			FailFront Keep
			ZFailFront Keep
		}
		Blend SrcAlpha OneMinusSrcAlpha , Zero OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma target 5.0
		#pragma multi_compile_instancing
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _SizeParams;
		uniform sampler2D _MainTex;

		UNITY_INSTANCING_BUFFER_START(UrkiParametric3SliceSpriteObstacle)
			UNITY_DEFINE_INSTANCED_PROP(float4, _TintColor)
#define _TintColor_arr UrkiParametric3SliceSpriteObstacle
			UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
#define _MainTex_ST_arr UrkiParametric3SliceSpriteObstacle
		UNITY_INSTANCING_BUFFER_END(UrkiParametric3SliceSpriteObstacle)

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 temp_output_41_0 = ( ase_vertex3Pos - ( floor( ( ( ase_vertex3Pos < float3( 0,0,0 ) ? ase_vertex3Pos : float3( 0,0,0 ) ) - ( ase_vertex3Pos > float3( 0,0,0 ) ? ase_vertex3Pos : float3( 0,0,0 ) ) ) ) * _SizeParams.w ) );
			v.vertex.xyz = ( ( ( temp_output_41_0 + temp_output_41_0 ) * float3( 1,1,1 ) ) / (_SizeParams).xyz );
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 _TintColor_Instance = UNITY_ACCESS_INSTANCED_PROP(_TintColor_arr, _TintColor);
			o.Emission = _TintColor_Instance.rgb;
			float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_MainTex_ST_arr, _MainTex_ST);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
			float4 tex2DNode28 = tex2D( _MainTex, uv_MainTex );
			o.Alpha = ( tex2DNode28 * tex2DNode28.a ).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
-16.8;24;1536;766;1268.05;213.2058;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;32;-932,21.3411;Inherit;False;1214.404;497.7589;Vertex stuff;11;5;37;38;39;40;41;43;44;45;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;5;-854.446,123.4113;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;37;-619.05,108.7942;Inherit;False;2;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Compare;38;-616.05,251.7942;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-419.05,153.7942;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FloorOpNode;40;-278.05,166.7942;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;44;-410.05,257.7942;Inherit;False;Property;_SizeParams;_SizeParams;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-144.05,144.7942;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;11.95,3.794205;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;17.94995,144.7942;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;47;-223.05,264.7942;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;28;-117.796,-245.1589;Inherit;True;Property;_MainTex;Sprite Texture;2;0;Create;False;0;0;0;False;0;False;-1;None;af3cfcfd051d00d4faa11a0b69f3ed60;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;144.95,156.7942;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;14;-1100,-412;Inherit;False;542.8;235.6;Amplify component mask is retarded;3;11;20;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;20;-732.796,-348.6589;Inherit;False;Constant;_Blue;Blue;2;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;19;-1060.796,-351.6589;Inherit;False;Constant;_Red;Red;2;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-772.796,-567.1589;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;46;285.95,153.7942;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;11;-893,-350;Inherit;False;Constant;_Green;Green;2;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;195.204,-228.6589;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2;-52,-413.5;Inherit;False;InstancedProperty;_TintColor;Tint Color;0;0;Create;False;0;0;0;False;0;False;1,0,0,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;654,-374;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/Parametric3SliceSpriteObstacle;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;True;0;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;1;0;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;False;Absolute;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;37;0;5;0
WireConnection;37;2;5;0
WireConnection;38;0;5;0
WireConnection;38;2;5;0
WireConnection;39;0;38;0
WireConnection;39;1;37;0
WireConnection;40;0;39;0
WireConnection;48;0;40;0
WireConnection;48;1;44;4
WireConnection;41;0;5;0
WireConnection;41;1;48;0
WireConnection;43;0;41;0
WireConnection;43;1;41;0
WireConnection;47;0;44;0
WireConnection;45;0;43;0
WireConnection;46;0;45;0
WireConnection;46;1;47;0
WireConnection;29;0;28;0
WireConnection;29;1;28;4
WireConnection;0;2;2;0
WireConnection;0;9;29;0
WireConnection;0;11;46;0
ASEEND*/
//CHKSM=88478387308C8AE8F639617E504892152CEB8A5F