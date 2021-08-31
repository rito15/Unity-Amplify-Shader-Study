// 출처 : https://blog.naver.com/mnpshino/221478999495

Shader "Rito/Screen Zoom Blur"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _CenterPos("Center Pos", Vector) = (0.5, 0.5, 0., 0.)
        _SampleCount("Sample Count", Float) = 8
        _BlurSize("Blur Size", Range(0, 100)) = 20
        _AreaRange("Area Range", Range(0, 1)) = 0.5
        _AreaSmoothness("Area Smoothness", Range(0, 1)) = 0.5
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
            half4 _MainTex_TexelSize;

            half2 _CenterPos;
            half _SampleCount;
            half _BlurSize;
            half _AreaRange;
            half _AreaSmoothness;

            half4 frag (v2f i) : SV_Target
            {
                half4 mainCol = tex2D(_MainTex, i.uv);

                half2 uv2 = i.uv - _CenterPos;
                half4 col = half4(0., 0., 0., 1.);

                _AreaSmoothness += 0.001;

                half range = (1. - (_AreaRange + _AreaSmoothness)) * (1. + _AreaSmoothness);
                half circleRange = smoothstep(range, range + _AreaSmoothness, length(uv2));

                for(int a = 0; a < _SampleCount; a++)
                {
                    half scale = 1. - _BlurSize * _MainTex_TexelSize * a;
                    col.rgb += tex2D(_MainTex, uv2 * scale + _CenterPos).rgb;
                }

                col.rgb /= _SampleCount;

                return lerp(mainCol, col, circleRange);
            }
            ENDCG
        }
    }
}
