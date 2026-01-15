Shader "Hidden/Urki/MainShaderKawase"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HideInInspector] _BTex ("Bloom Texture", 2D) = "white" {}
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
            #pragma multi_compile _ BLUR_ONLY_ENABLED

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
            float4 _MainTex_TexelSize;
            sampler2D _BTex;
            float4 _BTex_ST;
            float _BIteration;
            float _BIntensity;
            float _BThreshold;
            float _BKSize;
            float _BDirCount;
            int _BDebug;


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
                float4 bloomBuffer;
                float4 main;
                float4 tmpTex;
                float4 col;
                float2 offsets[5] = {
                    float2(-1,-1), float2(1,-1),
                    float2(-1,1), float2(1,1),
                    float2(0,0)
                };
                float aspectRatio = _ScreenParams.x / _ScreenParams.y;
                
                // bloom 
                /*
                for (int i = 0; i<_BIteration; i++)
                {
                    float blurSize = (i/_BIteration) * (_BKSize * 0.02);
                    //kawase loop
                    for (int k = 0; k < _BDirCount; k++)
                    {
                        float angle = ((k/_BDirCount) * 360) * (3.141592/180);
                        float2 dir = float2(cos(angle), sin(angle) * aspectRatio);
                        tmpTex = tex2D(_BTex, inp.uv + (dir * blurSize));
                        tmpTex *= tmpTex.a * _BIntensity;
                        bloomBuffer += tmpTex;
                    }
                }
                bloomBuffer /= _BIteration;
                bloomBuffer /= _BDirCount;*/
                bloomBuffer = tex2D(_BTex, inp.uv);
                bloomBuffer *= _BIntensity;


                // main texture
                main = tex2D(_MainTex, inp.uv);
                main += main.a * (_BThreshold);

                #ifdef BLUR_ONLY_ENABLED
                    col = bloomBuffer;
                #else
                    col = main + bloomBuffer;
                #endif
                return col;
            }
            ENDCG
        }
    }
}
