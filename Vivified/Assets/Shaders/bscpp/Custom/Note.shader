// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Note"
{
	Properties
	{
		[Header(Color and Fog)]_Color("Color", Color) = (0,0,0,0)
		_ColorIntensity("Color Intensity", Float) = 0
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		[Header(Lighting and Fresnel)]_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_CullMode("Cull Mode", Float) = 0
		_RimFresnel("Rim Fresnel", Float) = 0
		_RimIntensity("Rim Intensity", Float) = 0
		[Header(Cutout and Debris)]_Cutout("Cutout", Float) = 0
		_CutoutTexScale("Cutout Texture Scale", Float) = 0
		_CutoutEdge("Cutout Edge", Float) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HideInInspector]_SlicePos("_SlicePos", Vector) = (0,0,0,0)
		[HideInInspector]_TransformOffset("_TransformOffset", Vector) = (0,0,0,0)
		[Toggle]_UseGlowEdge("Use Glow Edge", Float) = 1
		[Toggle]_EnablePlaneCut("Enable PlaneCut", Float) = 1
		_SliceEdge("Slice Edge", Float) = 0
		_CutPlane("_CutPlane", Vector) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma shader_feature ENABLE_CENTER_CUTOUT_GLOBAL
		#pragma shader_feature QUEST_CUTOUT
		#pragma shader_feature MAIN_EFFECT_ENABLED
		#include "slice.cginc"
		#pragma surface surf Standard keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float eyeDepth;
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
			half ASEVFace : VFACE;
		};

		uniform float _Cutout;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform float _ColorIntensity;
		uniform float4 _Color;
		uniform float _CullMode;
		uniform float _CustomFogColorMultiplier;
		uniform float4 _CustomFogColor;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _StereoCameraEyeOffset;
		uniform float _CustomFogGammaCorrection;
		uniform float _RimFresnel;
		uniform float _RimIntensity;
		uniform sampler3D _CutoutTex;
		uniform float4 _CutoutTexOffset;
		uniform float _CutoutTexScale;
		uniform float _UseGlowEdge;
		uniform float4 _CutPlane;
		uniform half3 _SlicePos;
		uniform half3 _TransformOffset;
		uniform float _SliceEdge;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _CutoutEdge;
		uniform float _EnablePlaneCut;
		uniform float _Cutoff = 0.5;


		float4 fogcorrection189( float4 input, float offset )
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


		float4 GammaCorrection180( float4 input, float GammaValue )
		{
			float4 clr = input;
			clr = log2(clr);
			clr *= GammaValue;
			clr = exp2(clr);
			return clr;
		}


		float3 MyCustomExpression122( half4 CutPlane, float3 SlicePos, float3 localpos, float3 TransformOffset, float SliceEdge )
		{
			return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge);
		}


		float3 MyCustomExpression101( half4 CutPlane, float3 SlicePos, float3 localpos, float3 TransformOffset, float SliceEdge )
		{
			return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 temp_output_142_0 = ( ase_vertex3Pos * ( 1.0 - _Cutout ) );
			#ifdef QUEST_CUTOUT
				float3 staticSwitch136 = temp_output_142_0;
			#else
				float3 staticSwitch136 = ase_vertex3Pos;
			#endif
			#ifdef ENABLE_CENTER_CUTOUT_GLOBAL
				float3 staticSwitch185 = ( temp_output_142_0 * float3( 0,0,0 ) );
			#else
				float3 staticSwitch185 = staticSwitch136;
			#endif
			v.vertex.xyz = staticSwitch185;
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float clampResult84 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.0 , 1.0 );
			float temp_output_61_0 = ( 1.0 - clampResult84 );
			float4 temp_output_16_0 = ( ( _ColorIntensity * _Color ) + ( _CullMode * 0.0 ) );
			o.Albedo = ( temp_output_61_0 * temp_output_16_0 ).rgb;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 input189 = ase_screenPosNorm;
			float offset189 = _StereoCameraEyeOffset;
			float4 localfogcorrection189 = fogcorrection189( input189 , offset189 );
			float4 input180 = ( ( _CustomFogColorMultiplier * _CustomFogColor ) + tex2D( _BloomPrePassTexture, localfogcorrection189.xy ) );
			float GammaValue180 = _CustomFogGammaCorrection;
			float4 localGammaCorrection180 = GammaCorrection180( input180 , GammaValue180 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV28 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode28 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV28, _RimFresnel ) );
			float4 switchResult159 = (((i.ASEVFace>0)?(( fresnelNode28 * _RimIntensity * _Color * i.ASEVFace )):(temp_output_16_0)));
			#ifdef MAIN_EFFECT_ENABLED
				float4 staticSwitch162 = _Color;
			#else
				float4 staticSwitch162 = ( _Color + _Color.a );
			#endif
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform176 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float4 tex3DNode177 = tex3D( _CutoutTex, ( ( transform176 + _CutoutTexOffset ) * _CutoutTexScale ).xyz );
			#ifdef QUEST_CUTOUT
				float staticSwitch144 = 0.0;
			#else
				float staticSwitch144 = step( tex3DNode177.a , _Cutout );
			#endif
			float3 temp_cast_5 = (0.0).xxx;
			float4 CutPlane122 = _CutPlane;
			float3 SlicePos122 = _SlicePos;
			float3 localpos122 = ase_vertex3Pos;
			float3 TransformOffset122 = _TransformOffset;
			float temp_output_197_0 = ( _CutPlane.w + ( _Cutout * -0.25 ) );
			float SliceEdge122 = ( _SliceEdge + temp_output_197_0 );
			float3 localMyCustomExpression122 = MyCustomExpression122( CutPlane122 , SlicePos122 , localpos122 , TransformOffset122 , SliceEdge122 );
			o.Emission = ( ( localGammaCorrection180 * clampResult84 ) + ( temp_output_61_0 * ( switchResult159 + ( staticSwitch162 * staticSwitch144 ) + ( float4( (( _UseGlowEdge )?( localMyCustomExpression122 ):( temp_cast_5 )) , 0.0 ) * staticSwitch162 ) ) ) ).xyz;
			o.Metallic = _Metallic;
			float switchResult160 = (((i.ASEVFace>0)?(( temp_output_61_0 * _Smoothness * ( 1.0 - fresnelNode28 ) )):(0.8)));
			o.Smoothness = switchResult160;
			float fresnelNdotV25 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode25 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV25, 1.0 ) );
			float switchResult152 = (((i.ASEVFace>0)?(( 1.0 - fresnelNode25 )):(-1.0)));
			o.Occlusion = switchResult152;
			float3 temp_cast_9 = (0.0).xxx;
			o.Alpha = ( ( 0.0 + staticSwitch144 ) + (( _UseGlowEdge )?( localMyCustomExpression122 ):( temp_cast_9 )) ).x;
			#ifdef QUEST_CUTOUT
				float staticSwitch135 = (float)1;
			#else
				float staticSwitch135 = step( ( _Cutout - _CutoutEdge ) , tex3DNode177.a );
			#endif
			float3 temp_cast_12 = (staticSwitch135).xxx;
			float3 temp_cast_13 = (0.0).xxx;
			float4 CutPlane101 = _CutPlane;
			float3 SlicePos101 = _SlicePos;
			float3 localpos101 = ase_vertex3Pos;
			float3 TransformOffset101 = _TransformOffset;
			float SliceEdge101 = temp_output_197_0;
			float3 localMyCustomExpression101 = MyCustomExpression101( CutPlane101 , SlicePos101 , localpos101 , TransformOffset101 , SliceEdge101 );
			clip( ( temp_cast_12 - (( _EnablePlaneCut )?( localMyCustomExpression101 ):( temp_cast_13 )) ).x - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;825.238;915.557;1;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;128;-1321,39;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-473,199;Inherit;False;Property;_Cutout;Cutout;9;1;[Header];Create;True;1;Cutout and Debris;0;0;False;0;False;0;0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;176;-1113,151;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;172;-1337,503;Inherit;False;Global;_CutoutTexOffset;_CutoutTexOffset;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-889,263;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;32.26196,422.943;Inherit;False;2;2;0;FLOAT;0.25;False;1;FLOAT;-0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-985,359;Inherit;False;Property;_CutoutTexScale;Cutout Texture Scale;10;0;Create;False;0;0;0;False;0;False;0;0.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;146;408.0649,247.5331;Inherit;False;Property;_CutPlane;_CutPlane;19;0;Create;True;0;0;0;False;0;False;0,0,0,0;1.05,-4.07,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;124;-433,471;Inherit;False;Property;_SliceEdge;Slice Edge;18;0;Create;True;0;0;0;False;0;False;0;-0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-645.4195,-440.352;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-681,327;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SurfaceDepthNode;93;-622.9256,-523.9626;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-620.0281,-289.6024;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-563.7146,-363.1763;Inherit;False;Property;_FogOffset;Fog Offset;2;0;Create;True;0;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;197;647.262,362.943;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-60,-62.5;Inherit;False;Property;_CullMode;Cull Mode;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;113;629.1307,717.3835;Half;False;Property;_TransformOffset;_TransformOffset;15;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;111;343.1307,427.3835;Half;False;Property;_SlicePos;_SlicePos;14;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-338.0634,-393.9952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;177;-521,279;Inherit;True;Global;_CutoutTex;_CutoutTex;20;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-135.541,-309.9517;Inherit;False;Property;_ColorIntensity;Color Intensity;1;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;94;-127.9752,-697.0157;Float;True;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;190;-140.547,-777.943;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;13;-134,-232.5;Inherit;False;Property;_Color;Color;0;1;[Header];Create;True;1;Color and Fog;0;0;False;0;False;0,0,0,0;0.1411761,0.1411761,0.1411761,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-680.0064,-111.1983;Inherit;False;Property;_RimFresnel;Rim Fresnel;7;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;112;304.1307,579.3835;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-310.0634,-504.9951;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;161;662.0042,475.6026;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;628,56.5;Inherit;False;Constant;_Glow;Glow;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;47;-233,119;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;87;453.463,-597.0853;Inherit;False;Global;_CustomFogColor;_CustomFogColor;13;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;28;-458.4724,-192.081;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;128,-180.5;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;31;47.90464,9.048306;Inherit;False;Property;_RimIntensity;Rim Intensity;8;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;382.4302,-672.2961;Inherit;False;Global;_CustomFogColorMultiplier;_CustomFogColorMultiplier;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;189;244.071,-590.1716;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-162.7152,-508.176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FaceVariableNode;127;26.6122,79.89706;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;163;66.69775,-365.481;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;118;879.1307,154.3835;Inherit;False;Constant;_Zero;Zero;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-159.7152,-407.1762;Inherit;False;Property;_FogScale;Fog Scale;3;0;Create;True;0;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;92.95556,-84.93723;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;122;824.1307,428.3835;Inherit;False;return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge)@;3;Create;5;True;CutPlane;FLOAT4;0,0,0,0;In;;Half;False;True;SlicePos;FLOAT3;0,0,0;In;;Inherit;False;True;localpos;FLOAT3;0,0,0;In;;Inherit;False;True;TransformOffset;FLOAT3;0,0,0;In;;Inherit;False;True;SliceEdge;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;144;111.5874,128.6813;Inherit;False;Property;_Keyword1;Keyword 1;19;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;135;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;83;19.28499,-477.1761;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-433.738,544.9427;Inherit;False;Property;_CutoutEdge;Cutout Edge;11;0;Create;True;0;0;0;False;0;False;0;0.0175;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;681.882,-512.1245;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;300,-183.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;59;446.9308,-422.3803;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;12;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;162;168.6978,-287.481;Inherit;False;Property;_MainEffectEnabled;Main Effect Enabled;7;0;Create;True;0;0;0;False;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Create;False;False;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;184;1128.083,407.1872;Inherit;False;Property;_UseGlowEdge;Use Glow Edge;16;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;294.459,-81.95169;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;816.1219,-382.2389;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;229.2534,246.8194;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;1334.131,403.3835;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;84;197.9641,-487.9978;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;159;547.0042,-173.8974;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;181;392.7571,-758.8277;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;139;1112.486,677.0839;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;552.576,140.9096;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;140;1126.54,527.6143;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;180;981.4088,-294.7979;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;101;804.1307,266.3835;Inherit;False;return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge)@;3;Create;5;True;CutPlane;FLOAT4;0,0,0,0;In;;Half;False;True;SlicePos;FLOAT3;0,0,0;In;;Inherit;False;True;localpos;FLOAT3;0,0,0;In;;Inherit;False;True;TransformOffset;FLOAT3;0,0,0;In;;Inherit;False;True;SliceEdge;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;75;-222.2893,-80.82964;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;143;733.0634,188.4332;Inherit;False;Constant;_One;One;20;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.OneMinusNode;61;441.3156,-247.3914;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;25;-477.6497,5.102649;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;864.519,-86.5728;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;496.4667,-14.49533;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;1325.833,581.27;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;52;425.7057,139.3465;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;135;1244.519,115.6982;Inherit;False;Property;_QuestCutout;Quest Cutout;19;0;Create;True;0;0;0;False;0;False;0;0;0;False;QUEST_CUTOUT;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;828.459,58.04828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;183;1139.083,209.1872;Inherit;False;Property;_EnablePlaneCut;Enable PlaneCut;17;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;26;-203.7434,-8.195133;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;984.2014,-68.99077;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;1266.897,-220.6335;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;1150.943,-106.3973;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;136;1470.194,490.5663;Inherit;False;Property;_Keyword0;Keyword 0;19;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;135;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;1541.083,611.1872;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;119;1534.877,149.1012;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;725.3547,-240.2489;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;173;-1289,183;Inherit;False;Row;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwitchByFaceNode;152;1485.004,39.60263;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformVariables;170;-1561,199;Inherit;False;_Object2World;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;169;-1337,343;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;8;493,-82.5;Inherit;False;Property;_Metallic;Metallic;4;1;[Header];Create;True;1;Lighting and Fresnel;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;1104.131,63.38348;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwitchByFaceNode;160;1491.004,-52.8974;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;185;1702.083,461.1872;Inherit;False;Property;_CenterCutout;Center Cutout;20;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_CENTER_CUTOUT_GLOBAL;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;164;-27.3022,311.019;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;1680.514,-166.2385;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;24;2115.694,-99.03145;Float;False;True;-1;7;ASEMaterialInspector;0;0;Standard;Urki/Note;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;13;-1;-1;-1;0;False;0;0;True;2;-1;0;False;-1;1;Include;slice.cginc;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;176;0;128;0
WireConnection;175;0;176;0
WireConnection;175;1;172;0
WireConnection;198;0;35;0
WireConnection;167;0;175;0
WireConnection;167;1;168;0
WireConnection;197;0;146;4
WireConnection;197;1;198;0
WireConnection;79;0;76;0
WireConnection;79;1;85;0
WireConnection;177;1;167;0
WireConnection;80;0;93;0
WireConnection;80;1;77;0
WireConnection;161;0;124;0
WireConnection;161;1;197;0
WireConnection;47;0;177;4
WireConnection;47;1;35;0
WireConnection;28;3;30;0
WireConnection;14;0;17;0
WireConnection;14;1;13;0
WireConnection;189;0;94;0
WireConnection;189;1;190;0
WireConnection;82;0;80;0
WireConnection;82;1;79;0
WireConnection;163;0;13;0
WireConnection;163;1;13;4
WireConnection;4;0;2;0
WireConnection;122;0;146;0
WireConnection;122;1;111;0
WireConnection;122;2;112;0
WireConnection;122;3;113;0
WireConnection;122;4;161;0
WireConnection;144;1;47;0
WireConnection;144;0;11;0
WireConnection;83;0;82;0
WireConnection;83;1;81;0
WireConnection;86;0;88;0
WireConnection;86;1;87;0
WireConnection;16;0;14;0
WireConnection;16;1;4;0
WireConnection;59;1;189;0
WireConnection;162;1;163;0
WireConnection;162;0;13;0
WireConnection;184;0;118;0
WireConnection;184;1;122;0
WireConnection;27;0;28;0
WireConnection;27;1;31;0
WireConnection;27;2;13;0
WireConnection;27;3;127;0
WireConnection;89;0;86;0
WireConnection;89;1;59;0
WireConnection;51;0;35;0
WireConnection;51;1;188;0
WireConnection;125;0;184;0
WireConnection;125;1;162;0
WireConnection;84;0;83;0
WireConnection;159;0;27;0
WireConnection;159;1;16;0
WireConnection;139;0;35;0
WireConnection;49;0;162;0
WireConnection;49;1;144;0
WireConnection;180;0;89;0
WireConnection;180;1;181;0
WireConnection;101;0;146;0
WireConnection;101;1;111;0
WireConnection;101;2;112;0
WireConnection;101;3;113;0
WireConnection;101;4;197;0
WireConnection;75;0;28;0
WireConnection;61;0;84;0
WireConnection;50;0;159;0
WireConnection;50;1;49;0
WireConnection;50;2;125;0
WireConnection;142;0;140;0
WireConnection;142;1;139;0
WireConnection;52;0;51;0
WireConnection;52;1;177;4
WireConnection;135;1;52;0
WireConnection;135;0;143;0
WireConnection;48;0;11;0
WireConnection;48;1;144;0
WireConnection;183;0;118;0
WireConnection;183;1;101;0
WireConnection;26;0;25;0
WireConnection;68;0;61;0
WireConnection;68;1;9;0
WireConnection;68;2;75;0
WireConnection;66;0;180;0
WireConnection;66;1;84;0
WireConnection;65;0;61;0
WireConnection;65;1;50;0
WireConnection;136;1;140;0
WireConnection;136;0;142;0
WireConnection;186;0;142;0
WireConnection;119;0;135;0
WireConnection;119;1;183;0
WireConnection;64;0;61;0
WireConnection;64;1;16;0
WireConnection;173;0;170;0
WireConnection;152;0;26;0
WireConnection;116;0;48;0
WireConnection;116;1;184;0
WireConnection;160;0;68;0
WireConnection;185;1;136;0
WireConnection;185;0;186;0
WireConnection;164;0;124;0
WireConnection;69;0;66;0
WireConnection;69;1;65;0
WireConnection;24;0;64;0
WireConnection;24;2;69;0
WireConnection;24;3;8;0
WireConnection;24;4;160;0
WireConnection;24;5;152;0
WireConnection;24;9;116;0
WireConnection;24;10;119;0
WireConnection;24;11;185;0
ASEEND*/
//CHKSM=564FC7B79F05EB810CADE492323298605A93A1BE