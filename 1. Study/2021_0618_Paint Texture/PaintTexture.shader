﻿// https://www.patreon.com/posts/rendertexture-15961186
// https://pastebin.com/LxDYqWBh

Shader "Custom/PaintTexture"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _PaintTex ("Painted Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex;
        sampler2D _PaintTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 main = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 painted = tex2D (_PaintTex, IN.uv_MainTex);

            o.Emission = lerp(main.rgb, painted.rgb, painted.a);

            o.Alpha = main.a * painted.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
