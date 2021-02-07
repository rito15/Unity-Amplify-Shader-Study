// 투명 쉐이더 기초
Shader "Custom/AlphaBasic"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" } // Transparent 설정
        //ZWrite Off
        blend srcAlpha oneminusSrcAlpha

        CGPROGRAM

        #pragma surface surf Lambert keepalpha // alpha:fade 설정
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Transparent" // 그림자 없애기
}
