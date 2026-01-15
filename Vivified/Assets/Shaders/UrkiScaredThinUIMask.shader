Shader "Urki/ScaredThin/UIMask"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _ColorTex ("Border Color Texture", 2D) = "white" {}
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
                float4 clr : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 clr : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ColorTex;
            float4 _Color;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v); //Insert
                UNITY_INITIALIZE_OUTPUT(v2f, o); //Insert
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //Insert
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.clr = v.clr;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 regularTex = tex2D(_MainTex, i.uv);
                float4 colorMaskTex = tex2D(_ColorTex, i.uv);
                float4 col = regularTex * (1 - colorMaskTex.a);
                col += (regularTex * (_Color * i.clr)) * colorMaskTex.a;

                col.a *= 0;
                return col;
            }
            ENDCG
        }
    }
}
