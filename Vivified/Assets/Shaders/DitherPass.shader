// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/DitherPass"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_ColorStep("Color Step", Float) = 256
		_DitherIntensity("Dither Intensity", Float) = 0.1
		_Fade("Fade", Float) = 0
		_GrayFact("GrayscaleFactor", Float) = 0
		_Intensity("Intensity", Float) = 0
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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float _ColorStep;
			uniform UNITY_DECLARE_SCREENSPACE_TEXTURE(_Mask);
			uniform float4 _Mask_ST;
			uniform float _Fade;
			uniform UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex);
			uniform float4 _MainTex_ST;
			uniform float _Intensity;
			uniform float _GrayFact;
			uniform float _DitherIntensity;
			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
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
				float2 uv_Mask = i.ase_texcoord1.xy * _Mask_ST.xy + _Mask_ST.zw;
				float2 uv_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 temp_output_65_0 = ( ( UNITY_SAMPLE_SCREENSPACE_TEXTURE( _Mask, uv_Mask ) * _Fade ) + ( UNITY_SAMPLE_SCREENSPACE_TEXTURE( _MainTex, uv_MainTex ) * _Intensity ) );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen41 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither41 = Dither8x8Bayer( fmod(clipScreen41.x, 8), fmod(clipScreen41.y, 8) );
				float div55=256.0/float((int)_ColorStep);
				float4 posterize55 = ( floor( ( ( ( temp_output_65_0.r * _GrayFact ) + ( temp_output_65_0 * ( 1.0 - _GrayFact ) ) ) + ( dither41 * _DitherIntensity ) ) * div55 ) / div55 );
				
				
				finalColor = posterize55;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
0;0;1920;1011;879.137;704.145;1;True;False
Node;AmplifyShaderEditor.SamplerNode;57;-78.25049,-404.722;Inherit;True;Global;_Mask;_Mask;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;90;-276.137,86.85498;Inherit;False;Property;_Intensity;Intensity;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-330,-130;Inherit;True;Property;_MainTex;MainTex;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-67.25049,-524.722;Inherit;False;Property;_Fade;Fade;3;0;Create;True;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;111.863,-177.145;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;227.7495,-344.722;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;81;285.363,-435.145;Inherit;False;Property;_GrayFact;GrayscaleFactor;6;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;426.7495,-223.722;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;87;514.363,-313.145;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;86;551.363,-227.145;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;726.363,-111.145;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;727.363,-209.145;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;240.4922,85.90023;Inherit;False;Property;_DitherIntensity;Dither Intensity;2;0;Create;True;0;0;0;False;0;False;0.1;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;41;213.1973,-26.83908;Inherit;False;1;True;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;877.363,-197.145;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;493.2657,-13.78503;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;979.0344,-97.2296;Inherit;False;Property;_ColorStep;Color Step;1;0;Create;True;0;0;0;False;0;False;256;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;1022.636,-207.6618;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;74;-498.25,-393.722;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-223.25,-364.722;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosterizeNode;55;1197.168,-206.1014;Inherit;False;1;2;1;COLOR;0,0,0,0;False;0;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-460.25,-263.722;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;72;-1030.25,-238.722;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1030.25,-126.722;Inherit;False;Property;_NoiseIntensity;Noise Intensity;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-785.25,-245.722;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;80;-611.25,-147.722;Inherit;False;Constant;_Red;Red;6;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;78;-783.25,-147.722;Inherit;False;2;0;FLOAT;2;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-629.25,-260.722;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;62;127.7495,-503.722;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;40;1444.238,-205.6929;Float;False;True;-1;2;ASEMaterialInspector;100;1;Urki/DitherPass;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;89;0;1;0
WireConnection;89;1;90;0
WireConnection;63;0;57;0
WireConnection;63;1;60;0
WireConnection;65;0;63;0
WireConnection;65;1;89;0
WireConnection;87;0;81;0
WireConnection;86;0;65;0
WireConnection;83;0;65;0
WireConnection;83;1;87;0
WireConnection;85;0;86;0
WireConnection;85;1;81;0
WireConnection;88;0;85;0
WireConnection;88;1;83;0
WireConnection;48;0;41;0
WireConnection;48;1;47;0
WireConnection;42;0;88;0
WireConnection;42;1;48;0
WireConnection;73;0;74;0
WireConnection;73;1;79;0
WireConnection;55;1;42;0
WireConnection;55;0;44;0
WireConnection;79;0;77;0
WireConnection;79;1;80;0
WireConnection;72;0;74;2
WireConnection;75;0;72;0
WireConnection;75;1;76;0
WireConnection;78;0;76;0
WireConnection;77;0;75;0
WireConnection;77;1;78;0
WireConnection;62;0;60;0
WireConnection;40;0;55;0
ASEEND*/
//CHKSM=523A7148F348E67F9638EEA99E865A20527964E5