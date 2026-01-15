// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Amplify/FunnyTrailRemake"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_ColorTint("Color Tint", Color) = (0,0,0,0)
		_DisplacementTexture("Displacement Texture", 2D) = "white" {}
		_DisplacementVector("Displacement Vector", Vector) = (0,0,0,0)
		_TimeScale("Time Scale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		AlphaToMask On
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

		uniform float4 _ColorTint;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform sampler2D _DisplacementTexture;
		uniform float _TimeScale;
		uniform float4 _DisplacementTexture_ST;
		uniform float2 _DisplacementVector;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Emission = ( _ColorTint * i.vertexColor ).rgb;
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float mulTime13 = _Time.y * _TimeScale;
			float2 uv_DisplacementTexture = i.uv_texcoord * _DisplacementTexture_ST.xy + _DisplacementTexture_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTexture, ( float4( uv_MainTexture, 0.0 , 0.0 ) + ( tex2D( _DisplacementTexture, ( ( ( mulTime13 + uv_DisplacementTexture.y ) * float2( 0,1 ) ) + ( uv_DisplacementTexture.x * float2( 1,0 ) ) ) ) * float4( _DisplacementVector, 0.0 , 0.0 ) ) ).rg );
			o.Alpha = ( tex2DNode1.a * tex2DNode1 ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
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
				half4 color : COLOR0;
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
				o.color = v.color;
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
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
0;48;1920;963;855;575.5;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;15;-1540,56;Inherit;False;Property;_TimeScale;Time Scale;5;0;Create;True;0;0;0;False;0;False;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1537,-117;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;13;-1380,56;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;17;-1204,145;Inherit;False;Constant;_Green;Green;6;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;16;-1204,24;Inherit;False;Constant;_Red;Red;6;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-1188,-88;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1044,28;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1045,-89;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-833,-83;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;10;-541,121;Inherit;False;Property;_DisplacementVector;Displacement Vector;4;0;Create;True;0;0;0;False;0;False;0,0;0.05,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;9;-553,-70;Inherit;True;Property;_DisplacementTexture;Displacement Texture;3;0;Create;True;0;0;0;False;0;False;-1;None;7160a0d3cd930c446b6f81193120863c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-334,-196;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-260,-73;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-108,-189;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;5;85,-560;Inherit;False;Property;_ColorTint;Color Tint;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;4;123,-390;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;4,-222;Inherit;True;Property;_MainTexture;Main Texture;1;0;Create;True;0;0;0;False;0;False;-1;None;2ef0b21cd2181ab45bd9ba0890ba2654;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;347,-221;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;353,-57;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;512,-273;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Urki/Amplify/FunnyTrailRemake;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;Transparent;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;15;0
WireConnection;20;0;13;0
WireConnection;20;1;11;2
WireConnection;21;0;11;1
WireConnection;21;1;16;0
WireConnection;19;0;20;0
WireConnection;19;1;17;0
WireConnection;12;0;19;0
WireConnection;12;1;21;0
WireConnection;9;1;12;0
WireConnection;8;0;9;0
WireConnection;8;1;10;0
WireConnection;6;0;7;0
WireConnection;6;1;8;0
WireConnection;1;1;6;0
WireConnection;3;0;5;0
WireConnection;3;1;4;0
WireConnection;2;0;1;4
WireConnection;2;1;1;0
WireConnection;0;2;3;0
WireConnection;0;9;2;0
ASEEND*/
//CHKSM=B685EBFBFED71FD95C38C835BDF6A94E4FF151E1