Shader "Custom/Kaitlyn03/ParametricBoxOpaque" {
  Properties {
    _Color ("Color", Vector) = (1,0,0,0)
    [HideInInspector] _SizeParams ("Width, Length and Center", Vector) = (0.2,2,0.5,0)
    _FogStartOffset ("Fog Start Offset", Float) = 1
    _FogScale ("Fog Scale", Float) = 1
  }

  SubShader {
    Tags { "Queue"="Geometry" "RenderType"="Opaque" }

    Pass {
      CGPROGRAM
      #pragma multi_compile __ _ENABLE_BLOOM_FOG
      #pragma shader_feature MAIN_EFFECT_ENABLED
      #pragma multi_compile_instancing
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"
      #include "UnityInstancing.cginc"

      struct appdata_t {
        float4 vertex : POSITION;
        UNITY_VERTEX_INPUT_INSTANCE_ID
      };
      struct v2f {
        float4 vertex : SV_POSITION;
        float3 worldPos : TEXCOORD1;
        float4 screenPos : TEXCOORD2;
        UNITY_VERTEX_INPUT_INSTANCE_ID
      };

      UNITY_INSTANCING_BUFFER_START(MyProperties)
        UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
        UNITY_DEFINE_INSTANCED_PROP(float3, _SizeParams)
      UNITY_INSTANCING_BUFFER_END(MyProperties)

      float _FogStartOffset;
      float _FogScale;
	  float _CustomFogGammaCorrection;

      uniform float _CustomFogAttenuation;
      uniform float _CustomFogOffset;
      uniform sampler2D _BloomPrePassTexture;

      v2f vert(appdata_t v) {
        v2f o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        float3 sizeParams = UNITY_ACCESS_INSTANCED_PROP(MyProperties, _SizeParams);
        float4 vertex = v.vertex;
        vertex.y = (v.vertex.y - sizeParams.z) * sizeParams.y;
        vertex.xz = v.vertex.xz * sizeParams.x;
        o.vertex = UnityObjectToClipPos(vertex);
        o.worldPos = mul(unity_ObjectToWorld, vertex);
        o.screenPos = ComputeNonStereoScreenPos(o.vertex);
        return o;
      }

      float4 frag(v2f i) : SV_Target {
        UNITY_SETUP_INSTANCE_ID(i);
        float4 color = UNITY_ACCESS_INSTANCED_PROP(MyProperties, _Color);
        float2 screenUV = i.screenPos.xy / i.screenPos.w;
        #ifdef UNITY_UV_STARTS_AT_TOP
				{
					//screenUV.y = 1 - screenUV.y;
				}
				#else
				{
					screenUV.y = 1 - screenUV.y;
				}
        #endif
        float3 fogDistance = i.worldPos - _WorldSpaceCameraPos;
        float fogIntensity = max(sqrt(dot(fogDistance, fogDistance)) - _FogStartOffset, 0);
        fogIntensity = min(max(fogIntensity * _FogScale + -_CustomFogOffset, 0), 9999);
        fogIntensity = (-fogIntensity * _CustomFogAttenuation) * 1.44269502;
        fogIntensity = 1 - max(1 - exp2(fogIntensity), 0);
        float4 BloomTex = tex2D(_BloomPrePassTexture, screenUV);
        BloomTex = log2(BloomTex);
        BloomTex *= _CustomFogGammaCorrection;
        BloomTex = exp2(BloomTex);
        float4 oneMinus = BloomTex * (1 - fogIntensity);
        fogIntensity = fogIntensity * color.a;
        #ifdef MAIN_EFFECT_ENABLED
            return float4(fogIntensity * color.rgb + (oneMinus), fogIntensity);
        #else
            return float4(fogIntensity * (color.rgb + color.a) + (oneMinus), fogIntensity);
        #endif
      }
      ENDCG
    }
  }
}
