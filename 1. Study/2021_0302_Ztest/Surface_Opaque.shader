// 설명 : 
Shader "Custom/Surface_Opaque"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        [HideInInspector] _MainTex ("Albedo (RGB)", 2D) = "white" {}

        [Toggle] _ZWrite("Z Write", float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", Float) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        ZWrite [_ZWrite]
        ZTest [_ZTest]

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
