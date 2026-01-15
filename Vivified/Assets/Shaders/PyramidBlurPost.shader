// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Post/PyramidBlur"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_KernelSize("Kernel Size", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _KernelSize;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				
				finalColor = ( ( tex2Dlod( _MainTex, float4( uv_MainTex, 0, ( _KernelSize / 5.0 )) ) + tex2Dlod( _MainTex, float4( uv_MainTex, 0, ( _KernelSize / 4.0 )) ) + tex2Dlod( _MainTex, float4( uv_MainTex, 0, ( _KernelSize / 3.0 )) ) + tex2Dlod( _MainTex, float4( uv_MainTex, 0, ( _KernelSize / 2.0 )) ) ) / 4.0 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
0;5.6;1536;788;707.933;351.8255;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;4;-759,-191;Inherit;False;Property;_KernelSize;Kernel Size;1;0;Create;True;0;0;0;False;0;False;0;3.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-814,-75;Inherit;True;Property;_MainTex;Main Texture;0;0;Create;False;0;0;0;False;0;False;None;fb1109fed6239b94d95afd6bde559a4a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-290.155,-293.5923;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-322.155,-87.5923;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;17;-302.9333,78.17453;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;18;-276.9333,261.1745;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-131,-353;Inherit;True;Property;_TextureSample1;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-139,-146;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-136,43;Inherit;True;Property;_TextureSample2;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-134.9333,245.1745;Inherit;True;Property;_TextureSample3;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;9;209,-158;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;196,7.5;Inherit;False;Constant;_Four;Four;1;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;370,-166;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;4;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;528,-155;Float;False;True;-1;2;ASEMaterialInspector;100;1;Urki/Post/PyramidBlur;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;13;0;4;0
WireConnection;14;0;4;0
WireConnection;17;0;4;0
WireConnection;18;0;4;0
WireConnection;5;0;2;0
WireConnection;5;2;13;0
WireConnection;3;0;2;0
WireConnection;3;2;14;0
WireConnection;6;0;2;0
WireConnection;6;2;17;0
WireConnection;16;0;2;0
WireConnection;16;2;18;0
WireConnection;9;0;5;0
WireConnection;9;1;3;0
WireConnection;9;2;6;0
WireConnection;9;3;16;0
WireConnection;8;0;9;0
WireConnection;8;1;10;0
WireConnection;1;0;8;0
ASEEND*/
//CHKSM=C5FD238B92D7C3F0B1D45445F9A4E02E213645AE