// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/GlowingCutout"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		_Cutout("Cutout", Float) = 0
		_CutoutTexScale("Cutout Texture Scale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.0
		#pragma shader_feature ENABLE_CENTER_CUTOUT_GLOBAL
		#pragma shader_feature QUEST_CUTOUT
		#pragma shader_feature MAIN_EFFECT_ENABLED
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog vertex:vertexDataFunc 
		struct Input
		{
			float eyeDepth;
			float4 screenPos;
			float3 worldPos;
		};

		uniform float _Cutout;
		uniform float4 _Color;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _StereoCameraEyeOffset;
		uniform float4 _CustomFogColor;
		uniform float _CustomFogColorMultiplier;
		uniform float _CustomFogGammaCorrection;
		uniform sampler3D _CutoutTex;
		uniform float4 _CutoutTexOffset;
		uniform float _CutoutTexScale;
		uniform float _Cutoff = 0.5;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 fogcorrection62( float4 input, float offset )
		{
						#ifdef UNITY_UV_STARTS_AT_TOP
						#else
							input.y = 1 - input.y;
						#endif
						#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)
							if (unity_StereoEyeIndex > 0)
							{
								input.x -= 0.5;
								input.x += offset;
							}
							input.x *=2;
						#endif
						return input;
		}


		float4 GammaCorrection58( float4 input, float GammaValue )
		{
			float4 clr = input;
			clr = log2(clr);
			clr *= GammaValue;
			clr = exp2(clr);
			return clr;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef QUEST_CUTOUT
				float3 staticSwitch47 = ( ( 1.0 - _Cutout ) * ase_vertex3Pos );
			#else
				float3 staticSwitch47 = ase_vertex3Pos;
			#endif
			#ifdef ENABLE_CENTER_CUTOUT_GLOBAL
				float3 staticSwitch60 = ( staticSwitch47 * float3( 0,0,0 ) );
			#else
				float3 staticSwitch60 = staticSwitch47;
			#endif
			v.vertex.xyz = staticSwitch60;
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			#ifdef MAIN_EFFECT_ENABLED
				float4 staticSwitch49 = _Color;
			#else
				float4 staticSwitch49 = ( _Color + _Color.a );
			#endif
			float clampResult24 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.1 , 1.0 );
			float temp_output_12_0 = ( 1.0 - clampResult24 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 input62 = ase_grabScreenPosNorm;
			float offset62 = _StereoCameraEyeOffset;
			float4 localfogcorrection62 = fogcorrection62( input62 , offset62 );
			float4 input58 = ( _CustomFogColor * _CustomFogColorMultiplier );
			float GammaValue58 = _CustomFogGammaCorrection;
			float4 localGammaCorrection58 = GammaCorrection58( input58 , GammaValue58 );
			o.Emission = ( ( staticSwitch49 * temp_output_12_0 ) + ( clampResult24 * ( tex2D( _BloomPrePassTexture, localfogcorrection62.xy ) + localGammaCorrection58 ) ) ).rgb;
			o.Alpha = ( temp_output_12_0 * _Color.a );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform55 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			#ifdef QUEST_CUTOUT
				float staticSwitch42 = 1.0;
			#else
				float staticSwitch42 = step( _Cutout , tex3D( _CutoutTex, ( ( transform55 + _CutoutTexOffset ) * _CutoutTexScale ).xyz ).a );
			#endif
			clip( staticSwitch42 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Mobile/Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;1736.532;289.7905;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;16;-959.84,-192.7363;Inherit;False;Property;_FogOffset;Fog Offset;3;0;Create;True;0;0;0;False;0;False;0;-1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1033.188,-261.5553;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;18;-1014.628,-342.7589;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1048.188,-120.5553;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-706.188,-334.5553;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-734.188,-223.5553;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;56;-877.9974,440.7054;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;30;-892.4663,14.1311;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-558.84,-337.7363;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1212.341,7.323792;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;55;-677.7322,444.5149;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;51;-772.3654,618.7592;Inherit;False;Global;_CutoutTexOffset;_CutoutTexOffset;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;27;-856.058,193.1339;Inherit;False;Global;_CustomFogColor;_CustomFogColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-31.46594,325.1311;Inherit;False;Property;_Cutout;Cutout;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-558.84,-249.7363;Inherit;False;Property;_FogScale;Fog Scale;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-985.058,357.1339;Inherit;False;Global;_CustomFogColorMultiplier;_CustomFogColorMultiplier;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-608,-177.5;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;23;-376.84,-306.7363;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;44;96.46838,513.7095;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;46;103.4684,414.7095;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-467.3655,533.7592;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-655.8579,331.1946;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;62;-649.7229,33.09509;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-649.058,192.1339;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-560.3655,634.7592;Inherit;False;Property;_CutoutTexScale;Cutout Texture Scale;6;0;Create;False;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;345.4684,394.7095;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-245.3655,429.7592;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;9;-457,-7.5;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;2;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;24;-182.84,-321.7363;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-393.532,-164.2905;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;58;-412.2062,190.2244;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-136.058,3.133911;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;47;546.4684,383.7095;Inherit;False;Property;_Keyword0;Keyword 0;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;42;False;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;12;3,-168.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;49;-278.532,-145.2905;Inherit;False;Property;_MainEffectEnabled;Main Effect Enabled;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Create;False;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;57;-140.532,129.7095;Inherit;True;Global;_CutoutTex;_CutoutTex;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;15,-96.5;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;32;160.5341,199.1311;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;152.4684,297.7095;Inherit;False;Constant;_One;One;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;169,-169.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;594.968,640.2095;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;42;299.4684,189.7095;Inherit;False;Property;_QuestCutout;Quest Cutout;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;QUEST_CUTOUT;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;60;767.968,491.2095;Inherit;False;Property;_CenterCutout;Center Cutout;20;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_CENTER_CUTOUT_GLOBAL;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;308,-155.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;260.942,40.13385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1048,35;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;Urki/GlowingCutout;False;False;False;False;True;True;True;True;True;True;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;Mobile/Diffuse;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;18;0
WireConnection;20;1;17;0
WireConnection;19;0;16;0
WireConnection;19;1;25;0
WireConnection;22;0;20;0
WireConnection;22;1;19;0
WireConnection;55;0;56;0
WireConnection;23;0;22;0
WireConnection;23;1;21;0
WireConnection;46;0;33;0
WireConnection;53;0;55;0
WireConnection;53;1;51;0
WireConnection;62;0;30;0
WireConnection;62;1;63;0
WireConnection;28;0;27;0
WireConnection;28;1;29;0
WireConnection;45;0;46;0
WireConnection;45;1;44;0
WireConnection;52;0;53;0
WireConnection;52;1;54;0
WireConnection;9;1;62;0
WireConnection;24;0;23;0
WireConnection;50;0;2;0
WireConnection;50;1;2;4
WireConnection;58;0;28;0
WireConnection;58;1;59;0
WireConnection;26;0;9;0
WireConnection;26;1;58;0
WireConnection;47;1;44;0
WireConnection;47;0;45;0
WireConnection;12;0;24;0
WireConnection;49;1;50;0
WireConnection;49;0;2;0
WireConnection;57;1;52;0
WireConnection;11;0;24;0
WireConnection;11;1;26;0
WireConnection;32;0;33;0
WireConnection;32;1;57;4
WireConnection;10;0;49;0
WireConnection;10;1;12;0
WireConnection;61;0;47;0
WireConnection;42;1;32;0
WireConnection;42;0;43;0
WireConnection;60;1;47;0
WireConnection;60;0;61;0
WireConnection;13;0;10;0
WireConnection;13;1;11;0
WireConnection;14;0;12;0
WireConnection;14;1;2;4
WireConnection;0;2;13;0
WireConnection;0;9;14;0
WireConnection;0;10;42;0
WireConnection;0;11;60;0
ASEEND*/
//CHKSM=34455883DCE9FB6BD55B7DF9F4C80E54A9E0FEE8