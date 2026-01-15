// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/DistortionFog"
{
	Properties
	{
		_FogOffset("Fog Offset", Float) = 0
		_FogScale("Fog Scale", Float) = 0
		_Color("Color", Color) = (0,0,0,0)
		_Cutout("Cutout", Float) = 0
		_CullMode("CullMode", Int) = 0
		_DisplacementIntensity("Displacement Intensity", Float) = 0
		_DisplacementTexture("Displacement Texture", 2D) = "white" {}
		_ScrollSpeed("Scroll Speed", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite On
		Stencil
		{
			Ref 0
			Comp Always
			Pass Keep
			Fail Keep
			ZFail Keep
		}
		Blend One Zero , Zero Zero
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float eyeDepth;
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float _Cutout;
		uniform float _CustomFogAttenuation;
		uniform float _FogOffset;
		uniform float _CustomFogOffset;
		uniform float _FogScale;
		uniform float4 _Color;
		uniform sampler2D _BloomPrePassTexture;
		uniform float _DisplacementIntensity;
		uniform sampler2D _DisplacementTexture;
		uniform float _ScrollSpeed;
		uniform float4 _DisplacementTexture_ST;
		uniform int _CullMode;


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


		float2 MyCustomExpression45( float2 input )
		{
			input.y = 1 - input.y;
			return input.xy;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			v.vertex.xyz = ( ( 1.0 - _Cutout ) * ase_vertex3Pos );
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float clampResult36 = clamp( ( ( ( i.eyeDepth * _CustomFogAttenuation ) - ( _FogOffset + _CustomFogOffset ) ) / _FogScale ) , 0.1 , 1.0 );
			float temp_output_48_0 = ( 1.0 - clampResult36 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 input45 = ase_grabScreenPosNorm.xy;
			float2 localMyCustomExpression45 = MyCustomExpression45( input45 );
			float temp_output_92_0 = ( _Time.y * _ScrollSpeed );
			float2 uv_DisplacementTexture = i.uv_texcoord * _DisplacementTexture_ST.xy + _DisplacementTexture_ST.zw;
			float4 tex2DNode70 = tex2D( _BloomPrePassTexture, ( float4( localMyCustomExpression45, 0.0 , 0.0 ) + ( ( _DisplacementIntensity / 2.0 ) * tex2D( _DisplacementTexture, ( ( temp_output_92_0 + ( uv_DisplacementTexture * float2( 1,0 ) ) ) + ( ( uv_DisplacementTexture * float2( 0,1 ) ) + temp_output_92_0 ) ) ) ) ).rg );
			float4 Color67 = ( _Color * ( ( tex2DNode70.r + tex2DNode70.g + tex2DNode70.b ) / 3.0 ) );
			o.Emission = ( ( ( temp_output_48_0 * Color67 ) + ( clampResult36 * tex2D( _BloomPrePassTexture, localMyCustomExpression45 ) ) ) + ( _CullMode * 0 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;5.6;1536;788;1567.191;1430.057;1;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;89;-2520.191,-810.0571;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;95;-2426.191,-945.557;Inherit;False;0;79;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;93;-2484.191,-739.0571;Inherit;False;Property;_ScrollSpeed;Scroll Speed;9;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-2293.191,-816.0571;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-2119.191,-828.0571;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-2113.191,-927.0571;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-1971.191,-827.0571;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1968.191,-927.0571;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-1814.191,-891.0571;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-1629.191,-942.0571;Inherit;False;Property;_DisplacementIntensity;Displacement Intensity;7;0;Create;True;0;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;79;-1477.191,-860.0571;Inherit;True;Property;_DisplacementTexture;Displacement Texture;8;0;Create;True;0;0;0;False;0;False;-1;None;ed354f366bf90a3428fd55788ad869f9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;46;-714.9509,-248.2759;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;69;-727.1542,-79.09229;Inherit;True;Global;_BloomPrePassTexture;_BloomPrePassTexture;10;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleDivideOpNode;97;-1324.191,-961.557;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-497.1542,-88.09229;Inherit;False;PrePass;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CustomExpressionNode;45;-494.2123,-250.524;Inherit;False;input.y = 1 - input.y@$return input.xy@;2;Create;1;True;input;FLOAT2;0,0;In;;Inherit;False;My Custom Expression;True;False;0;;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1163.191,-925.0571;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-1073.154,-1026.092;Inherit;False;73;PrePass;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-1028.191,-948.0571;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-868.782,-384.3702;Inherit;False;Property;_FogOffset;Fog Offset;1;0;Create;True;0;0;0;False;0;False;0;-1.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-957.13,-312.1891;Inherit;False;Global;_CustomFogOffset;_CustomFogOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;30;-904.5698,-539.3928;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-942.13,-453.1892;Inherit;False;Global;_CustomFogAttenuation;_CustomFogAttenuation;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;70;-898.1542,-1028.092;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-643.13,-415.1892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;-587.1909,-1031.057;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-615.13,-526.1892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;99;-449.1909,-1034.057;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-464.782,-428.3702;Inherit;False;Property;_FogScale;Fog Scale;2;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;34;-467.782,-529.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;44;-812.4124,-1196.417;Inherit;False;Property;_Color;Color;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4811321,0.0295034,0.0295034,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-540.1542,-1191.092;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;35;-285.782,-498.3702;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;36;-151.3566,-501.0056;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-396.1542,-1200.092;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;42;-274.0555,-211.1823;Inherit;True;Global;Tex1;Tex1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;48;23.66639,-503.4358;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-209.1542,-385.0923;Inherit;False;67;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;180.0608,-331.4557;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;65;158.0766,-578.1844;Inherit;False;Property;_CullMode;CullMode;6;0;Create;True;0;0;0;False;0;False;0;2;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;156.3042,-434.8688;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;61;22.54229,-131.9368;Inherit;False;Property;_Cutout;Cutout;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;59;65.25632,-31.89633;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;304.6786,-501.7493;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.OneMinusNode;62;179.9095,-121.8203;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;317.0434,-407.8915;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;31,-609.5;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;50;332.7796,-307.8509;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;39;-216,-680.5;Inherit;False;Global;_CustomFogColor;_CustomFogColor;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;41;-290,-751.5;Inherit;False;Global;_CustomFogColorMultiplier;_CustomFogColorMultiplier;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;472.1627,-411.8251;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;53;155.18,-215.6788;Inherit;False;Property;_Opacity;Opacity;4;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;353.0131,-93.71904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;584.2797,-464.2245;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/DistortionFog;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0;True;True;0;True;Opaque;Transparent;AlphaTest;ForwardOnly;18;all;True;True;True;True;0;False;-1;True;0;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;0;-1;-1;-1;0;False;0;0;True;65;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;92;0;89;0
WireConnection;92;1;93;0
WireConnection;87;0;95;0
WireConnection;86;0;95;0
WireConnection;91;0;87;0
WireConnection;91;1;92;0
WireConnection;90;0;92;0
WireConnection;90;1;86;0
WireConnection;88;0;90;0
WireConnection;88;1;91;0
WireConnection;79;1;88;0
WireConnection;97;0;78;0
WireConnection;73;0;69;0
WireConnection;45;0;46;0
WireConnection;77;0;97;0
WireConnection;77;1;79;0
WireConnection;76;0;45;0
WireConnection;76;1;77;0
WireConnection;70;0;74;0
WireConnection;70;1;76;0
WireConnection;31;0;28;0
WireConnection;31;1;37;0
WireConnection;98;0;70;1
WireConnection;98;1;70;2
WireConnection;98;2;70;3
WireConnection;32;0;30;0
WireConnection;32;1;29;0
WireConnection;99;0;98;0
WireConnection;34;0;32;0
WireConnection;34;1;31;0
WireConnection;71;0;44;0
WireConnection;71;1;99;0
WireConnection;35;0;34;0
WireConnection;35;1;33;0
WireConnection;36;0;35;0
WireConnection;67;0;71;0
WireConnection;42;0;69;0
WireConnection;42;1;45;0
WireConnection;48;0;36;0
WireConnection;43;0;36;0
WireConnection;43;1;42;0
WireConnection;49;0;48;0
WireConnection;49;1;68;0
WireConnection;63;0;65;0
WireConnection;62;0;61;0
WireConnection;47;0;49;0
WireConnection;47;1;43;0
WireConnection;40;0;39;0
WireConnection;40;1;41;0
WireConnection;50;0;48;0
WireConnection;50;2;53;0
WireConnection;64;0;47;0
WireConnection;64;1;63;0
WireConnection;60;0;62;0
WireConnection;60;1;59;0
WireConnection;0;2;64;0
WireConnection;0;11;60;0
ASEEND*/
//CHKSM=EAE21518EF4B4DFC91FB259A73845046BF69724E