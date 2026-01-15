Shader "Urki/SimpleGrabPassPSX"
{
    Properties
    {
        [Space(0)][Header(Color Stuff)][Space]_Color("Color", Color) = (1,1,1,1)
        [Toggle]_CustomColors("Custom Colors", Float) = 1
        _AddColor ("Add Color", Float) = 0
        
        [Space(10)][Header(Displacement Stuff)][Space]_MainTex ("Displacement Texture", 2D) = "white" {}
        [Toggle] _DISP_PIXELS ("Displace By Pixels", Float) = 1
        _Intensity ("Displacement Intensity", Float) = 1
        _SatMix ("Saturation Mix", Float) = 1
        [Space(5)][Header(UV Scroll (Slightly Broken))][Space][Toggle] _SCROLL_UV ("Scroll UV", Float) = 0
		_ScrollUVVelocity ("Scroll UV Velocity", Vector) = (0,0,0,0)

        [Space(5)][Header(Experimental)][Space] _Snapping ("Vertex Snapping", Float) = 0
        _ScaleVector ("Scale Vector", Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "DisableBatching" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
        LOD 100
        ZWrite Off
        Cull Off

        GrabPass { "_GrabTexture1" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ QUEST
            #pragma shader_feature _DISP_PIXELS_ON
            #pragma shader_feature _SCROLL_UV_ON

            #include "UnityCG.cginc"

            #ifdef SHADER_API_GLES30
            UNITY_DECLARE_TEX2DARRAY(_GrabTexture1);
            #else
            UNITY_DECLARE_SCREENSPACE_TEXTURE(_GrabTexture1);
            #endif

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 scrnPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _AddColor;
            float _Intensity;
            float _Snapping;
            float _SatMix;
            float4 _ScrollUVVelocity;
            float4 _ScaleVector;

            v2f vert (appdata v)
            {
                v2f o;

                //Unity 2021 Thingy
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // Screen Coords
                o.scrnPos = ComputeGrabScreenPos(o.vertex);

                //Vertex snapping
		        float4 snapToPixel = UnityObjectToClipPos(v.vertex);
        		float4 vertex = snapToPixel;
        		vertex.xyz = snapToPixel.xyz / snapToPixel.w;
        		vertex.x = floor(_Snapping * vertex.x) / _Snapping;
                vertex.x *= _ScaleVector.x;
        		vertex.y = floor(_Snapping * vertex.y) / _Snapping;
                vertex.y *= _ScaleVector.y;
        		vertex.xyz *= snapToPixel.w;
        		o.vertex = vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                //Scrolling UV Thing
                float2 funnyUV = i.uv;
                #if _SCROLL_UV_ON
                funnyUV += (_Time * _ScrollUVVelocity);
                #endif

                // GrabPass Displacement Texture
                float4 dispTex = tex2D(_MainTex, funnyUV);
                dispTex = dispTex - 0.5;
                float2 displace = dispTex.xy;

                //If DISP_PIXELS is toggled on
                #if _DISP_PIXELS_ON
                displace *= (_Intensity * 0.001);
                #else
                displace *= _Intensity;
                #endif

                // Screen UV Stuff
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                displace += i.scrnPos.xy;
                float2 dispUV = displace / i.scrnPos.w;
                float3 proj = float3(dispUV, unity_StereoEyeIndex);

                //YIPPIE FUCKING GRABPASSS!!!!!!!!!!!!!!
                float4 gbTex = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture1, proj);

                fixed4 col = (_Color * gbTex) + (_AddColor * _Color);
                col.rgb = lerp(float3(0,0,0), col.rgb, _SatMix);
                col.a = gbTex.a;
                return col;
            }
            ENDCG
        }
    }
}
