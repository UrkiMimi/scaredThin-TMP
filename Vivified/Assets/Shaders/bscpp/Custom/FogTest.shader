// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/FogLighting"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Color("Color", Color) = (0,0,0,0)
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		_FogClamp("FogClamp", Vector) = (0,0,0,0)
		_FresnelVector("FresnelVector", Vector) = (0,0,0,0)
		[Toggle(_ENABLECUTOUT_ON)] _EnableCutout("Enable Cutout", Float) = 0
		_EdgeGlowColor("EdgeGlowColor", Color) = (1,1,1,1)
		_Cutout("Cutout", Float) = 0
		_CutoutTextureScale("Cutout Texture Scale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		Stencil
		{
			Ref 255
			Comp Always
			Pass Keep
			Fail Keep
			ZFail Keep
		}
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma shader_feature_local _ENABLECUTOUT_ON
		#pragma shader_feature QUEST_CUTOUT
		#pragma vertex vert
		#pragma multi_compile_fog
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float eyeDepth;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float _Cutout;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _StereoCameraEyeOffset;
		uniform float4 _CustomFogColor;
		uniform float _CustomFogColorMultiplier;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform float2 _FogClamp;
		uniform float3 _FresnelVector;
		uniform float4 _Color;
		uniform sampler2D _CutoutTex;
		uniform float4 _CutoutTexOffset;
		uniform float _CutoutTextureScale;
		uniform float4 _EdgeGlowColor;
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


		float4 MyCustomExpression80( float4 input, float offset )
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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef QUEST_CUTOUT
				float3 staticSwitch92 = ( ( 1.0 - _Cutout ) * ase_vertex3Pos );
			#else
				float3 staticSwitch92 = ase_vertex3Pos;
			#endif
			#ifdef _ENABLECUTOUT_ON
				float3 staticSwitch94 = staticSwitch92;
			#else
				float3 staticSwitch94 = ase_vertex3Pos;
			#endif
			v.vertex.xyz = staticSwitch94;
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 input80 = ase_grabScreenPosNorm;
			float offset80 = _StereoCameraEyeOffset;
			float4 localMyCustomExpression80 = MyCustomExpression80( input80 , offset80 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV54 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode54 = ( _FresnelVector.x + _FresnelVector.y * pow( 1.0 - fresnelNdotV54, _FresnelVector.z ) );
			float clampResult15 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , ( _FogClamp.x * ( 1.0 - fresnelNode54 ) ) , _FogClamp.y );
			float temp_output_19_0 = ( 1.0 - clampResult15 );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform116 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float4 tex2DNode118 = tex2D( _CutoutTex, ( ( transform116 + _CutoutTexOffset ) * _CutoutTextureScale ).xy );
			#ifdef _ENABLECUTOUT_ON
				float4 staticSwitch104 = ( step( tex2DNode118.a , _Cutout ) * _EdgeGlowColor );
			#else
				float4 staticSwitch104 = float4( 0,0,0,0 );
			#endif
			#ifdef QUEST_CUTOUT
				float4 staticSwitch105 = float4( 0,0,0,0 );
			#else
				float4 staticSwitch105 = staticSwitch104;
			#endif
			o.Emission = ( ( ( tex2D( _BloomPrePassTexture, localMyCustomExpression80.xy ) + ( _CustomFogColor * _CustomFogColorMultiplier ) ) * clampResult15 ) + ( temp_output_19_0 * ( _Color + staticSwitch105 ) ) ).rgb;
			o.Alpha = ( temp_output_19_0 * ( _Color.a + staticSwitch104 ) ).r;
			#ifdef QUEST_CUTOUT
				float staticSwitch88 = 1.0;
			#else
				float staticSwitch88 = step( ( _Cutout + -0.05 ) , tex2DNode118.a );
			#endif
			#ifdef _ENABLECUTOUT_ON
				float staticSwitch93 = staticSwitch88;
			#else
				float staticSwitch93 = 1.0;
			#endif
			clip( staticSwitch93 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Mobile/Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;1061.732;594.0329;1;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;117;-851.7568,336.0424;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;116;-667.1367,352.8883;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;112;-703.6768,517.1602;Inherit;False;Global;_CutoutTexOffset;_CutoutTexOffset;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;84;-506.3083,516.9818;Inherit;False;Property;_CutoutTextureScale;Cutout Texture Scale;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-460.9857,395.7652;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-258.7394,378.4606;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1645.702,-244.395;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;118;-143.1007,89.50362;Inherit;True;Global;_CutoutTex;_CutoutTex;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SurfaceDepthNode;52;-1627.142,-325.5986;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;56;-1654.702,49.60501;Inherit;False;Property;_FresnelVector;FresnelVector;6;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;85;-44.86014,272.9014;Inherit;False;Property;_Cutout;Cutout;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-1660.702,-103.3949;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1572.354,-175.576;Inherit;False;Property;_FogOffset;Fog Offset;3;0;Create;True;0;0;0;False;0;False;0;-6.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1318.702,-317.395;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1346.702,-206.395;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;102;103.4918,-366.439;Inherit;False;Property;_EdgeGlowColor;EdgeGlowColor;8;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;87;154.5165,147.9551;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;54;-1446.702,32.60502;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1168.355,-219.576;Inherit;False;Property;_FogScale;Fog Scale;4;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;391.1816,59.29944;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1459.232,436.9671;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;78;-1423.9,255.0037;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;57;-1218.702,7.605018;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-1171.355,-320.576;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;53;-1227.702,-108.395;Inherit;False;Property;_FogClamp;FogClamp;5;0;Create;True;0;0;0;False;0;False;0,0;0.1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1002.704,-118.395;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;17;-989.3557,-289.576;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;104;541.8748,38.22323;Inherit;False;Property;_EnableCutout;Enable Cutout;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;93;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;80;-1026.074,167.1799;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-621.3997,-318.4963;Inherit;False;Global;_CustomFogColorMultiplier;_CustomFogColorMultiplier;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;62;-604.3997,-491.4962;Inherit;False;Global;_CustomFogColor;_CustomFogColor;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;15;-765.0517,-314.6772;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-344.3996,-275.4962;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1;-547.0558,-173.6773;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;105;868.1436,-4.563362;Inherit;False;Property;_QuestCutout;QuestCutout;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;QUEST_CUTOUT;Toggle;2;Key0;Key1;Create;False;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;9;-383.5,32;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;90;90.0742,362.4798;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;124.4821,252.3572;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;89;83.07419,461.4798;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;101;95.06107,-45.71796;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;332.0742,342.4798;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;95;258.343,247.4648;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-354.0516,-343.6772;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-129.3996,-173.4963;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;86;404.0742,253.4798;Inherit;False;Constant;_One;One;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;280.2321,-83.5637;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-92.72454,-10.72379;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;280.0632,-189.8341;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;88;391.5403,150.9102;Inherit;False;Property;_QuestCutout;QuestCutout;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;QUEST_CUTOUT;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;92;533.0742,331.4798;Inherit;False;Property;_Keyword0;Keyword 0;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;88;False;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;110;-599.2229,186.5717;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;253.3633,26.234;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;94;838.2672,321.6958;Inherit;False;Property;_EnableCutout;Enable Cutout;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;93;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;93;707.7958,169.5029;Inherit;False;Property;_EnableCutout;Enable Cutout;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-616.8875,-245.6344;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;442.5,-166;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1539,-36;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/FogLighting;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;True;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;Mobile/Diffuse;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;2;Pragma;vertex vert;False;;Custom;Pragma;multi_compile_fog;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;116;0;117;0
WireConnection;114;0;116;0
WireConnection;114;1;112;0
WireConnection;113;0;114;0
WireConnection;113;1;84;0
WireConnection;118;1;113;0
WireConnection;58;0;52;0
WireConnection;58;1;59;0
WireConnection;60;0;11;0
WireConnection;60;1;61;0
WireConnection;87;0;118;4
WireConnection;87;1;85;0
WireConnection;54;1;56;1
WireConnection;54;2;56;2
WireConnection;54;3;56;3
WireConnection;103;0;87;0
WireConnection;103;1;102;0
WireConnection;57;0;54;0
WireConnection;16;0;58;0
WireConnection;16;1;60;0
WireConnection;55;0;53;1
WireConnection;55;1;57;0
WireConnection;17;0;16;0
WireConnection;17;1;12;0
WireConnection;104;0;103;0
WireConnection;80;0;78;0
WireConnection;80;1;121;0
WireConnection;15;0;17;0
WireConnection;15;1;55;0
WireConnection;15;2;53;2
WireConnection;64;0;62;0
WireConnection;64;1;65;0
WireConnection;1;1;80;0
WireConnection;105;1;104;0
WireConnection;90;0;85;0
WireConnection;96;0;85;0
WireConnection;101;0;9;0
WireConnection;101;1;105;0
WireConnection;91;0;90;0
WireConnection;91;1;89;0
WireConnection;95;0;96;0
WireConnection;95;1;118;4
WireConnection;19;0;15;0
WireConnection;63;0;1;0
WireConnection;63;1;64;0
WireConnection;18;0;19;0
WireConnection;18;1;101;0
WireConnection;100;0;9;4
WireConnection;100;1;104;0
WireConnection;14;0;63;0
WireConnection;14;1;15;0
WireConnection;88;1;95;0
WireConnection;88;0;86;0
WireConnection;92;1;89;0
WireConnection;92;0;91;0
WireConnection;51;0;19;0
WireConnection;51;1;100;0
WireConnection;94;1;89;0
WireConnection;94;0;92;0
WireConnection;93;1;86;0
WireConnection;93;0;88;0
WireConnection;20;0;14;0
WireConnection;20;1;18;0
WireConnection;0;2;20;0
WireConnection;0;9;51;0
WireConnection;0;10;93;0
WireConnection;0;11;94;0
ASEEND*/
//CHKSM=65DF1D21B7E9F5904EB55C04F8AE7AE4601BBA48