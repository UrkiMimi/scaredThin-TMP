// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Post/NoiseDisplacementAmp"
{
	Properties
	{
		_NoiseScale("Noise Scale", Float) = 128
		_MainTex("MainTex", 2D) = "white" {}
		_TimeScale("Time Scale", Float) = 128
		_DisplacementIntensity("Displacement Intensity", Float) = 0.1

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

			uniform sampler2D _MainTex;
			uniform float _TimeScale;
			uniform float _NoiseScale;
			uniform float _DisplacementIntensity;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
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
				float2 texCoord30 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime17 = _Time.y * _TimeScale;
				float2 temp_cast_1 = (( mulTime17 + texCoord30.y )).xx;
				float simplePerlin2D10 = snoise( temp_cast_1*_NoiseScale );
				simplePerlin2D10 = simplePerlin2D10*0.5 + 0.5;
				
				
				finalColor = tex2D( _MainTex, ( float3( texCoord30 ,  0.0 ) + ( ( ( simplePerlin2D10 * _DisplacementIntensity ) - ( _DisplacementIntensity / 2.0 ) ) * float3(1,0,0) ) ).xy );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
0;0;1536;795;201.2729;568.0091;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;19;-1452,-81.5;Inherit;False;Property;_TimeScale;Time Scale;2;0;Create;True;0;0;0;False;0;False;128;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-1304,-75.5;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-504.2727,-199.0091;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-1091,10;Inherit;False;Property;_NoiseScale;Noise Scale;0;0;Create;True;0;0;0;False;0;False;128;512;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-1066,-95.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1003,95;Inherit;False;Property;_DisplacementIntensity;Displacement Intensity;3;0;Create;True;0;0;0;False;0;False;0.1;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;10;-904,-7;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-713,88;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-714,-21;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-546,-19;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;16;-545,78.5;Inherit;False;Constant;_Red;Red;3;0;Create;True;0;0;0;False;0;False;1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-386,-27.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-214,-193;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1;-76,-213;Inherit;True;Property;_MainTex;MainTex;1;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture2DArray;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;40;281,-206;Float;False;True;-1;2;ASEMaterialInspector;100;1;Urki/Post/NoiseDisplacementAmp;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;17;0;19;0
WireConnection;18;0;17;0
WireConnection;18;1;30;2
WireConnection;10;0;18;0
WireConnection;10;1;11;0
WireConnection;13;0;12;0
WireConnection;8;0;10;0
WireConnection;8;1;12;0
WireConnection;14;0;8;0
WireConnection;14;1;13;0
WireConnection;15;0;14;0
WireConnection;15;1;16;0
WireConnection;4;0;30;0
WireConnection;4;1;15;0
WireConnection;1;1;4;0
WireConnection;40;0;1;0
ASEEND*/
//CHKSM=323C93B30F64B85E40A3D903ACB1246B2B969BBF