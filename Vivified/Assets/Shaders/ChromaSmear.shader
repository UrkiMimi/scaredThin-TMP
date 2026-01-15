// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/ChromaSmear"
{
	Properties
	{
		[Header(Color)]_Color("Color", Color) = (0,0,0,0)
		[Toggle(_CUSTOMCOLORS_ON)] _CustomColors("Custom Colors", Float) = 0
		_MainTexture("Main Texture", 2D) = "white" {}
		_GlowIntensity("Glow Intensity", Float) = 0
		[Header(CRT Lines)]_LineWidth("Line Width", Float) = 0
		_LineSpeed("Line Speed", Float) = 0
		_LineIntensity("Line Intensity", Float) = 0
		_ChromaSmearIntensity("Chroma Smear Intensity", Float) = 0
		[Header(Noise)]_NoiseScale("Noise Scale", Float) = 0
		_NoiseTimeSpeed("Noise Time Speed", Float) = 0
		_NoiseIntensity("Noise Intensity", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest-450" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _CUSTOMCOLORS_ON
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _NoiseIntensity;
		uniform float _NoiseTimeSpeed;
		uniform float _NoiseScale;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float _ChromaSmearIntensity;
		uniform float _LineWidth;
		uniform float _LineSpeed;
		uniform float _LineIntensity;
		uniform float4 _Color;
		uniform float _GlowIntensity;


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


		float3 Addcolors46( float r, float g, float b )
		{
			return float3(r, g, b);
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float mulTime56 = _Time.y * _NoiseTimeSpeed;
			float simplePerlin2D51 = snoise( ( i.uv_texcoord + mulTime56 )*_NoiseScale );
			simplePerlin2D51 = simplePerlin2D51*0.5 + 0.5;
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float2 _Vector0 = float2(1,0);
			float2 temp_output_37_0 = ( _Vector0 * ( _ChromaSmearIntensity / 10.0 ) );
			float mulTime10 = _Time.y * _LineSpeed;
			float temp_output_8_0 = tan( ( ( uv_MainTexture.y * _LineWidth ) + mulTime10 ) );
			float2 temp_cast_0 = (mulTime10).xx;
			float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
			float lerpResult10_g1 = lerp( 0.0 , _LineIntensity , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
			float2 temp_output_14_0 = ( ( ( temp_output_8_0 < 0.0 ? 0.0 : temp_output_8_0 ) * ( lerpResult10_g1 / -256.0 ) ) * _Vector0 );
			float r46 = tex2D( _MainTexture, ( uv_MainTexture + temp_output_37_0 + temp_output_14_0 ) ).r;
			float4 tex2DNode1 = tex2D( _MainTexture, ( uv_MainTexture + temp_output_14_0 ) );
			float g46 = tex2DNode1.g;
			float b46 = tex2D( _MainTexture, ( uv_MainTexture + temp_output_14_0 + -temp_output_37_0 ) ).b;
			float3 localAddcolors46 = Addcolors46( r46 , g46 , b46 );
			#ifdef _CUSTOMCOLORS_ON
				float staticSwitch66 = 0.0;
			#else
				float staticSwitch66 = 0.0;
			#endif
			o.Emission = ( float4( ( ( _NoiseIntensity * simplePerlin2D51 ) + ( localAddcolors46 * ( 1.0 - _NoiseIntensity ) ) ) , 0.0 ) * ( _Color + staticSwitch66 ) ).rgb;
			o.Alpha = ( tex2DNode1.a * _GlowIntensity );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;26.4;1536;767;47.16629;526.7104;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;29;-1680.773,92.32349;Inherit;False;Property;_LineSpeed;Line Speed;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1476.773,13.32349;Inherit;False;Property;_LineWidth;Line Width;5;1;[Header];Create;True;1;CRT Lines;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-438,-102;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1293.773,6.323486;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;10;-1508.773,90.82346;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1109.773,160.3235;Inherit;False;Property;_LineIntensity;Line Intensity;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-1124.773,29.82346;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;27;-917.7729,136.3235;Inherit;False;Random Range;-1;;1;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-869.0376,288.4163;Inherit;False;Property;_ChromaSmearIntensity;Chroma Smear Intensity;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TanOpNode;8;-975.7726,29.82346;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;20;-727.7729,-25.67651;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;18;-723.7729,131.3235;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;-256;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;15;-569.7726,130.8235;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;39;-554.0376,256.4163;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-541.7729,29.32349;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-381.0376,136.4163;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;42;-258.0376,229.4163;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-372.7726,32.82346;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-620.0376,-390.0837;Inherit;False;Property;_NoiseTimeSpeed;Noise Time Speed;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-141.0376,70.41632;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;52;-444.0376,-530.0837;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-146,-63;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;56;-411.0376,-396.0837;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-143.7043,-274.2503;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;11,-110;Inherit;True;Property;_MainTexture;Main Texture;3;0;Create;True;1;Color;0;0;False;0;False;-1;None;f9206c9d8a429a146a59d3808b05ec7e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;31.9624,-506.0837;Inherit;False;Property;_NoiseIntensity;Noise Intensity;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;14.29572,-307.2503;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;1;[Header];Create;True;1;Color;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-117.0376,-483.0837;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;41;17.9624,84.41632;Inherit;True;Property;_MainTexture1;Main Texture;3;1;[Header];Create;True;1;Color;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;54;-150.0376,-390.0837;Inherit;False;Property;_NoiseScale;Noise Scale;9;1;[Header];Create;True;1;Noise;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;51;92.9624,-420.0837;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;394.113,-181.9478;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;46;420.9624,-85.58368;Inherit;False;return float3(r, g, b)@;3;Create;3;True;r;FLOAT;0;In;;Inherit;False;True;g;FLOAT;0;In;;Inherit;False;True;b;FLOAT;0;In;;Inherit;False;Add colors;True;False;0;;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;64;576.113,-332.9478;Inherit;False;Property;_Color;Color;1;1;[Header];Create;True;1;Color;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;612.9624,-151.0837;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;605.113,-50.94775;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;66;538.8337,-444.2104;Inherit;False;Property;_CustomColors;Custom Colors;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;161,296;Inherit;False;Property;_GlowIntensity;Glow Intensity;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;814.8337,-298.2104;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;764.113,-97.94775;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;1002.113,-97.94781;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;586,105;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1293,-141;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Urki/ChromaSmear;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;-450;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;0;6;2
WireConnection;30;1;31;0
WireConnection;10;0;29;0
WireConnection;12;0;30;0
WireConnection;12;1;10;0
WireConnection;27;1;10;0
WireConnection;27;3;17;0
WireConnection;8;0;12;0
WireConnection;20;0;8;0
WireConnection;20;3;8;0
WireConnection;18;0;27;0
WireConnection;39;0;38;0
WireConnection;16;0;20;0
WireConnection;16;1;18;0
WireConnection;37;0;15;0
WireConnection;37;1;39;0
WireConnection;42;0;37;0
WireConnection;14;0;16;0
WireConnection;14;1;15;0
WireConnection;40;0;6;0
WireConnection;40;1;14;0
WireConnection;40;2;42;0
WireConnection;7;0;6;0
WireConnection;7;1;14;0
WireConnection;56;0;57;0
WireConnection;33;0;6;0
WireConnection;33;1;37;0
WireConnection;33;2;14;0
WireConnection;1;1;7;0
WireConnection;32;1;33;0
WireConnection;55;0;52;0
WireConnection;55;1;56;0
WireConnection;41;1;40;0
WireConnection;51;0;55;0
WireConnection;51;1;54;0
WireConnection;59;0;47;0
WireConnection;46;0;32;1
WireConnection;46;1;1;2
WireConnection;46;2;41;3
WireConnection;50;0;47;0
WireConnection;50;1;51;0
WireConnection;60;0;46;0
WireConnection;60;1;59;0
WireConnection;65;0;64;0
WireConnection;65;1;66;0
WireConnection;61;0;50;0
WireConnection;61;1;60;0
WireConnection;62;0;61;0
WireConnection;62;1;65;0
WireConnection;4;0;1;4
WireConnection;4;1;2;0
WireConnection;0;2;62;0
WireConnection;0;9;4;0
ASEEND*/
//CHKSM=70094ED3EA37BA4BF0F1E805D20F78AD8C19A41E