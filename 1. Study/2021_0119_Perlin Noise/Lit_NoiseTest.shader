// 설명 : 
Shader "Custom/Lit_NoiseTest"
{
    Properties
    {
        _EdgeLength("Edge length", Range(2,50)) = 5
        _Phong("Phong Strengh", Range(0,1)) = 0.5

        _NoiseBumpX("Noise Bump X", Range(0, 1)) = 0.05
        _NoiseBumpY("Noise Bump Y", Range(0, 1)) = 0.05
        _NoiseBumpZ("Noise Bump Z", Range(0, 1)) = 0.05
        _NoiseDensity("Noise Density", Range(0, 10)) = 1

        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows vertex:vert tessellate:tessEdge tessphong:_Phong

        // ================================ Tessellation =================================
        #include "Tessellation.cginc"
        #include "NoiseSimplex.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float _NoiseBumpX;
        float _NoiseBumpY;
        float _NoiseBumpZ;
        float _NoiseDensity;

        void vert(inout appdata v)
        {
            float4 vertex = v.vertex;
            float t = fmod(_Time.y, 600);
            half density = _NoiseDensity;
            float noise = snoise(vertex.xz * density + t);

            float3 nb = float3(_NoiseBumpX, _NoiseBumpY, _NoiseBumpZ);
            float3 n3 = noise * nb;

            vertex.xyz *= sin(t) * 0.05 + 0.95;
            vertex.xyz += n3;

            v.vertex = vertex;
        }

        float _Phong;
        float _EdgeLength;

        float4 tessEdge(appdata v0, appdata v1, appdata v2)
        {
            return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
        }

        // ================================ ------------- =================================

        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

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
