// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/ColorFogNote"
{
	Properties
	{
		[Header(Color)]_MainTex("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[Header(Fog)]_FogScale("Fog Scale", Float) = 0
		_FogOffset("Fog Offset", Float) = 0
		[Header(Glow and Culling)]_Glow("Glow", Range( 0 , 1)) = 0
		[HideInInspector]_SlicePos("_SlicePos", Vector) = (0,0,0,0)
		[Enum(UnityEngine.Rendering.CullMode)]_CullingMode("Culling Mode", Int) = 0
		[HideInInspector]_TransformOffset("_TransformOffset", Vector) = (0,0,0,0)
		[Header(Cutout)]_Cutout("Cutout", Float) = 0
		_CutoutTexScale("Cutout Texture Scale", Float) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_EdgeIntensity("Edge Intensity", Float) = 0
		[Header(Cut Plane)]_CutPlane("_CutPlane", Vector) = (0,0,0,0)
		[Toggle]_EnableCutPlane("Enable Cut Plane", Float) = 0
		_InsideBrightness("Inside Brightness", Float) = 0
		_VertexScale("Vertex Scale", Float) = 0
		_NoteBrightness("Note Brightness", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_CullingMode]
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma shader_feature MAIN_EFFECT_ENABLED
		#include "slice.cginc"
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float eyeDepth;
			half ASEVFace : VFACE;
			float3 worldPos;
			float4 screenPosition;
		};

		uniform float4 _CutoutTexOffset;
		uniform float _CutoutTexScale;
		uniform float _VertexScale;
		uniform float _NoteVertexStep;
		uniform float3 _NoteVertexAdd;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Glow;
		uniform float4 _Color;
		uniform float _NoteBrightness;
		uniform float _FogScale;
		uniform float _FogOffset;
		uniform float4 _FogColor;
		uniform float _InsideBrightness;
		uniform int _CullingMode;
		uniform float _Cutout;
		uniform float _EdgeIntensity;
		uniform float _EnableCutPlane;
		uniform float4 _CutPlane;
		uniform half3 _SlicePos;
		uniform half3 _TransformOffset;
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


		float Fog23( float eyePos, float _FogScale, float _FogStartOffset )
		{
			return clamp( ( ( ( eyePos ) - ( _FogStartOffset ) ) / _FogScale ) , 0.0 , 1.0 );
		}


		inline float Dither4x4Bayer( int x, int y )
		{
			const float dither[ 16 ] = {
				 1,  9,  3, 11,
				13,  5, 15,  7,
				 4, 12,  2, 10,
				16,  8, 14,  6 };
			int r = y * 4 + x;
			return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
		}


		float3 MyCustomExpression71( half4 CutPlane, float3 SlicePos, float3 localpos, float3 TransformOffset, float SliceEdge )
		{
			return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 transform96 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float4 transform29 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float4 temp_output_32_0 = ( ( transform29 + _CutoutTexOffset ) * _CutoutTexScale );
			float simplePerlin3D92 = snoise( temp_output_32_0.xyz*_VertexScale );
			simplePerlin3D92 = simplePerlin3D92*0.5 + 0.5;
			float4 transform97 = mul(unity_WorldToObject,( transform96 + float4( ( step( simplePerlin3D92 , _NoteVertexStep ) * _NoteVertexAdd ) , 0.0 ) ));
			v.vertex.xyz = transform97.xyz;
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
			float4 temp_output_101_0 = ( _Color * _NoteBrightness );
			#ifdef MAIN_EFFECT_ENABLED
				float4 staticSwitch104 = temp_output_101_0;
			#else
				float4 staticSwitch104 = ( _Glow + temp_output_101_0 );
			#endif
			float eyePos23 = i.eyeDepth;
			float _FogScale23 = _FogScale;
			float _FogStartOffset23 = _FogOffset;
			float localFog23 = Fog23( eyePos23 , _FogScale23 , _FogStartOffset23 );
			float temp_output_25_0 = ( 1.0 - localFog23 );
			float4 temp_output_14_0 = ( ( tex2DNode1 * staticSwitch104 * temp_output_25_0 ) + ( localFog23 * _FogColor ) );
			float4 switchResult80 = (((i.ASEVFace>0)?(temp_output_14_0):(( temp_output_14_0 * _InsideBrightness ))));
			o.Emission = ( switchResult80 + ( _CullingMode * 0 ) ).rgb;
			o.Alpha = ( temp_output_25_0 * _Glow );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform29 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float4 temp_output_32_0 = ( ( transform29 + _CutoutTexOffset ) * _CutoutTexScale );
			float simplePerlin3D36 = snoise( temp_output_32_0.xyz );
			simplePerlin3D36 = simplePerlin3D36*0.5 + 0.5;
			float temp_output_38_0 = step( _Cutout , simplePerlin3D36 );
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen67 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither67 = Dither4x4Bayer( fmod(clipScreen67.x, 4), fmod(clipScreen67.y, 4) );
			float3 temp_cast_3 = (1.0).xxx;
			float4 CutPlane71 = _CutPlane;
			float3 SlicePos71 = _SlicePos;
			float3 localpos71 = ase_vertex3Pos;
			float3 TransformOffset71 = _TransformOffset;
			float SliceEdge71 = 0.0;
			float3 localMyCustomExpression71 = MyCustomExpression71( CutPlane71 , SlicePos71 , localpos71 , TransformOffset71 , SliceEdge71 );
			float3 CutPlane78 = (( _EnableCutPlane )?( localMyCustomExpression71 ):( temp_cast_3 ));
			clip( ( ( ( tex2DNode1.a * temp_output_38_0 ) + ( ( step( ( _Cutout - _EdgeIntensity ) , simplePerlin3D36 ) - temp_output_38_0 ) * step( dither67 , 0.2 ) ) ) * CutPlane78 ).x - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
318;342;1225;669;1980.691;524.5952;1;True;False
Node;AmplifyShaderEditor.PosVertexDataNode;27;-1102.678,25.04647;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;44;-1744.684,-686.921;Inherit;False;1459.4;671.9;Color;20;26;14;6;5;15;3;25;17;1;23;10;24;13;80;81;82;101;102;103;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;28;-1120.047,479.1003;Inherit;False;Global;_CutoutTexOffset;_CutoutTexOffset;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;29;-904.413,197.8558;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-1357.682,-307.421;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;102;-1717.606,-126.8186;Inherit;False;Property;_NoteBrightness;Note Brightness;16;0;Create;True;0;0;0;False;0;False;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1694.684,-511.421;Inherit;False;Property;_FogOffset;Fog Offset;3;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;24;-1577.684,-616.921;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1533.684,-508.421;Inherit;False;Property;_FogScale;Fog Scale;2;1;[Header];Create;True;1;Fog;0;0;False;0;False;0;75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;70;-614.077,7.290497;Inherit;False;802.4;233.8;Edge Glow;7;69;67;64;54;56;62;66;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-695.0463,287.1002;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-788.0463,388.1001;Inherit;False;Property;_CutoutTexScale;Cutout Texture Scale;9;0;Create;False;0;0;0;False;0;False;0;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-1144.606,-282.8186;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1520.682,-114.4211;Inherit;False;Property;_Glow;Glow;4;1;[Header];Create;True;1;Glow and Culling;0;0;False;0;False;0;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-478.0464,354.1001;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-1182.191,-148.5952;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-483.1501,465.3124;Inherit;False;Property;_Cutout;Cutout;8;1;[Header];Create;True;1;Cutout;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-596.077,170.2905;Inherit;False;Property;_EdgeIntensity;Edge Intensity;11;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;77;-909.8788,664.195;Inherit;False;595.972;709.1126;Cut Plane;7;74;71;72;76;75;73;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;23;-1293.682,-636.921;Inherit;False;return clamp( ( ( ( eyePos ) - ( _FogStartOffset ) ) / _FogScale ) , 0.0 , 1.0 )@;1;Create;3;True;eyePos;FLOAT;0;In;;Inherit;False;True;_FogScale;FLOAT;0;In;;Inherit;False;True;_FogStartOffset;FLOAT;0;In;;Inherit;False;Fog;True;False;0;;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1359.682,-503.421;Inherit;True;Property;_MainTex;Main Texture;0;1;[Header];Create;False;1;Color;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;73;-822.5069,887.1529;Half;False;Property;_SlicePos;_SlicePos;5;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;72;-842.017,714.195;Inherit;False;Property;_CutPlane;_CutPlane;12;1;[Header];Create;True;1;Cut Plane;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;62;-397.077,148.2905;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-1033.682,-581.921;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-1580.683,-311.421;Inherit;False;Global;_FogColor;_FogColor;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;75;-848.5069,1030.153;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;36;-317.01,343.4703;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;76;-859.8788,1183.708;Half;False;Property;_TransformOffset;_TransformOffset;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;104;-1033.191,-191.5952;Inherit;False;Property;MAIN_EFFECT_ENABLED;MAIN_EFFECT_ENABLED;18;0;Create;False;0;0;0;True;0;False;0;0;0;False;MAIN_EFFECT_ENABLED;Toggle;2;Key0;Key1;Create;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-285.653,545.3195;Inherit;False;Property;_VertexScale;Vertex Scale;15;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;67;-323.077,61.2905;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-572.6538,1111.286;Inherit;False;Constant;_CutPlaneFallback;CutPlaneFallback;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-827.6823,-475.421;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;38;-65.99841,320.6721;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-851.6823,-586.421;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-80.65302,575.3195;Inherit;False;Global;_NoteVertexStep;_NoteVertexStep;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;71;-579.5068,935.1528;Inherit;False;return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge)@;3;Create;5;True;CutPlane;FLOAT4;0,0,0,0;In;;Half;False;True;SlicePos;FLOAT3;0,0,0;In;;Inherit;False;True;localpos;FLOAT3;0,0,0;In;;Inherit;False;True;TransformOffset;FLOAT3;0,0,0;In;;Inherit;False;True;SliceEdge;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;92;-78.6528,459.3195;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;54;-230.077,149.2905;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-768.5515,-356.9519;Inherit;False;Property;_InsideBrightness;Inside Brightness;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;98;134.347,467.3195;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;69;-94.07703,57.2905;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;93;134.3472,575.3195;Inherit;False;Global;_NoteVertexAdd;_NoteVertexAdd;16;1;[Header];Create;True;1;Vertex;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;-101.077,152.2905;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-681.2808,-486.4209;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;90;61.3472,279.3195;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;53;-148.077,-216.2095;Inherit;False;589.4;205.8;For culling mode switch;3;45;52;50;;0.3207547,0.3207547,0.3207547,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;87;-285.335,934.5621;Inherit;False;Property;_EnableCutPlane;Enable Cut Plane;13;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;50;-98.07703,-149.2095;Inherit;False;Property;_CullingMode;Culling Mode;6;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;False;0;False;0;2;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-541.8694,-447.8737;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.7;False;1;COLOR;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;96;239.347,275.3195;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;311.585,55.03259;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-41.91808,934.1613;Inherit;False;CutPlane;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;312.3472,454.3195;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;47.08209,142.5897;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;460.8851,61.15034;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;467.3472,323.3195;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;105.923,-166.2095;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;397.6179,160.3974;Inherit;False;78;CutPlane;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwitchByFaceNode;80;-388.0894,-511.9032;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-754.6823,-271.921;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;97;606.347,325.3195;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;590.3038,63.48427;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1123.047,330.1002;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;288.923,-144.2095;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformVariables;34;-1342.046,185.1002;Inherit;False;_Object2World;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CustomExpressionNode;74;-584.7682,726.3423;Inherit;False;return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge)@;3;Create;5;True;CutPlane;FLOAT4;0,0,0,0;In;;Half;False;True;SlicePos;FLOAT3;0,0,0;In;;Inherit;False;True;localpos;FLOAT3;0,0,0;In;;Inherit;False;True;TransformOffset;FLOAT3;0,0,0;In;;Inherit;False;True;SliceEdge;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;37;-1075.047,168.1002;Inherit;False;Row;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1154,-135;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/ColorFogNote;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;TransparentCutout;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;10;-1;-1;-1;0;False;0;0;True;50;-1;0;False;-1;1;Include;slice.cginc;False;;Custom;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;29;0;27;0
WireConnection;31;0;29;0
WireConnection;31;1;28;0
WireConnection;101;0;3;0
WireConnection;101;1;102;0
WireConnection;32;0;31;0
WireConnection;32;1;30;0
WireConnection;103;0;6;0
WireConnection;103;1;101;0
WireConnection;23;0;24;0
WireConnection;23;1;13;0
WireConnection;23;2;10;0
WireConnection;62;0;39;0
WireConnection;62;1;56;0
WireConnection;25;0;23;0
WireConnection;36;0;32;0
WireConnection;104;1;103;0
WireConnection;104;0;101;0
WireConnection;5;0;1;0
WireConnection;5;1;104;0
WireConnection;5;2;25;0
WireConnection;38;0;39;0
WireConnection;38;1;36;0
WireConnection;15;0;23;0
WireConnection;15;1;17;0
WireConnection;71;0;72;0
WireConnection;71;1;73;0
WireConnection;71;2;75;0
WireConnection;71;3;76;0
WireConnection;92;0;32;0
WireConnection;92;1;100;0
WireConnection;54;0;62;0
WireConnection;54;1;36;0
WireConnection;98;0;92;0
WireConnection;98;1;99;0
WireConnection;69;0;67;0
WireConnection;64;0;54;0
WireConnection;64;1;38;0
WireConnection;14;0;5;0
WireConnection;14;1;15;0
WireConnection;87;0;85;0
WireConnection;87;1;71;0
WireConnection;81;0;14;0
WireConnection;81;1;82;0
WireConnection;96;0;90;0
WireConnection;40;0;1;4
WireConnection;40;1;38;0
WireConnection;78;0;87;0
WireConnection;94;0;98;0
WireConnection;94;1;93;0
WireConnection;66;0;64;0
WireConnection;66;1;69;0
WireConnection;68;0;40;0
WireConnection;68;1;66;0
WireConnection;91;0;96;0
WireConnection;91;1;94;0
WireConnection;52;0;50;0
WireConnection;80;0;14;0
WireConnection;80;1;81;0
WireConnection;26;0;25;0
WireConnection;26;1;6;0
WireConnection;97;0;91;0
WireConnection;88;0;68;0
WireConnection;88;1;89;0
WireConnection;45;0;80;0
WireConnection;45;1;52;0
WireConnection;74;0;72;0
WireConnection;74;1;73;0
WireConnection;74;2;75;0
WireConnection;74;3;76;0
WireConnection;37;0;34;0
WireConnection;0;2;45;0
WireConnection;0;9;26;0
WireConnection;0;10;88;0
WireConnection;0;11;97;0
ASEEND*/
//CHKSM=D30A7B1DA713652E894070A1A02FFF76A7B71B10