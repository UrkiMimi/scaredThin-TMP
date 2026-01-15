Shader "Hidden/Urki/Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BKSize;
            float _DirSize;
            float _BIterations;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f inp) : SV_Target
            {
                float4 tmpTex;
                float4 bloomBuffer;
                float aspectRatio = _ScreenParams.x / _ScreenParams.y;


                float blurSize = _BKSize * 0.02;
                //kawase loop
                for (int k = 0; k < _DirSize; k++)
                {
                    float angle = ((k/_DirSize) * 360) * (3.141592/180);
                    float2 dir = float2(cos(angle), sin(angle) * aspectRatio);
                    tmpTex = tex2D(_MainTex, inp.uv + (dir * blurSize));
                    tmpTex *= clamp(tmpTex.a * (_BIterations * _DirSize),0,1);

                    bloomBuffer += tmpTex;
                }
                bloomBuffer /= _DirSize;

                float4 col = bloomBuffer;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
