// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/ScreenDisplacementGB"
{
	Properties
	{
		_DisplacementIntensity("Displacement Intensity", Float) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_DisplacementTexture("DisplacementTexture", 2D) = "white" {}
		_CullMode("Cull Mode", Float) = 0
		[Toggle]_EnableFog("Enable Fog", Float) = 0
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		_TintColor("Tint Color", Color) = (0,0,0,0)
		_AddColor("Add Color", Color) = (0,0,0,0)
		_Cutout("Cutout", Float) = 0
		_CutoutTexScale("Cutout Texture Scale", Float) = 0
		_TimeScale("Time Scale", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+1" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite On
		Offset  1 , 1
		Blend One Zero
		
		GrabPass{ "_GrabTexture" }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.0
		#pragma multi_compile_instancing
		#pragma shader_feature ENABLE_CENTER_CUTOUT_GLOBAL
		#pragma shader_feature_local ENABLE_QUEST_OPTIMIZATIONS
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
			float eyeDepth;
			float3 worldPos;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _DisplacementTexture;
		uniform float4 _DisplacementTexture_ST;
		uniform float4 _TimeScale;
		uniform float _DisplacementIntensity;
		uniform float _EnableFog;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform float4 _TintColor;
		uniform float4 _AddColor;
		uniform float _CullMode;
		uniform float _Cutout;
		uniform sampler3D _CutoutTex;
		uniform float4 _CutoutTexOffset;
		uniform float _CutoutTexScale;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef ENABLE_CENTER_CUTOUT_GLOBAL
				float3 staticSwitch154 = ( ase_vertex3Pos * float3( 0,0,0 ) );
			#else
				float3 staticSwitch154 = ase_vertex3Pos;
			#endif
			v.vertex.xyz = staticSwitch154;
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
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 screenColor76 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ase_screenPosNorm.xy);
			float4 TransparentFog75 = screenColor76;
			float2 uv_DisplacementTexture = i.uv_texcoord * _DisplacementTexture_ST.xy + _DisplacementTexture_ST.zw;
			float mulTime159 = _Time.y * _TimeScale.x;
			float mulTime160 = _Time.y * _TimeScale.y;
			float2 appendResult162 = (float2(mulTime159 , mulTime160));
			float2 temp_output_163_0 = ( uv_DisplacementTexture + appendResult162 );
			float4 tex2DNode7 = tex2D( _DisplacementTexture, temp_output_163_0 );
			float temp_output_10_0 = ( i.vertexColor.a * tex2DNode7.a );
			float temp_output_14_0 = ( 1.0 - temp_output_10_0 );
			#ifdef ENABLE_QUEST_OPTIMIZATIONS
				float staticSwitch131 = ( _DisplacementIntensity * 4.0 );
			#else
				float staticSwitch131 = _DisplacementIntensity;
			#endif
			float clampResult33 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.1 , 1.0 );
			float4 DistortedFogUV91 = ( ase_screenPosNorm + float4( ( UnpackNormal( tex2D( _DisplacementTexture, temp_output_163_0 ) ) * ( staticSwitch131 * ( 1.0 - (( _EnableFog )?( clampResult33 ):( 0.0 )) ) ) * tex2DNode7.a * float3( float2( 1,1 ) ,  0.0 ) ) , 0.0 ) );
			float4 screenColor90 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,DistortedFogUV91.xy);
			float4 DistortedFog87 = screenColor90;
			float4 temp_output_16_0 = ( ( TransparentFog75 * temp_output_14_0 ) + ( ( ( DistortedFog87 * _TintColor ) + _AddColor ) * temp_output_10_0 ) + ( 0.0 * _CullMode ) );
			o.Emission = temp_output_16_0.rgb;
			float temp_output_46_0 = ( 1.0 - (( _EnableFog )?( clampResult33 ):( 0.0 )) );
			o.Alpha = ( temp_output_46_0 * ( ( (DistortedFog87).a * temp_output_10_0 ) + ( (TransparentFog75).a * temp_output_14_0 ) ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform134 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float CutoutTexture148 = tex3D( _CutoutTex, ( ( transform134 + _CutoutTexOffset ) * _CutoutTexScale ).xyz ).a;
			clip( step( _Cutout , CutoutTexture148 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Mobile/Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;6;1920;1005;631.738;796.948;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;25;-1217.924,-497.6698;Inherit;False;Property;_FogOffset;Fog Offset;5;0;Create;True;0;0;0;False;0;False;0;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;27;-1272.712,-647.6924;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1306.272,-425.4887;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1291.272,-566.4888;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-964.2722,-639.4888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-992.2722,-528.4888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-813.9241,-541.6698;Inherit;False;Property;_FogScale;Fog Scale;6;0;Create;True;0;0;0;False;0;False;0;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-816.9241,-642.6698;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-634.924,-611.6698;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;161;-1871.738,-20.948;Inherit;False;Property;_TimeScale;Time Scale;13;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;159;-1583.738,-9.947998;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-456.4233,-615.8202;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1567.094,219.8131;Inherit;False;Property;_DisplacementIntensity;Displacement Intensity;0;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;160;-1579.738,69.052;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;40;-307.7474,-606.0523;Inherit;False;Property;_EnableFog;Enable Fog;4;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;164;-1597.738,-141.948;Inherit;False;0;21;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-1332.267,299.9012;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;-1341.738,9.052002;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;21;-1593.345,-366.8123;Inherit;True;Property;_DisplacementTexture;DisplacementTexture;2;0;Create;True;0;0;0;False;0;False;None;ed354f366bf90a3428fd55788ad869f9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;163;-1201.738,-33.948;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;131;-1191.267,221.9012;Inherit;False;Property;_QuestOptimizations;Quest Optimizations;11;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_QUEST_OPTIMIZATIONS;Toggle;2;Key0;Key1;Create;True;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;119;-1039.417,321.9851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-971.2405,32.48672;Inherit;True;Property;_Sample;Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-974,-150;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;20;-867,-268.5;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-853.7818,227.8786;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;129;-537.5972,-252.7363;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-568.6021,-82.52392;Inherit;True;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-326,-225.5;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-202.3617,-213.4312;Inherit;False;DistortedFogUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;143;-724.334,750.7283;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1187.405,-1222.873;Inherit;False;91;DistortedFogUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;133;-714.6819,1220.676;Inherit;False;Global;_CutoutTexOffset;_CutoutTexOffset;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;134;-500.0491,939.4317;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;76;-860.9634,-1024.848;Inherit;False;Global;_GrabTexture;GrabTexture;11;0;Create;True;0;0;0;False;0;False;Object;-1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;90;-932.7574,-1278.924;Inherit;False;Global;_GrabScreen0;Grab Screen 0;11;0;Create;True;0;0;0;False;0;False;Instance;76;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-609.5792,-1022.969;Inherit;True;TransparentFog;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;9;-699.489,-235.7477;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;135;-382.6825,1129.676;Inherit;False;Property;_CutoutTexScale;Cutout Texture Scale;11;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-638.5604,-1281.868;Inherit;True;DistortedFog;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;136;-289.6825,1028.676;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-461.5297,-318.5449;Inherit;False;75;TransparentFog;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-329.505,-125.911;Inherit;False;87;DistortedFog;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;35;-580,132.5;Inherit;False;Property;_TintColor;Tint Color;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.6886792,0.6886792,0.6886792,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-319.2964,-53.79731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-72.68237,1095.676;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;99;-139.0003,-109.6179;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;138;108.703,1045.844;Inherit;True;Global;_CutoutTex;_CutoutTex;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;100;-197.6556,-301.5553;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-143.3493,-13.40844;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-327,62.5;Inherit;False;Property;_AddColor;Add Color;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;145.2679,-174.1254;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-234,-493.5;Inherit;False;Property;_CullMode;Cull Mode;3;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;271.2516,-190.1852;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;294.1218,-0.2992589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;156;298.8045,395.4398;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;408.5874,1050.463;Inherit;False;CutoutTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;293.3302,-87.62277;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;46;564.7577,-122.1837;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;444.7167,271.322;Inherit;False;148;CutoutTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;477.2303,-50.63501;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;542.1677,580.2057;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;72;492.9742,186.4556;Inherit;False;Property;_Cutout;Cutout;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;70.33344,-400.395;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;150.7885,-298.2381;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;411.8718,-217.5252;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;157;-250.5166,-396.8465;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;571.4486,-265.3241;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;150;697.6235,195.9214;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;737.0079,-63.46622;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformVariables;141;-936.682,926.676;Inherit;False;_Object2World;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;139;-717.6819,1071.676;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VectorFromMatrixNode;140;-669.6822,909.676;Inherit;False;Row;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;154;703.1677,430.2056;Inherit;False;Property;_CenterCutout;Center Cutout;20;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_CENTER_CUTOUT_GLOBAL;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;987.3613,-250.8968;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;820.1882,-217.2775;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;82;-1176.42,-1006.621;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;10;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;820.8806,-305.0161;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-700.5495,-392.104;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;284.1041,-473.5062;Inherit;True;Property;_TextureSample2;Texture Sample 2;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;153;601.221,-388.7672;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;152;263.7381,-560.3024;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1106.906,-295.484;Float;False;True;-1;4;ASEMaterialInspector;0;0;Unlit;Urki/ScreenDisplacementGB;False;False;False;False;True;True;True;True;True;True;False;False;False;False;True;True;True;False;False;False;False;Back;1;False;-1;0;False;-1;True;1;False;-1;1;False;-1;False;0;Custom;0.5;True;False;1;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;1;1;False;-1;0;False;-1;0;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;Mobile/Diffuse;1;-1;-1;-1;0;False;0;0;True;24;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;29;0;27;0
WireConnection;29;1;26;0
WireConnection;28;0;25;0
WireConnection;28;1;34;0
WireConnection;31;0;29;0
WireConnection;31;1;28;0
WireConnection;32;0;31;0
WireConnection;32;1;30;0
WireConnection;159;0;161;1
WireConnection;33;0;32;0
WireConnection;160;0;161;2
WireConnection;40;1;33;0
WireConnection;132;0;8;0
WireConnection;162;0;159;0
WireConnection;162;1;160;0
WireConnection;163;0;164;0
WireConnection;163;1;162;0
WireConnection;131;1;8;0
WireConnection;131;0;132;0
WireConnection;119;0;40;0
WireConnection;7;0;21;0
WireConnection;7;1;163;0
WireConnection;22;0;21;0
WireConnection;22;1;163;0
WireConnection;120;0;131;0
WireConnection;120;1;119;0
WireConnection;6;0;22;0
WireConnection;6;1;120;0
WireConnection;6;2;7;4
WireConnection;6;3;20;0
WireConnection;5;0;129;0
WireConnection;5;1;6;0
WireConnection;91;0;5;0
WireConnection;134;0;143;0
WireConnection;76;0;129;0
WireConnection;90;0;92;0
WireConnection;75;0;76;0
WireConnection;87;0;90;0
WireConnection;136;0;134;0
WireConnection;136;1;133;0
WireConnection;10;0;9;4
WireConnection;10;1;7;4
WireConnection;137;0;136;0
WireConnection;137;1;135;0
WireConnection;99;0;98;0
WireConnection;138;1;137;0
WireConnection;100;0;86;0
WireConnection;14;0;10;0
WireConnection;12;0;98;0
WireConnection;12;1;35;0
WireConnection;36;0;12;0
WireConnection;36;1;39;0
WireConnection;117;0;100;0
WireConnection;117;1;14;0
WireConnection;148;0;138;4
WireConnection;13;0;99;0
WireConnection;13;1;10;0
WireConnection;46;0;40;0
WireConnection;19;0;13;0
WireConnection;19;1;117;0
WireConnection;155;0;156;0
WireConnection;23;1;24;0
WireConnection;17;0;86;0
WireConnection;17;1;14;0
WireConnection;116;0;36;0
WireConnection;116;1;10;0
WireConnection;157;0;129;0
WireConnection;157;1;158;0
WireConnection;16;0;17;0
WireConnection;16;1;116;0
WireConnection;16;2;23;0
WireConnection;150;0;72;0
WireConnection;150;1;149;0
WireConnection;118;0;46;0
WireConnection;118;1;19;0
WireConnection;140;0;141;0
WireConnection;154;1;156;0
WireConnection;154;0;155;0
WireConnection;47;0;45;0
WireConnection;47;1;43;0
WireConnection;43;0;16;0
WireConnection;43;1;46;0
WireConnection;45;0;153;0
WireConnection;45;1;40;0
WireConnection;84;0;82;0
WireConnection;84;1;157;0
WireConnection;153;0;84;0
WireConnection;153;1;152;0
WireConnection;0;2;16;0
WireConnection;0;9;118;0
WireConnection;0;10;150;0
WireConnection;0;11;154;0
ASEEND*/
//CHKSM=4F0C6D351057B1F90DC0D56BBA94CE5ABF681DCC