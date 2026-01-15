// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Urki/NoteSimple"
{
	Properties
	{
		[Header(Color Options)]_Color("Color", Color) = (1,1,1,1)
		_ColorIntensity("Color Intensity", Float) = 0
		_MainTex("MainTexture", 2D) = "white" {}
		[Header(Pseudo Lighting Options)]_MainCubemap("Main Cubemap", CUBE) = "white" {}
		_RimPower("Rim Power", Float) = 0
		_RimIntensity("Rim Intensity", Float) = 0
		_Roughness("Roughness", Float) = 0
		[Header(Normal Maps)]_NormalTexture("Normal Texture", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Float) = 0
		[Toggle(QUEST_CUTOUT)] _QuestCutout("Quest Cutout", Float) = 0
		_Cutout("Cutout", Float) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_NoiseScale("Noise Scale", Float) = 0
		[Header(Other)]_CullMode("Cull Mode", Int) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma shader_feature QUEST_CUTOUT
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
			half ASEVFace : VFACE;
		};

		uniform float _Cutout;
		uniform samplerCUBE _MainCubemap;
		uniform sampler2D _NormalTexture;
		uniform float4 _NormalTexture_ST;
		uniform float _NormalIntensity;
		uniform float _Roughness;
		uniform float4 _Color;
		uniform float _RimPower;
		uniform float _RimIntensity;
		uniform float _ColorIntensity;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _NoiseScale;
		uniform int _CullMode;
		uniform float _Cutoff = 0.5;


		float3 ViewReflection164( float4 worldPos, float3 wsCamPos, float3 vertNorm )
		{
			float3 viewDir = normalize(wsCamPos.xyz - worldPos);
			float3 viewRef = reflect(viewDir, vertNorm);
			return viewRef;
		}


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef QUEST_CUTOUT
				float3 staticSwitch136 = ( ase_vertex3Pos * ( 1.0 - _Cutout ) );
			#else
				float3 staticSwitch136 = ase_vertex3Pos;
			#endif
			v.vertex.xyz = staticSwitch136;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 worldPos164 = float4( ase_worldPos , 0.0 );
			float3 wsCamPos164 = _WorldSpaceCameraPos;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float4 transform201 = mul(unity_ObjectToWorld,float4( ase_vertexNormal , 0.0 ));
			float2 uv_NormalTexture = i.uv_texcoord * _NormalTexture_ST.xy + _NormalTexture_ST.zw;
			float4 normalizeResult202 = normalize( ( transform201 + float4( ( UnpackNormal( tex2D( _NormalTexture, uv_NormalTexture ) ) * _NormalIntensity ) , 0.0 ) ) );
			float3 vertNorm164 = normalizeResult202.xyz;
			float3 localViewReflection164 = ViewReflection164( worldPos164 , wsCamPos164 , vertNorm164 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV174 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode174 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV174, 1.0 ) );
			float fresnelNdotV178 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode178 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV178, _RimPower ) );
			float switchResult200 = (((i.ASEVFace>0)?(fresnelNode178):(0.0)));
			float temp_output_180_0 = ( switchResult200 * _RimIntensity );
			float4 MainColor187 = ( ( ( texCUBEbias( _MainCubemap, float4( -localViewReflection164, ( fresnelNode174 + _Roughness )) ) * _Color * ( 1.0 - temp_output_180_0 ) ) + ( temp_output_180_0 * _Color ) ) * _ColorIntensity );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform129 = mul(unity_WorldToObject,float4( ( ase_vertex3Pos / float3( 10,10,10 ) ) , 0.0 ));
			float simplePerlin3D73 = snoise( transform129.xyz*( _NoiseScale * 10.0 ) );
			simplePerlin3D73 = simplePerlin3D73*0.5 + 0.5;
			#ifdef QUEST_CUTOUT
				float staticSwitch144 = 0.0;
			#else
				float staticSwitch144 = step( simplePerlin3D73 , _Cutout );
			#endif
			float temp_output_116_0 = ( ( 0.0 + staticSwitch144 ) + 0.0 );
			float4 clr188 = _Color;
			o.Emission = ( ( ( MainColor187 * tex2D( _MainTex, uv_MainTex ) ) * ( 1.0 - temp_output_116_0 ) ) + ( clr188 * temp_output_116_0 ) + ( _CullMode * 0 ) ).rgb;
			o.Alpha = temp_output_116_0;
			#ifdef QUEST_CUTOUT
				float staticSwitch135 = (float)1;
			#else
				float staticSwitch135 = step( ( _Cutout - 0.05 ) , simplePerlin3D73 );
			#endif
			clip( ( staticSwitch135 - 0.0 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Mobile/Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
0;5.6;1536;788;1083.476;1169.834;1;True;False
Node;AmplifyShaderEditor.NormalVertexDataNode;169;-931.0774,-862.3521;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;215;-835.476,-648.834;Inherit;True;Property;_NormalTexture;Normal Texture;7;1;[Header];Create;True;1;Normal Maps;0;0;False;0;False;-1;None;ea400335b033eab4b94d3f6f809f6242;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;217;-795.476,-447.834;Inherit;False;Property;_NormalIntensity;Normal Intensity;8;0;Create;True;0;0;0;False;0;False;0;-1.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;201;-743.6642,-865.6674;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;-519.476,-649.834;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-39.144,-1298.676;Inherit;False;Property;_RimPower;Rim Power;4;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;-526.476,-840.834;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FresnelNode;178;141.8559,-1384.676;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;166;-341.3091,-1182.611;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;202;-347.6642,-880.6674;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;165;-415.3091,-1046.611;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FresnelNode;174;207.456,-787.276;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;480.8559,-1456.676;Inherit;False;Property;_RimIntensity;Rim Intensity;5;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;200;435.4047,-1360.666;Inherit;False;2;0;FLOAT;-1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;164;-99.64499,-1066.276;Inherit;False;float3 viewDir = normalize(wsCamPos.xyz - worldPos)@$float3 viewRef = reflect(viewDir, vertNorm)@$return viewRef@;3;Create;3;True;worldPos;FLOAT4;0,0,0,0;In;;Inherit;False;True;wsCamPos;FLOAT3;0,0,0;In;;Inherit;False;True;vertNorm;FLOAT3;0,0,0;In;;Inherit;False;View Reflection;True;False;0;;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;213;216.524,-608.834;Inherit;False;Property;_Roughness;Roughness;6;0;Create;True;0;0;0;False;0;False;0;3.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;128;-559.9338,188.9653;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-268.3873,252.4044;Inherit;False;Property;_NoiseScale;Noise Scale;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;212;483.524,-820.834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;186;246.856,-1056.676;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;130;-378.2069,165.1967;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;10,10,10;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;711.856,-1336.676;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;163;716.25,-1060.941;Inherit;True;Property;_MainCubemap;Main Cubemap;3;1;[Header];Create;True;1;Pseudo Lighting Options;0;0;False;0;False;-1;None;f464c72246affe748899e93ecaefc566;True;0;False;white;LockedToCube;False;Object;-1;MipBias;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;172;706.6909,-1234.611;Inherit;False;Property;_Color;Color;0;1;[Header];Create;True;1;Color Options;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToObjectTransfNode;129;-185.8464,64.04173;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-105.1437,241.4774;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;177;848.856,-1303.676;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;68.459,252.0483;Inherit;False;Property;_Cutout;Cutout;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;1039.691,-1046.611;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;73;40.71397,142.3904;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;1047.856,-1145.676;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;173;1155.255,-937.8816;Inherit;False;Property;_ColorIntensity;Color Intensity;1;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;176;1255.856,-1037.676;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;11;628,56.5;Inherit;False;Constant;_Glow;Glow;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;47;244.1381,135.1629;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;1395.856,-1026.276;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;144;401.1645,53.68394;Inherit;False;Property;_Keyword1;Keyword 1;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;135;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;828.459,58.04828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;1539.238,-1024.262;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;1067.176,59.56042;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;188;1032.19,-1230.749;Inherit;False;clr;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;238.0654,248.8193;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;209;106.772,-94.21606;Inherit;True;Property;_MainTex;MainTexture;2;0;Create;False;0;0;0;False;0;False;-1;None;b8bb4920a4f49cd47b2a3e5bd27befe2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;190;263.0738,-182.5606;Inherit;False;187;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;198;575.4047,-221.4659;Inherit;False;Property;_CullMode;Cull Mode;19;1;[Header];Create;True;1;Other;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;401.4875,286.7144;Inherit;False;188;clr;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;599.772,-128.2161;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;143;733.0634,188.4332;Inherit;False;Constant;_One;One;20;0;Create;True;0;0;0;False;0;False;1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.StepOpNode;52;425.7057,171.3465;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;205;1209.888,26.48693;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;140;1126.54,527.6143;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;139;1112.486,677.0839;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;755.5562,-116.3359;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;135;1218.519,113.6982;Inherit;False;Property;_QuestCutout;Quest Cutout;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;QUEST_CUTOUT;Toggle;2;Key0;Key1;Create;False;False;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;1325.833,581.27;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;753.9879,-220.1019;Inherit;False;2;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;615.576,132.9096;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;113;567.1307,651.3835;Half;False;Property;_TransformOffset;_TransformOffset;10;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;118;879.1307,154.3835;Inherit;False;Constant;_Zero;Zero;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;136;1470.194,490.5663;Inherit;False;Property;_Keyword0;Keyword 0;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;135;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;112;449.1307,523.3835;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;119;1523.877,149.1012;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;101;821.1307,263.3835;Inherit;False;return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge)@;3;Create;5;True;CutPlane;FLOAT4;0,0,0,0;In;;Half;False;True;SlicePos;FLOAT3;0,0,0;In;;Inherit;False;True;localpos;FLOAT3;0,0,0;In;;Inherit;False;True;TransformOffset;FLOAT3;0,0,0;In;;Inherit;False;True;SliceEdge;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;161;684.0042,518.6026;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;115;1109.184,227.6754;Inherit;False;Property;_EnablePlaneCut;Enable PlaneCut;11;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;194;922.0942,-106.5396;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;146;-136.9351,373.5331;Inherit;False;Property;_CutPlane;_CutPlane;14;1;[Header];Create;True;1;Cutout Options;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;111;475.1307,388.3835;Half;False;Property;_SlicePos;_SlicePos;9;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;123;1087.502,426.5605;Inherit;False;Property;_UseGlowEdge;Use Glow Edge;12;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;204;1376.819,435.5537;Inherit;False;EdgeCutoutGlow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;206;284.172,377.684;Inherit;False; return(float4(x,y,z,w))@;4;Create;4;True;x;FLOAT;0;In;;Inherit;False;True;y;FLOAT;0;In;;Inherit;False;True;z;FLOAT;0;In;;Inherit;False;True;w;FLOAT;0;In;;Inherit;False;bruh;True;False;0;;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleRemainderNode;207;94.17203,405.684;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;292.1307,516.3835;Inherit;False;Property;_SliceEdge;Slice Edge;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;122;824.1307,428.3835;Inherit;False;return slice(CutPlane, SlicePos, localpos, TransformOffset, SliceEdge)@;3;Create;5;True;CutPlane;FLOAT4;0,0,0,0;In;;Half;False;True;SlicePos;FLOAT3;0,0,0;In;;Inherit;False;True;localpos;FLOAT3;0,0,0;In;;Inherit;False;True;TransformOffset;FLOAT3;0,0,0;In;;Inherit;False;True;SliceEdge;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;24;1859.694,-94.03145;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Urki/NoteSimple;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;Mobile/Diffuse;17;-1;-1;-1;0;False;0;0;True;198;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;201;0;169;0
WireConnection;216;0;215;0
WireConnection;216;1;217;0
WireConnection;214;0;201;0
WireConnection;214;1;216;0
WireConnection;178;3;179;0
WireConnection;202;0;214;0
WireConnection;200;0;178;0
WireConnection;164;0;166;0
WireConnection;164;1;165;0
WireConnection;164;2;202;0
WireConnection;212;0;174;0
WireConnection;212;1;213;0
WireConnection;186;0;164;0
WireConnection;130;0;128;0
WireConnection;180;0;200;0
WireConnection;180;1;181;0
WireConnection;163;1;186;0
WireConnection;163;2;212;0
WireConnection;129;0;130;0
WireConnection;131;0;39;0
WireConnection;177;0;180;0
WireConnection;171;0;163;0
WireConnection;171;1;172;0
WireConnection;171;2;177;0
WireConnection;73;0;129;0
WireConnection;73;1;131;0
WireConnection;182;0;180;0
WireConnection;182;1;172;0
WireConnection;176;0;171;0
WireConnection;176;1;182;0
WireConnection;47;0;73;0
WireConnection;47;1;35;0
WireConnection;183;0;176;0
WireConnection;183;1;173;0
WireConnection;144;1;47;0
WireConnection;144;0;11;0
WireConnection;48;0;11;0
WireConnection;48;1;144;0
WireConnection;187;0;183;0
WireConnection;116;0;48;0
WireConnection;188;0;172;0
WireConnection;51;0;35;0
WireConnection;210;0;190;0
WireConnection;210;1;209;0
WireConnection;52;0;51;0
WireConnection;52;1;73;0
WireConnection;205;0;116;0
WireConnection;139;0;35;0
WireConnection;192;0;210;0
WireConnection;192;1;205;0
WireConnection;135;1;52;0
WireConnection;135;0;143;0
WireConnection;142;0;140;0
WireConnection;142;1;139;0
WireConnection;196;0;198;0
WireConnection;49;0;189;0
WireConnection;49;1;116;0
WireConnection;136;1;140;0
WireConnection;136;0;142;0
WireConnection;119;0;135;0
WireConnection;101;0;206;0
WireConnection;101;1;111;0
WireConnection;101;2;112;0
WireConnection;101;3;113;0
WireConnection;101;4;146;4
WireConnection;161;0;124;0
WireConnection;161;1;146;4
WireConnection;115;1;118;0
WireConnection;115;0;101;0
WireConnection;194;0;192;0
WireConnection;194;1;49;0
WireConnection;194;2;196;0
WireConnection;123;1;118;0
WireConnection;123;0;122;0
WireConnection;206;0;146;1
WireConnection;206;1;207;0
WireConnection;206;2;146;3
WireConnection;206;3;146;3
WireConnection;207;0;146;2
WireConnection;122;0;206;0
WireConnection;122;1;111;0
WireConnection;122;2;112;0
WireConnection;122;3;113;0
WireConnection;122;4;161;0
WireConnection;24;2;194;0
WireConnection;24;9;116;0
WireConnection;24;10;119;0
WireConnection;24;11;136;0
ASEEND*/
//CHKSM=7C9D00FEC7E34970BA29A286458E540AF0C60A8A