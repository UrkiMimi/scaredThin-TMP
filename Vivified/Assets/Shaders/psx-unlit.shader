// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "psx/unlit" {
	Properties{
		_MainTex("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
		[MaterialToggle] _CustomColors("Custom Colors", Float) = 0
		_Glow ("Glow", Range (0, 1)) = 0
		_Snapping("Snapping Intensity", Float) = 1024

        
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		Pass{
		Lighting On
		Cull Off
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
    	float2 uv : TEXCOORD0;

    	UNITY_VERTEX_INPUT_INSTANCE_ID //Insert
	};

	struct v2f
	{
		fixed4 pos : SV_POSITION;
		half4 color : COLOR0;
		half4 colorFog : COLOR1;
		float2 uv_MainTex : TEXCOORD0;
		half3 normal : TEXCOORD1;
		UNITY_VERTEX_OUTPUT_STEREO //Insert
	};

	float4 _MainTex_ST;
	uniform half4 unity_FogStart;
	uniform half4 unity_FogEnd;

    float _Snapping;
	v2f vert(appdata_full v)
	{
		v2f o;

    	UNITY_SETUP_INSTANCE_ID(v); //Insert
    	UNITY_INITIALIZE_OUTPUT(v2f, o); //Insert
    	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //Insert

		//Vertex snapping
		float4 snapToPixel = UnityObjectToClipPos(v.vertex);
		float4 vertex = snapToPixel;
		vertex.xyz = snapToPixel.xyz / snapToPixel.w;
		vertex.x = floor(_Snapping * vertex.x) / _Snapping;
		vertex.y = floor(_Snapping * vertex.y) / _Snapping;
		vertex.xyz *= snapToPixel.w;
		o.pos = vertex;

		//Vertex lighting 
		o.color = v.color*UNITY_LIGHTMODEL_AMBIENT;;

		float distance = length(mul(UNITY_MATRIX_MV,v.vertex));

		//Affine Texture Mapping
		float4 affinePos = vertex;//vertex;				
		o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uv_MainTex *= distance + (vertex.w*(UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;
		o.normal = distance + (vertex.w*(UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;

		//Fog
		float4 fogColor = unity_FogColor;

		float fogDensity = (unity_FogEnd - distance) / (unity_FogEnd - unity_FogStart);
		o.normal.g = fogDensity;
		o.normal.b = 1;

		o.colorFog = fogColor;
		o.colorFog.a = clamp(fogDensity,0,1);

		//Cut out polygons
		if (distance > unity_FogStart.z + unity_FogColor.a * 255)
		{
			o.pos.w = 0;
		}


		return o;
	}

	sampler2D _MainTex;
    float4 _Color;
    float _Glow;

	float4 frag(v2f IN) : COLOR
	{
		float4 psxTex = tex2D(_MainTex, IN.uv_MainTex / IN.normal.r);
		float4 color = _Color * psxTex;
		return float4(color.rgb, _Glow);
	}
		ENDCG
	}
	}
}