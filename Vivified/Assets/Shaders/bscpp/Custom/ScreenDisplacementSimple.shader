// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/ScreenDisplacementSimple"
{
	Properties
	{
		_DisplacementIntensity("Displacement Intensity", Float) = 0
		_DisplacementTexture("DisplacementTexture", 2D) = "white" {}
		_CullMode("Cull Mode", Float) = 0
		[Toggle]_EnableFog("Enable Fog", Float) = 1
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		_TintColor("Tint Color", Color) = (0,0,0,0)
		_AddColor("Add Color", Color) = (0,0,0,0)
		[HideInInspector]_Cutout("Cutout", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite On
		Offset  1 , 1
		Blend One Zero
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma multi_compile_instancing
		#pragma shader_feature ENABLE_QUEST_OPTIMIZATIONS
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float eyeDepth;
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

		uniform float _Cutout;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _EnableFog;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform float _CustomFogGammaCorrection;
		uniform sampler2D _DisplacementTexture;
		uniform float4 _DisplacementTexture_ST;
		uniform float _DisplacementIntensity;
		uniform float4 _TintColor;
		uniform float4 _AddColor;
		uniform float _CullMode;


		float2 MyCustomExpression74( float2 input )
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


		float4 GammaCorrection143( float4 input, float GammaValue )
		{
			float4 clr = input;
			clr = log2(clr);
			clr *= GammaValue;
			clr = exp2(clr);
			return clr;
		}


		float2 MyCustomExpression93( float2 input )
		{
			#ifdef UNITY_UV_STARTS_AT_TOP
			{
			}
			#else
			{
				input.y = 1 - input.y;
			}
			#endif
			return input;
		}


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float temp_output_73_0 = ( 1.0 - _Cutout );
			v.vertex.xyz = ( ase_vertex3Pos * temp_output_73_0 );
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
			float2 input74 = ase_screenPosNorm.xy;
			float2 localMyCustomExpression74 = MyCustomExpression74( input74 );
			float clampResult33 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.1 , 1.0 );
			float4 input143 = ( tex2D( _BloomPrePassTexture, localMyCustomExpression74 ) * float4( 1,1,1,0 ) );
			float GammaValue143 = _CustomFogGammaCorrection;
			float4 localGammaCorrection143 = GammaCorrection143( input143 , GammaValue143 );
			float4 TransparentFog75 = localGammaCorrection143;
			float2 uv_DisplacementTexture = i.uv_texcoord * _DisplacementTexture_ST.xy + _DisplacementTexture_ST.zw;
			float4 tex2DNode7 = tex2D( _DisplacementTexture, uv_DisplacementTexture );
			float temp_output_73_0 = ( 1.0 - _Cutout );
			#ifdef ENABLE_QUEST_OPTIMIZATIONS
				float staticSwitch109 = 1.0;
			#else
				float staticSwitch109 = temp_output_73_0;
			#endif
			float temp_output_10_0 = ( i.vertexColor.a * tex2DNode7.a * staticSwitch109 );
			float temp_output_14_0 = ( 1.0 - temp_output_10_0 );
			float4 DistortedFogUV91 = ( ase_screenPosNorm + float4( ( UnpackNormal( tex2D( _DisplacementTexture, uv_DisplacementTexture ) ) * ( ( 3.0 * _DisplacementIntensity ) * ( 1.0 - (( _EnableFog )?( clampResult33 ):( 0.0 )) ) ) * tex2DNode7.a * float3( float2( 1,1 ) ,  0.0 ) ) , 0.0 ) );
			float2 input93 = DistortedFogUV91.xy;
			float2 localMyCustomExpression93 = MyCustomExpression93( input93 );
			float4 tex2DNode89 = tex2D( _BloomPrePassTexture, localMyCustomExpression93 );
			float4 DistortedFog87 = ( ( ( tex2DNode89.r + tex2DNode89.g + tex2DNode89.b ) / 3.0 ) * float4(1,1,1,0) );
			float3 hsvTorgb141 = RGBToHSV( _TintColor.rgb );
			float3 hsvTorgb142 = HSVToRGB( float3(hsvTorgb141.x,( 1.75 * hsvTorgb141.y ),hsvTorgb141.z) );
			float temp_output_46_0 = ( 1.0 - (( _EnableFog )?( clampResult33 ):( 0.0 )) );
			o.Emission = ( ( tex2D( _BloomPrePassTexture, localMyCustomExpression74 ) * (( _EnableFog )?( clampResult33 ):( 0.0 )) ) + ( ( ( TransparentFog75 * temp_output_14_0 ) + ( ( ( DistortedFog87 * float4( hsvTorgb142 , 0.0 ) ) + saturate( _AddColor ) ) * temp_output_10_0 ) + ( 0.0 * _CullMode ) ) * temp_output_46_0 ) ).rgb;
			o.Alpha = ( temp_output_46_0 * ( ( (DistortedFog87).w * temp_output_10_0 ) + ( (TransparentFog75).w * temp_output_14_0 ) ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;992.3051;807.145;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;25;-1217.924,-497.6698;Inherit;False;Property;_FogOffset;Fog Offset;5;0;Create;True;0;0;0;False;0;False;0;-1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;27;-1272.712,-647.6924;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1306.272,-425.4887;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1291.272,-566.4888;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-964.2722,-639.4888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-992.2722,-528.4888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-813.9241,-541.6698;Inherit;False;Property;_FogScale;Fog Scale;6;0;Create;True;0;0;0;False;0;False;0;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-816.9241,-642.6698;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-634.924,-611.6698;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-456.4233,-615.8202;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;40;-307.7474,-606.0523;Inherit;False;Property;_EnableFog;Enable Fog;4;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1221.094,234.8131;Inherit;False;Property;_DisplacementIntensity;Displacement Intensity;0;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-988.3051,225.355;Inherit;False;2;2;0;FLOAT;3;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;119;-1050.417,318.9851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;21;-1243.345,-25.81232;Inherit;True;Property;_DisplacementTexture;DisplacementTexture;2;0;Create;True;0;0;0;False;0;False;None;ed354f366bf90a3428fd55788ad869f9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector2Node;20;-867,-268.5;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;22;-974,-150;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-971.2405,32.48672;Inherit;True;Property;_Sample;Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-853.7818,227.8786;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;129;-537.5972,-252.7363;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-568.6021,-82.52392;Inherit;True;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-326,-225.5;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-202.3617,-213.4312;Inherit;False;DistortedFogUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1004.47,-1303.959;Inherit;False;91;DistortedFogUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;82;-1283.591,-1031.998;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;10;0;Create;True;0;0;0;False;0;False;None;;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CustomExpressionNode;93;-790.1683,-1293.791;Inherit;False;#ifdef UNITY_UV_STARTS_AT_TOP${$}$#else${$	input.y = 1 - input.y@$}$#endif$return input@;2;Create;1;True;input;FLOAT2;0,0;In;;Inherit;False;My Custom Expression;True;False;0;;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;89;-581.0565,-1332.193;Inherit;True;Property;_TextureSample3;Texture Sample 3;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-228.6802,-1278.751;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-825,341.5;Inherit;False;Property;_TintColor;Tint Color;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.5019608,0.5019608,0.7843137;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;74;-136.0991,-406.6768;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;2;Create;1;True;input;FLOAT2;0,0;In;;Inherit;False;My Custom Expression;True;False;0;;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;132;-132.8047,-1160.145;Inherit;False;Constant;_g;g;11;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;97;-110.868,-1274.99;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;38.61618,-1278.987;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;1,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-45.82734,183.3139;Inherit;False;Property;_Cutout;Cutout;9;1;[HideInInspector];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;141;-621.3051,354.355;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;83;-1030.234,-1030.915;Inherit;True;Property;_TextureSample1;Texture Sample 1;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;110;299.7168,100.7782;Inherit;False;Constant;_One;One;12;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-731.3027,-1026.529;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;73;80.2669,198.4347;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-397.3051,403.355;Inherit;False;2;2;0;FLOAT;1.75;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;200.5247,-1301.312;Inherit;True;DistortedFog;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-1014.631,-1119.66;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;143;-590.9792,-1032.63;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.HSVToRGBNode;142;-262.3051,365.355;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;39;-324,72.5;Inherit;False;Property;_AddColor;Add Color;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.125,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;109;458.8882,124.5913;Inherit;False;Property;_QuestOptimizations;Quest Optimizations;11;0;Create;True;0;0;0;False;0;False;0;0;0;False;ENABLE_QUEST_OPTIMIZATIONS;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-329.505,-125.911;Inherit;False;87;DistortedFog;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;9;-699.489,-235.7477;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-319.2964,-53.79731;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;145.2679,-174.1254;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;134;-109.3051,71.35498;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-358.6812,-1064.16;Inherit;True;TransparentFog;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-461.5297,-318.5449;Inherit;False;75;TransparentFog;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;14;-143.3493,-13.40844;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;271.2516,-190.1852;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-234,-493.5;Inherit;False;Property;_CullMode;Cull Mode;3;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;411.8718,-217.5252;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;100;-197.6556,-301.5553;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;150.7885,-298.2381;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;99;-139.0003,-109.6179;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;74.33344,-394.395;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;414.5189,-464.8119;Inherit;True;Property;_TextureSample2;Texture Sample 2;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;16;572.4486,-259.3241;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;293.3302,-87.62277;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;46;559.7577,-147.1837;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;294.1218,-0.2992589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;477.2303,-50.63501;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;760.4147,-234.6662;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;112;55.31952,384.0285;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;748.0657,-336.533;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;743.0079,-71.46622;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;938.4556,-258.5043;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;297.1172,344.2817;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1106.906,-295.484;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/ScreenDisplacementSimple;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;False;False;False;False;Back;1;False;-1;0;False;-1;True;1;False;-1;1;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;1;1;False;-1;0;False;-1;0;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;1;-1;-1;-1;0;False;0;0;True;24;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;29;0;27;0
WireConnection;29;1;26;0
WireConnection;28;0;25;0
WireConnection;28;1;34;0
WireConnection;31;0;29;0
WireConnection;31;1;28;0
WireConnection;32;0;31;0
WireConnection;32;1;30;0
WireConnection;33;0;32;0
WireConnection;40;1;33;0
WireConnection;135;1;8;0
WireConnection;119;0;40;0
WireConnection;22;0;21;0
WireConnection;7;0;21;0
WireConnection;120;0;135;0
WireConnection;120;1;119;0
WireConnection;6;0;22;0
WireConnection;6;1;120;0
WireConnection;6;2;7;4
WireConnection;6;3;20;0
WireConnection;5;0;129;0
WireConnection;5;1;6;0
WireConnection;91;0;5;0
WireConnection;93;0;92;0
WireConnection;89;0;82;0
WireConnection;89;1;93;0
WireConnection;96;0;89;1
WireConnection;96;1;89;2
WireConnection;96;2;89;3
WireConnection;74;0;129;0
WireConnection;97;0;96;0
WireConnection;130;0;97;0
WireConnection;130;1;132;0
WireConnection;141;0;35;0
WireConnection;83;0;82;0
WireConnection;83;1;74;0
WireConnection;131;0;83;0
WireConnection;73;0;72;0
WireConnection;137;1;141;2
WireConnection;87;0;130;0
WireConnection;143;0;131;0
WireConnection;143;1;144;0
WireConnection;142;0;141;0
WireConnection;142;1;137;0
WireConnection;142;2;141;3
WireConnection;109;1;73;0
WireConnection;109;0;110;0
WireConnection;10;0;9;4
WireConnection;10;1;7;4
WireConnection;10;2;109;0
WireConnection;12;0;98;0
WireConnection;12;1;142;0
WireConnection;134;0;39;0
WireConnection;75;0;143;0
WireConnection;14;0;10;0
WireConnection;36;0;12;0
WireConnection;36;1;134;0
WireConnection;116;0;36;0
WireConnection;116;1;10;0
WireConnection;100;0;86;0
WireConnection;17;0;86;0
WireConnection;17;1;14;0
WireConnection;99;0;98;0
WireConnection;23;1;24;0
WireConnection;84;0;82;0
WireConnection;84;1;74;0
WireConnection;16;0;17;0
WireConnection;16;1;116;0
WireConnection;16;2;23;0
WireConnection;13;0;99;0
WireConnection;13;1;10;0
WireConnection;46;0;40;0
WireConnection;117;0;100;0
WireConnection;117;1;14;0
WireConnection;19;0;13;0
WireConnection;19;1;117;0
WireConnection;43;0;16;0
WireConnection;43;1;46;0
WireConnection;45;0;84;0
WireConnection;45;1;40;0
WireConnection;118;0;46;0
WireConnection;118;1;19;0
WireConnection;47;0;45;0
WireConnection;47;1;43;0
WireConnection;113;0;112;0
WireConnection;113;1;73;0
WireConnection;0;2;47;0
WireConnection;0;9;118;0
WireConnection;0;11;113;0
ASEEND*/
//CHKSM=71F0461FD0F3396B1319414FBE1B441C9D0D90DB