Shader "Urki/Post/NoiseDisplacement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Displacement Texture", 2D) = "white" {}
        _DispIntensity ("Displacement Strength", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, v2f o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex);
            sampler2D _NoiseTex;
            float _DispIntensity;

            fixed4 frag (v2f i) : SV_Target
            {
                // do displacement shit
                float2 screenUV = i.uv;
                float4 noiseTex = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_NoiseTex, i.uv);
                screenUV.x += (noiseTex.x * _DispIntensity) - (_DispIntensity/2);

                // Apply displacement UV to main texture
                float4 clr = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, screenUV);

                return clr;
            }
            ENDCG
        }
    }
}
