// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/Spectrogram"
{
	Properties
	{
		_DataTex("_DataTex", 2D) = "black" {}
		_Color("Color", Color) = (0,0,0,0)
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		_FogClamp("FogClamp", Vector) = (0,0,0,0)
		_SpectrogramPeak("Spectrogram Peak", Float) = 0
		_SpectrogramOffset("Spectrogram Offset", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
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
		#pragma vertex vert
		#pragma multi_compile_fog
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float eyeDepth;
		};

		uniform sampler2D _DataTex;
		uniform float4 _DataTex_ST;
		uniform float _SpectrogramPeak;
		uniform float _SpectrogramOffset;
		uniform float4 _CustomFogColor;
		uniform float _CustomFogColorMultiplier;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _StereoCameraEyeOffset;
		uniform float _CustomFogGammaCorrection;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform float2 _FogClamp;
		uniform float4 _Color;


		float3 DatatoVertex102( float Data, float3 Vert, float peak, float offset )
		{
			float3 v = Vert;
			v.z -= offset;
			v.z += Data * peak;
			return v;
		}


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


		float4 fogcorrection108( float4 input, float offset )
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


		float4 GammaCorrection107( float4 input, float GammaValue )
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
			float2 uv_DataTex = v.texcoord * _DataTex_ST.xy + _DataTex_ST.zw;
			float4 tex2DNode81 = tex2Dlod( _DataTex, float4( uv_DataTex, 0, 0.0) );
			float Data102 = tex2DNode81.r;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 Vert102 = ase_vertex3Pos;
			float peak102 = _SpectrogramPeak;
			float offset102 = _SpectrogramOffset;
			float3 localDatatoVertex102 = DatatoVertex102( Data102 , Vert102 , peak102 , offset102 );
			v.vertex.xyz = localDatatoVertex102;
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
			float4 input108 = ase_grabScreenPosNorm;
			float offset108 = _StereoCameraEyeOffset;
			float4 localfogcorrection108 = fogcorrection108( input108 , offset108 );
			float4 input107 = tex2D( _BloomPrePassTexture, localfogcorrection108.xy );
			float GammaValue107 = _CustomFogGammaCorrection;
			float4 localGammaCorrection107 = GammaCorrection107( input107 , GammaValue107 );
			float clampResult15 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , _FogClamp.x , _FogClamp.y );
			float temp_output_19_0 = ( 1.0 - clampResult15 );
			o.Emission = ( ( ( ( _CustomFogColor * _CustomFogColorMultiplier ) + localGammaCorrection107 ) * clampResult15 ) + ( temp_output_19_0 * _Color ) ).xyz;
			o.Alpha = ( temp_output_19_0 * _Color.a );
		}

		ENDCG
	}
	Fallback "Mobile/Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;24;1920;987;1584.338;483.322;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;11;-1337.5,-168;Inherit;False;Property;_FogOffset;Fog Offset;4;0;Create;True;0;0;0;False;0;False;0;0.5151;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1410.848,-236.819;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-1425.848,-95.81897;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;52;-1392.288,-318.0226;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1111.848,-198.819;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1083.848,-309.819;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;78;-768.348,4.681;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;109;-802.147,183.7923;Inherit;False;Global;_StereoCameraEyeOffset;_StereoCameraEyeOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-936.5,-313;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;108;-460.5289,-102.4364;Inherit;False;			#ifdef UNITY_UV_STARTS_AT_TOP$			#else$				input.y = 1 - input.y@$			#endif$			#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)$$				if (unity_StereoEyeIndex > 0)$				{$					input.x -= 0.5@$					input.x += offset@$				}$				input.x *=2@$			#endif$			return input@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;fog correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-933.5,-212;Inherit;False;Property;_FogScale;Fog Scale;5;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-426.848,-234.819;Inherit;False;Global;_CustomFogColorMultiplier;_CustomFogColorMultiplier;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;17;-754.5,-282;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-469.4603,-487.6066;Inherit;False;Global;_CustomFogGammaCorrection;_CustomFogGammaCorrection;7;0;Create;True;0;0;0;False;0;False;0;2.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-244.5,-156;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;53;-987.848,-121.819;Inherit;False;Property;_FogClamp;FogClamp;6;0;Create;True;0;0;0;False;0;False;0,0;0.1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector4Node;62;-417.848,-409.819;Inherit;False;Global;_CustomFogColor;_CustomFogColor;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;107;206.5397,-174.6066;Inherit;False;float4 clr = input@$clr = log2(clr)@$clr *= GammaValue@$clr = exp2(clr)@$return clr@;4;Create;2;True;input;FLOAT4;0,0,0,0;In;;Inherit;False;True;GammaValue;FLOAT;0;In;;Inherit;False;Gamma Correction;True;False;0;;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-105.848,-267.819;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;15;-560.5,-297;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;664.152,-203.819;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;19;-142.5,-339;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-383.5,32;Inherit;False;Property;_Color;Color;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;103;-284.4691,395.866;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;104;-299.1488,548.5062;Inherit;False;Property;_SpectrogramPeak;Spectrogram Peak;8;0;Create;True;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;81;-625.0181,256.0572;Inherit;True;Property;_DataTex;_DataTex;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;105;-295.9705,623.7661;Inherit;False;Property;_SpectrogramOffset;Spectrogram Offset;9;0;Create;True;0;0;0;False;0;False;0;8.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;972.5,-193;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;972.5,-97;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;56;-1419.848,57.181;Inherit;False;Property;_FresnelVector;FresnelVector;7;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0.8;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FresnelNode;54;-1211.848,40.181;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;980.7085,-3.927429;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;91;-319.4291,273.4355;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;96;-558.2693,440.3859;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;102;-20.8488,299.4059;Inherit;False;float3 v = Vert@$v.z -= offset@$v.z += Data * peak@$return v@;3;Create;4;True;Data;FLOAT;0;In;;Inherit;False;True;Vert;FLOAT3;0,0,0;In;;Inherit;False;True;peak;FLOAT;0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;Data to Vertex;True;False;0;;False;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;57;-983.848,15.181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;1123.5,-191;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1326,-246;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/Spectrogram;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;True;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;Mobile/Diffuse;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;2;Pragma;vertex vert;False;;Custom;Pragma;multi_compile_fog;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;60;0;11;0
WireConnection;60;1;61;0
WireConnection;58;0;52;0
WireConnection;58;1;59;0
WireConnection;16;0;58;0
WireConnection;16;1;60;0
WireConnection;108;0;78;0
WireConnection;108;1;109;0
WireConnection;17;0;16;0
WireConnection;17;1;12;0
WireConnection;1;1;108;0
WireConnection;107;0;1;0
WireConnection;107;1;106;0
WireConnection;64;0;62;0
WireConnection;64;1;65;0
WireConnection;15;0;17;0
WireConnection;15;1;53;1
WireConnection;15;2;53;2
WireConnection;63;0;64;0
WireConnection;63;1;107;0
WireConnection;19;0;15;0
WireConnection;14;0;63;0
WireConnection;14;1;15;0
WireConnection;18;0;19;0
WireConnection;18;1;9;0
WireConnection;54;1;56;1
WireConnection;54;2;56;2
WireConnection;54;3;56;3
WireConnection;51;0;19;0
WireConnection;51;1;9;4
WireConnection;91;0;81;0
WireConnection;102;0;81;1
WireConnection;102;1;103;0
WireConnection;102;2;104;0
WireConnection;102;3;105;0
WireConnection;57;0;54;0
WireConnection;20;0;14;0
WireConnection;20;1;18;0
WireConnection;0;2;20;0
WireConnection;0;9;51;0
WireConnection;0;11;102;0
ASEEND*/
//CHKSM=05AC555C689EE4C00855A07EBB369F218CA64A9E