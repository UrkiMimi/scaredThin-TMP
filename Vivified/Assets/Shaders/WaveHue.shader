// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Post/WaveHue"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Saturation("Saturation", Float) = 0
		_HueTimeScale("Hue Time Scale", Float) = 0
		_WaveScale("Wave Scale", Float) = 0
		_Wave("Wave", Float) = 0
		_Alpha("Alpha", Float) = 0
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

			#define ASE_ABSOLUTE_VERTEX_POS 1


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


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

			uniform float _HueTimeScale;
			uniform sampler2D _Mask;
			uniform UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex);
			uniform float4 _MainTex_ST;
			uniform float _WaveScale;
			uniform float _Wave;
			uniform float _Alpha;
			uniform float _Saturation;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			
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
				float2 break48 = ( uv_MainTex * _WaveScale );
				float temp_output_1_0_g14 = break48.x;
				float temp_output_1_0_g13 = break48.y;
				float4 tex2DNode2 = tex2D( _Mask, ( uv_MainTex + ( ( ( ( ( ( abs( ( ( temp_output_1_0_g14 - floor( ( temp_output_1_0_g14 + 0.5 ) ) ) * 2 ) ) * 2 ) - 1.0 ) * float2( 0,1 ) ) + ( ( ( abs( ( ( temp_output_1_0_g13 - floor( ( temp_output_1_0_g13 + 0.5 ) ) ) * 2 ) ) * 2 ) - 1.0 ) * float2( 1,0 ) ) ) - float2( 0.5,0 ) ) * _Wave ) ) );
				float3 hsvTorgb29 = RGBToHSV( ( ( tex2DNode2 * _Alpha ) + ( UNITY_SAMPLE_SCREENSPACE_TEXTURE( _MainTex, uv_MainTex ) * ( 1.0 - _Alpha ) ) ).rgb );
				float3 hsvTorgb42 = HSVToRGB( float3(( ( _HueTimeScale * _Time.y ) + hsvTorgb29.x ),( hsvTorgb29.y * _Saturation ),hsvTorgb29.z) );
				
				
				finalColor = float4( hsvTorgb42 , 0.0 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
0;6;1920;1005;1127.596;810.5692;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;44;-2308.853,80.18109;Inherit;False;Property;_WaveScale;Wave Scale;5;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2391.356,-89.44479;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-2137.853,3.181091;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;28;-1710.356,-255.1905;Inherit;False;899.1091;546;Wave;10;11;15;21;22;23;24;27;20;19;45;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;48;-1923.853,17.18109;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;11;-1660.356,57.55518;Inherit;False;Triangle Wave;-1;;14;51ec3c8d117f3ec4fa3742c3e00d535b;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;20;-1657.247,-205.1905;Inherit;False;Constant;_Vector1;Vector 0;3;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode;15;-1654.247,126.8095;Inherit;False;Triangle Wave;-1;;13;51ec3c8d117f3ec4fa3742c3e00d535b;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;19;-1650.247,-75.19049;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1420.247,59.80951;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1423.247,155.8095;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1261.247,87.80951;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1215.853,-44.81891;Inherit;False;Property;_Wave;Wave;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-1119.247,85.80951;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-973.2468,73.80951;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-401.853,-417.8189;Inherit;False;Property;_Alpha;Alpha;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-730.2468,-277.1905;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-554.8748,-147.639;Inherit;True;Property;_MainTex;MainTex;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-557.1252,-342.361;Inherit;True;Global;_Mask;_Mask;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;3;94,-278.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;309,-178.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;311.6999,-290.1;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;38;498.1472,-323.8189;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;490.1472,-411.8189;Inherit;False;Property;_HueTimeScale;Hue Time Scale;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;511.6439,-232.4448;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;29;690.7532,-240.1905;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;753.1472,-345.8189;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;756.1472,-85.81891;Inherit;False;Property;_Saturation;Saturation;3;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;952.1472,-257.8189;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;943.1472,-157.8189;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;42;1157.147,-219.8189;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;51;-571.7525,-648.3185;Inherit;True;Global;_Mask_Depth;_Mask_Depth;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-175.5964,-208.5692;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;1520,-279;Float;False;True;-1;2;ASEMaterialInspector;100;1;Urki/Post/WaveHue;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;0;638877211380414200;0;1;True;False;;False;0
WireConnection;46;0;10;0
WireConnection;46;1;44;0
WireConnection;48;0;46;0
WireConnection;11;1;48;0
WireConnection;15;1;48;1
WireConnection;21;0;11;0
WireConnection;21;1;19;0
WireConnection;22;0;15;0
WireConnection;22;1;20;0
WireConnection;23;0;21;0
WireConnection;23;1;22;0
WireConnection;24;0;23;0
WireConnection;27;0;24;0
WireConnection;27;1;45;0
WireConnection;25;0;10;0
WireConnection;25;1;27;0
WireConnection;2;1;25;0
WireConnection;3;0;49;0
WireConnection;4;0;1;0
WireConnection;4;1;3;0
WireConnection;5;0;2;0
WireConnection;5;1;49;0
WireConnection;6;0;5;0
WireConnection;6;1;4;0
WireConnection;29;0;6;0
WireConnection;40;0;39;0
WireConnection;40;1;38;0
WireConnection;41;0;40;0
WireConnection;41;1;29;1
WireConnection;36;0;29;2
WireConnection;36;1;34;0
WireConnection;42;0;41;0
WireConnection;42;1;36;0
WireConnection;42;2;29;3
WireConnection;52;0;2;4
WireConnection;52;1;49;0
WireConnection;7;0;42;0
ASEEND*/
//CHKSM=922F2B6A8EEAF9834FA86D1D6E74B1EF06ADB8DD