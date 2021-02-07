
Shader "Custom/AlphaTest"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
        _Color("Color", Color) = (1,1,1,1) // 그림자 생성 관여
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }

        CGPROGRAM

        // 컷아웃 연결
        #pragma surface surf Lambert alphatest:_Cutoff // addshadow 안씀
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Legacy Shaders/Transparent/Cutout/Diffuse" // 그림자 생성
}
