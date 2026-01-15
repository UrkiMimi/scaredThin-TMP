// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/ColorFog"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Color("Color", Color) = (1,1,1,1)
		_FogOverrideColor("FogOverrideColor", Color) = (1,1,1,1)
		_Glow("Glow", Range( 0 , 1)) = 0
		[Header(Fog)]_FogScale("Fog Scale", Float) = 0
		_FogOffset("Fog Offset", Float) = 0
		_FogClamp("Fog Clamp", Vector) = (0,1,0,0)
		_FresnelVector("FresnelVector", Vector) = (0,0,0,0)
		[Header(Height Fog)]_HeightFogScale("Height Fog Scale", Float) = 0
		_HeightFogOffset("Height Fog Offset", Float) = 0
		_Fade("Fade", Float) = 0
		[Toggle]_EnableFading("Enable Fading", Float) = 0
		[ToggleUI]_FogOverride("Fog Override", Float) = 0
		_VertexScale1("Vertex Scale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float eyeDepth;
			float3 worldNormal;
			float4 screenPosition;
		};

		uniform float4 _CutoutTexOffset1;
		uniform float _VertexScale1;
		uniform float _RVertexStep;
		uniform float3 _RVertexAdd;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float _HeightFogScale;
		uniform float _HeightFogOffset;
		uniform float _FogScale;
		uniform float _FogOffset;
		uniform float2 _FogClamp;
		uniform float3 _FresnelVector;
		uniform float _FogOverride;
		uniform float4 _FogColor;
		uniform float4 _FogOverrideColor;
		uniform float _Glow;
		uniform float _EnableFading;
		uniform float _Fade;
		uniform float _Cutoff = 0.5;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		float Fog37( float eyePos, float _FogScale, float _FogStartOffset )
		{
			return clamp( ( ( ( eyePos ) - ( _FogStartOffset ) ) / _FogScale ) , 0.0 , 1.0 );
		}


		float Fog23( float eyePos, float _FogScale, float _FogStartOffset )
		{
			return clamp( ( ( ( eyePos ) - ( _FogStartOffset ) ) / _FogScale ) , 0.0 , 1.0 );
		}


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 transform70 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float4 transform62 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float simplePerlin3D56 = snoise( ( transform62 + _CutoutTexOffset1 ).xyz*_VertexScale1 );
			simplePerlin3D56 = simplePerlin3D56*0.5 + 0.5;
			float4 transform69 = mul(unity_WorldToObject,( transform70 + float4( ( step( simplePerlin3D56 , _RVertexStep ) * _RVertexAdd ) , 0.0 ) ));
			v.vertex.xyz = transform69.xyz;
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float3 ase_worldPos = i.worldPos;
			float eyePos37 = ase_worldPos.y;
			float _FogScale37 = _HeightFogScale;
			float _FogStartOffset37 = _HeightFogOffset;
			float localFog37 = Fog37( eyePos37 , _FogScale37 , _FogStartOffset37 );
			float eyePos23 = i.eyeDepth;
			float _FogScale23 = _FogScale;
			float _FogStartOffset23 = _FogOffset;
			float localFog23 = Fog23( eyePos23 , _FogScale23 , _FogStartOffset23 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV45 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode45 = ( _FresnelVector.x + _FresnelVector.y * pow( 1.0 - fresnelNdotV45, _FresnelVector.z ) );
			float clampResult43 = clamp( ( localFog37 + localFog23 ) , ( _FogClamp.x * ( 1.0 - fresnelNode45 ) ) , _FogClamp.y );
			float temp_output_25_0 = ( 1.0 - clampResult43 );
			o.Emission = ( ( tex2DNode1 * _Color * temp_output_25_0 ) + ( clampResult43 * (( _FogOverride )?( _FogOverrideColor ):( _FogColor )) ) ).rgb;
			o.Alpha = ( temp_output_25_0 * _Glow );
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 ditherCustomScreenPos30 = ase_screenPosNorm;
			float2 clipScreen30 = ditherCustomScreenPos30.xy * _ScreenParams.xy;
			float dither30 = Dither8x8Bayer( fmod(clipScreen30.x, 8), fmod(clipScreen30.y, 8) );
			clip( ( tex2DNode1.a * ( _EnableFading == 1.0 ? step( _Fade , dither30 ) : 1.0 ) ) - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;60;1920;951;1417.195;-471.3659;1;True;False
Node;AmplifyShaderEditor.Vector3Node;44;-1258.6,112.5;Inherit;False;Property;_FresnelVector;FresnelVector;8;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;60;-1381.342,592.7715;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;45;-1047.6,97.5;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;24;-1185,-286.5;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-1121,-427;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;10;-1302,-181;Inherit;False;Property;_FogOffset;Fog Offset;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1281,17;Inherit;False;Property;_HeightFogOffset;Height Fog Offset;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1269,-73;Inherit;False;Property;_HeightFogScale;Height Fog Scale;9;1;[Header];Create;True;1;Height Fog;0;0;False;0;False;0;-25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1141,-178;Inherit;False;Property;_FogScale;Fog Scale;5;1;[Header];Create;True;1;Fog;0;0;False;0;False;0;150;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;61;-1397.342,1040.771;Inherit;False;Global;_CutoutTexOffset1;_CutoutTexOffset;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;62;-1189.342,752.7714;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;37;-904,-426;Inherit;False;return clamp( ( ( ( eyePos ) - ( _FogStartOffset ) ) / _FogScale ) , 0.0 , 1.0 )@;1;Create;3;True;eyePos;FLOAT;0;In;;Inherit;False;True;_FogScale;FLOAT;0;In;;Inherit;False;True;_FogStartOffset;FLOAT;0;In;;Inherit;False;Fog;True;False;0;;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;23;-901,-306.5;Inherit;False;return clamp( ( ( ( eyePos ) - ( _FogStartOffset ) ) / _FogScale ) , 0.0 , 1.0 )@;1;Create;3;True;eyePos;FLOAT;0;In;;Inherit;False;True;_FogScale;FLOAT;0;In;;Inherit;False;True;_FogStartOffset;FLOAT;0;In;;Inherit;False;Fog;True;False;0;;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;46;-732.6,77.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;48;-854.6,-158.5;Inherit;False;Property;_FogClamp;Fog Clamp;7;0;Create;True;0;0;0;False;0;False;0,1;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-981.3418,848.7714;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-925.3419,977.7711;Inherit;False;Property;_VertexScale1;Vertex Scale;14;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-612,-288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-565.6,-71.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;56;-717.3419,881.7712;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;33;-811,429;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;-733.3419,1009.771;Inherit;False;Global;_RVertexStep;_RVertexStep;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-527,325;Inherit;False;Property;_Fade;Fade;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;43;-247,-278.5;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;30;-440,405;Inherit;False;1;True;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-730,177;Inherit;False;Global;_FogColor;_FogColor;3;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;53;-1137.5,371.5;Inherit;False;Property;_FogOverrideColor;FogOverrideColor;3;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;58;-508.3418,1009.771;Inherit;False;Global;_RVertexAdd;_RVertexAdd;16;1;[Header];Create;True;1;Vertex;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StepOpNode;57;-509.3418,897.7712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;71;-575.9947,713.0909;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-160,542.5;Inherit;False;Property;_EnableFading;Enable Fading;12;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;70;-397.9948,709.0909;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;52;-468.5,98.5;Inherit;False;Property;_FogOverride;Fog Override;13;0;Create;True;0;0;0;False;0;False;0;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-333.3418,881.7712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1;-246,-151;Inherit;True;Property;_MainTex;Main Texture;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;29;-163,324;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-109,-236.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-161,45;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.6037736,0.236383,0.5572029,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;36;82,316.5;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-226,228;Inherit;False;Property;_Glow;Glow;4;0;Create;True;0;0;0;False;0;False;0;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-172.1948,761.3659;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;87,-115;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;86,-230;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;69;-30.99487,759.0909;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;14;245,-130;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;108,72.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;252,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;66;-1397.342,896.7714;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformVariables;67;-1621.342,752.7714;Inherit;False;_Object2World;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;68;-1349.342,720.7714;Inherit;False;Row;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;552.3665,377.8564;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/ColorFog;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;TransparentCutout;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;45;1;44;1
WireConnection;45;2;44;2
WireConnection;45;3;44;3
WireConnection;62;0;60;0
WireConnection;37;0;39;2
WireConnection;37;1;41;0
WireConnection;37;2;42;0
WireConnection;23;0;24;0
WireConnection;23;1;13;0
WireConnection;23;2;10;0
WireConnection;46;0;45;0
WireConnection;64;0;62;0
WireConnection;64;1;61;0
WireConnection;40;0;37;0
WireConnection;40;1;23;0
WireConnection;47;0;48;1
WireConnection;47;1;46;0
WireConnection;56;0;64;0
WireConnection;56;1;54;0
WireConnection;43;0;40;0
WireConnection;43;1;47;0
WireConnection;43;2;48;2
WireConnection;30;2;33;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;70;0;71;0
WireConnection;52;0;17;0
WireConnection;52;1;53;0
WireConnection;59;0;57;0
WireConnection;59;1;58;0
WireConnection;29;0;27;0
WireConnection;29;1;30;0
WireConnection;25;0;43;0
WireConnection;36;0;35;0
WireConnection;36;2;29;0
WireConnection;72;0;70;0
WireConnection;72;1;59;0
WireConnection;5;0;1;0
WireConnection;5;1;3;0
WireConnection;5;2;25;0
WireConnection;15;0;43;0
WireConnection;15;1;52;0
WireConnection;69;0;72;0
WireConnection;14;0;5;0
WireConnection;14;1;15;0
WireConnection;26;0;25;0
WireConnection;26;1;6;0
WireConnection;34;0;1;4
WireConnection;34;1;36;0
WireConnection;68;0;67;0
WireConnection;0;2;14;0
WireConnection;0;9;26;0
WireConnection;0;10;34;0
WireConnection;0;11;69;0
ASEEND*/
//CHKSM=90AF2325C668D19B2298C33ADAAD28C014C9BCC5