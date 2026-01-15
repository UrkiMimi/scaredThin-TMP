// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UrkiParticle/FresnelBugfix"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Color("Tint Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend One One , Zero One
		CGPROGRAM
		#pragma target 5.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float3 worldPos;
			float3 worldNormal;
			half ASEVFace : VFACE;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV3 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode3 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV3, 1.0 ) );
			float switchResult14 = (((i.ASEVFace>0)?(fresnelNode3):(0.0)));
			o.Emission = ( tex2DNode1.r * _Color * i.vertexColor * ( 1.0 - switchResult14 ) * _Color.a * i.vertexColor.a ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;604;1455;387;803.7241;195.4301;1;True;False
Node;AmplifyShaderEditor.FresnelNode;3;-1137,104;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;14;-798.7241,96.56992;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-624,-256;Inherit;True;Property;_MainTex;Main Texture;0;0;Create;False;0;0;0;False;0;False;-1;None;ba601cbd80260eb40be57c39d4c80d8d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-544,-64;Inherit;False;Property;_Color;Tint Color;2;0;Create;False;0;0;0;False;0;False;0,0,0,0;0.9716981,0.5087648,0.8543458,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;4;-541,210;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;6;-521,118.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-147,-91.5;Inherit;False;6;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;11;241,-190;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;UrkiParticle/FresnelBugfix;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;1;0;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;3;0
WireConnection;6;0;14;0
WireConnection;5;0;1;1
WireConnection;5;1;2;0
WireConnection;5;2;4;0
WireConnection;5;3;6;0
WireConnection;5;4;2;4
WireConnection;5;5;4;4
WireConnection;11;2;5;0
ASEEND*/
//CHKSM=0B681A7020539403C6C455C80F52327AE7A43E63