Shader "Rito/Screen Blur"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Blur Area Mask", 2D) = "white" {}
        _Resolution("Resolution", Range(0, 1)) = 0.5
        _Intensity("Intensity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _MaskTex; // 블러 영역 마스크
            float _Resolution;
            float _Intensity;

            #define RANDOM_SEED 426.791

            static const half2 dir[8] = 
            {
                half2(1., 0.),
                half2(-1., 0.),
                half2(0., 1.),
                half2(0., -1.),
                half2(1., 1.),
                half2(-1., 1.),
                half2(1., 1.),
                half2(1., -1.),
            };

            float2 GetRandomDir(float2 uv, uint i)
            {
                float r1 = (uv.x * uv.y);
                float r2 = ((1. - uv.x) * uv.y);
                float r3 = (uv.x * (1. - uv.y));
                float r4 = ((1. - uv.x) * (1. - uv.y));

                float r = frac((r1 + r2 + r3 + r4) * RANDOM_SEED * i);
                float2 d = dir[i % 8] * r;
                // i % 2 : 좌우
                // i % 4 : 상하좌우
                // i % 8 : 8방향

                return d;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                uint sampleCount = (uint)(_Resolution * 64.);

                fixed4 mainColor = tex2D(_MainTex, i.uv);

                if(_Intensity <= 0.0 || _Resolution <= 0.0)
                    return mainColor;

                float4 col = 0.;
                for(uint index = 0; index < sampleCount; index++)
                {
                    float2 uv = i.uv - GetRandomDir(i.uv, index) * _Intensity * 0.05;
                    col += tex2D(_MainTex, uv);
                }
                
                fixed4 mask = tex2D(_MaskTex, i.uv);

                return lerp(mainColor, (col / sampleCount), mask);
            }
            ENDCG
        }
    }
}
