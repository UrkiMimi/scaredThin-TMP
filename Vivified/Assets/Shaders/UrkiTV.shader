Shader "Urki/Post/AV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Smear ("Color Smear", Float) = 0.07
        _Kernel ("Blur Kernel", float) = 0.2
        _TangentHead ("Tangent Head", float) = 0.0
        _NoiseScale ("Noise Scale", float) = 1
        _ColorLoss ("Color Loss", float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex);
            UNITY_DECLARE_SCREENSPACE_TEXTURE(_NoiseTex);
            float4 _MainTex_ST;
            float4 _NoiseTex_TexelSize;
            float _Kernel;
            float _Smear;
            float _TangentHead;
            float _NoiseScale;
            float _ColorLoss;

            // yiq shit
            float4 rgb2yiq(float4 c)
            {
                return float4(
                    (0.2989*c.x + 0.5959*c.y + 0.2115*c.z),
                    (0.5870*c.x - 0.2744*c.y - 0.5229*c.z),
                    (0.1140*c.x - 0.3216*c.y + 0.3114*c.z),
                    1
                );
            }

            // horizontal blur
            float4 blurX(float2 UV, int steps, float kernel, float offset)
            {
                float4 blurBuffer;
                float2 uv2;
                for (int j = 0; j < steps; j++)
                {
                    uv2 = UV + float2(((kernel * steps)/2) + (kernel * j) + offset, 0.0);
                    blurBuffer += UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, uv2);
                }
                blurBuffer /= steps;
                return blurBuffer;
            }

            // taken from unity forum (kudos to Przemyslaw_Zaworski)
            float random (float2 uv)
            {
                return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
            }

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);

                // Screen UV
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);


                //UV tangent bottom
                float2 UV = i.uv;
                float pi = 3.14159;
                UV.x += (tan((UV.y - 1) * pi/2)) * (_TangentHead * random(_Time));

                // horizontal blur for rgb stuff
                float4 blurBlue = blurX(UV, 8, (_Kernel * 1.5) * 0.05, -(_Kernel/2));
                float4 blurYellow = blurX(UV, 4, _Kernel * 0.01, + _Kernel/2);
                float4 col = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, UV);
                col.xy = lerp(col.xy, blurYellow.xy, _Smear / 4);
                col.z = lerp(blurBlue.z, col.z, _Smear);

                //noise tex
                /*
                float Aspect = _ScreenParams.x / _ScreenParams.y;
                float2 NoiseUV = float2((i.uv2.x * Aspect)* _NoiseTex_TexelSize.z, i.uv2.y * _NoiseTex_TexelSize.z).y;
                NoiseUV.xy += random(_Time);
                float blueNoise = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_NoiseTex, NoiseUV).x;
                blueNoise *= _ColorLoss;

                if(blueNoise > 0.5) {
                    blueNoise = 1; 
                }
                else {
                    blueNoise = 0;
                }

                // colorloss effects
                col = lerp(col, (col.x + col.y + col.z)/3, blueNoise);*/


                return col;
            }
            ENDCG
        }
    }
}
