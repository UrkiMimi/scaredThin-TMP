// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/Urki/MainEffect"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_BloomTex("BloomTex", 2D) = "white" {}
		_BloomIntensity("_BloomIntensity", Float) = 0
		_FadeAmount("FadeAmount", Float) = 0
		_BaseColorBoost("_BaseColorBoost", Float) = 0
		_BaseColorBoostThreshold("_BaseColorBoostThreshold", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _BloomIntensity;
		uniform sampler2D _BloomTex;
		uniform float _FadeAmount;
		uniform float _BaseColorBoost;
		uniform float _BaseColorBoostThreshold;


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


		float2 MyCustomExpression47( float2 input )
		{
			#ifdef UNITY_UV_STARTS_AT_TOP
			{
				input.y = 1 - input.y;
			}
			#else
			{
				input.y = 1 - input.y;
			}
			#endif
			return input;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 input47 = ase_grabScreenPosNorm.xy;
			float2 localMyCustomExpression47 = MyCustomExpression47( input47 );
			float3 hsvTorgb23 = RGBToHSV( ( ( tex2DNode1 + ( _BloomIntensity * tex2DNode1.a ) + ( tex2D( _BloomTex, localMyCustomExpression47 ) * _BloomIntensity ) ) * _FadeAmount ).rgb );
			float3 hsvTorgb26 = HSVToRGB( float3(hsvTorgb23.x,( hsvTorgb23.y * ( _BaseColorBoost + -_BaseColorBoostThreshold ) ),hsvTorgb23.z) );
			o.Emission = hsvTorgb26;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
263;26;1273;715;1139.608;159.7723;1;True;True
Node;AmplifyShaderEditor.GrabScreenPosition;42;-636.4659,243.8068;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;47;-386.1077,267.7277;Inherit;False;#ifdef UNITY_UV_STARTS_AT_TOP${$	input.y = 1 - input.y@$}$#else${$	input.y = 1 - input.y@$}$#endif$return input@;2;Create;1;True;input;FLOAT2;0,0;In;;Inherit;False;My Custom Expression;True;False;0;;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-111,-39;Inherit;False;Property;_BloomIntensity;_BloomIntensity;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-185,34;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-183,226;Inherit;True;Property;_BloomTex;BloomTex;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;152.3923,52.72766;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;151,143;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;294,83;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;295.6198,368.881;Inherit;False;Property;_BaseColorBoostThreshold;_BaseColorBoostThreshold;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;195,230.5;Inherit;False;Property;_FadeAmount;FadeAmount;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;586,93.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;28;586.6198,346.881;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;538.6198,268.881;Inherit;False;Property;_BaseColorBoost;_BaseColorBoost;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;23;718.6198,92.88104;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;27;785.6198,271.881;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;961.6198,119.881;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;26;1110.62,97.881;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1395,42;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Hidden/Urki/MainEffect;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;47;0;42;0
WireConnection;2;1;47;0
WireConnection;46;0;12;0
WireConnection;46;1;1;4
WireConnection;14;0;2;0
WireConnection;14;1;12;0
WireConnection;10;0;1;0
WireConnection;10;1;46;0
WireConnection;10;2;14;0
WireConnection;15;0;10;0
WireConnection;15;1;16;0
WireConnection;28;0;29;0
WireConnection;23;0;15;0
WireConnection;27;0;25;0
WireConnection;27;1;28;0
WireConnection;24;0;23;2
WireConnection;24;1;27;0
WireConnection;26;0;23;1
WireConnection;26;1;24;0
WireConnection;26;2;23;3
WireConnection;0;2;26;0
ASEEND*/
//CHKSM=E813DEA1C8863D2EA9131079D1D9737548360615