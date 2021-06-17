Shader "Custom/Surface_VertexOffset"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _VectorTest("Target Position", vector) = (0,0,0,0)
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _Progress("Progress", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert

        sampler2D _MainTex;
        sampler2D _NoiseTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float4 _VectorTest;
        half _Progress;

        void vert(inout appdata_full v) 
        {
            fixed3 disp = tex2Dlod(_NoiseTex, fixed4(v.texcoord.xy, 0, 0));
            fixed4 targetPos = mul(unity_WorldToObject, _VectorTest.xyz);
            //v.vertex = lerp(v.vertex, targetPos, saturate((disp.r < _Progress)));

            float f = v.vertex.y + 2;
            //f *= disp + 0.5;

            v.vertex = lerp(v.vertex, targetPos, saturate(_Progress * f));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
