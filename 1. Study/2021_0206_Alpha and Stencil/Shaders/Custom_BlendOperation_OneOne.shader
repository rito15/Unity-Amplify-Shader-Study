
Shader "Custom/BlendOperation_OneOne"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Alpha("Alpha", Range(0,1)) = 0.7
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        ZWrite Off
        Blend One One
        
        CGPROGRAM
        #pragma surface surf Lambert keepalpha
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        float _Alpha;

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a * _Alpha;
        }
        ENDCG
    }
    FallBack "Transparent"
}
