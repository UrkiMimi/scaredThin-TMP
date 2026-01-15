// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Fresnel/GlowEdge"
{
	Properties
	{
		_Color("Color", Color) = (1,0,0,1)
		_GlowIntensity("Glow Intensity", Range( 0 , 1)) = 0
		_RimFresnel("Rim Fresnel", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest-450" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature MAIN_EFFECT_ENABLED
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float4 _Color;
		uniform float _GlowIntensity;
		uniform float _RimFresnel;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV6 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode6 = ( 0.0 + _RimFresnel * pow( 1.0 - fresnelNdotV6, 5.0 ) );
			float temp_output_4_0 = ( _Color.a * _GlowIntensity * abs( fresnelNode6 ) );
			#ifdef MAIN_EFFECT_ENABLED
				float4 staticSwitch11 = _Color;
			#else
				float4 staticSwitch11 = ( temp_output_4_0 + _Color );
			#endif
			o.Emission = staticSwitch11.rgb;
			#ifdef MAIN_EFFECT_ENABLED
				float staticSwitch9 = temp_output_4_0;
			#else
				float staticSwitch9 = 1.0;
			#endif
			o.Alpha = staticSwitch9;
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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
0;6;1920;1005;757.0327;533.8914;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;7;-695,202;Inherit;False;Property;_RimFresnel;Rim Fresnel;3;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;6;-524,131;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-211,-187;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;1,0,0,1;0,0.3019609,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-286,34;Inherit;False;Property;_GlowIntensity;Glow Intensity;2;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;8;-147,127;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;64,-13;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;67,-93;Inherit;False;Constant;_One;One;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;87,-207;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;11;242,-215;Inherit;False;Property;_MAIN_EFFECT_ENABLED1;MAIN_EFFECT_ENABLED;4;0;Create;True;0;0;0;False;0;False;0;0;0;False;;Toggle;2;Key0;Key1;Reference;9;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;9;247,-69;Inherit;False;Property;MAIN_EFFECT_ENABLED;MAIN_EFFECT_ENABLED;4;0;Create;False;0;0;0;True;0;False;0;0;0;False;;Toggle;2;Key0;Key1;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;540,-273;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Urki/Fresnel/GlowEdge;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;-450;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;2;7;0
WireConnection;8;0;6;0
WireConnection;4;0;1;4
WireConnection;4;1;5;0
WireConnection;4;2;8;0
WireConnection;12;0;4;0
WireConnection;12;1;1;0
WireConnection;11;1;12;0
WireConnection;11;0;1;0
WireConnection;9;1;10;0
WireConnection;9;0;4;0
WireConnection;0;2;11;0
WireConnection;0;9;9;0
ASEEND*/
//CHKSM=3A8A2FD12C15373B13B017C8ADC25437FD772035