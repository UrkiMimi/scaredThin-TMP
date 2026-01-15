// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Glowing"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature MAIN_EFFECT_ENABLED
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float eyeDepth;
			float4 screenPos;
		};

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


		float4 fogcorrection40( float4 input, float offset )
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


		float4 GammaCorrection38( float4 input, float GammaValue )
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
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			#ifdef MAIN_EFFECT_ENABLED
				float4 staticSwitch36 = _Color;
			#else
				float4 staticSwitch36 = ( _Color + _Color.a );
			#endif
			float clampResult24 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.1 , 1.0 );
			float temp_output_12_0 = ( 1.0 - clampResult24 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 input40 = ase_grabScreenPosNorm;
			float offset40 = _StereoCameraEyeOffset;
			float4 localfogcorrection40 = fogcorrection40( input40 , offset40 );
			float4 input38 = ( tex2D( _BloomPrePassTexture, localfogcorrection40.xy ) + ( _CustomFogColor * _CustomFogColorMultiplier ) );
			float GammaValue38 = _CustomFogGammaCorrection;
			float4 localGammaCorrection38 = GammaCorrection38( input38 , GammaValue38 );
			o.Emission = ( ( staticSwitch36 * temp_output_12_0 ) + ( clampResult24 * localGammaCorrection38 ) ).rgb;
			o.Alpha = ( temp_output_12_0 * _Color.a );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;18;1920;993;1506.859;521.8044;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;25;-1048.188,-120.5553;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-959.84,-192.7363;Inherit;False;Property;_FogOffset;Fog Offset;3;0;Create;True;0;0;0;False;0;False;0;-1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1033.188,-261.5553;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;18;-1014.628,-342.7589;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-706.188,-334.5553;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-734.188,-223.5553;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-912.6681,212.3099;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;30;-897.4663,10.1311;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-660.058,356.1339;Inherit;False;Global;_CustomFogColorMultiplier;_CustomFogColorMultiplier;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;27;-531.058,192.1339;Inherit;False;Global;_CustomFogColor;_CustomFogColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;40;-646.05,29.08121;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-558.84,-337.7363;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-555.84,-236.7363;Inherit;False;Property;_FogScale;Fog Scale;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-324.058,191.1339;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;2;-398,-184.5;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.5019608,1,0.9137255;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-457,-7.5;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;2;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;23;-376.84,-306.7363;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;24;-173.84,-398.7363;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-165.9659,-251.3689;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-136.058,3.133911;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-368.2919,369.6162;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;38;11.35983,-5.353989;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;36;-45.96588,-152.3689;Inherit;False;Property;_MainEffectEnabled;Main Effect Enabled;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Create;False;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;12;262,-169.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;428,-170.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;274,-97.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;526.942,11.13385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;567,-156.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;736,-202;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Urki/Glowing;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;18;0
WireConnection;20;1;17;0
WireConnection;19;0;16;0
WireConnection;19;1;25;0
WireConnection;40;0;30;0
WireConnection;40;1;41;0
WireConnection;22;0;20;0
WireConnection;22;1;19;0
WireConnection;28;0;27;0
WireConnection;28;1;29;0
WireConnection;9;1;40;0
WireConnection;23;0;22;0
WireConnection;23;1;21;0
WireConnection;24;0;23;0
WireConnection;37;0;2;0
WireConnection;37;1;2;4
WireConnection;26;0;9;0
WireConnection;26;1;28;0
WireConnection;38;0;26;0
WireConnection;38;1;39;0
WireConnection;36;1;37;0
WireConnection;36;0;2;0
WireConnection;12;0;24;0
WireConnection;10;0;36;0
WireConnection;10;1;12;0
WireConnection;11;0;24;0
WireConnection;11;1;38;0
WireConnection;14;0;12;0
WireConnection;14;1;2;4
WireConnection;13;0;10;0
WireConnection;13;1;11;0
WireConnection;0;2;13;0
WireConnection;0;9;14;0
ASEEND*/
//CHKSM=4DB82BA81F94DB4B626F8B79E10C02D87A2F2232