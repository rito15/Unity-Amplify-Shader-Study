// 설명 : 
Shader "Unlit/RotationTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 col = 0;
                float2 uv = i.uv;
                float2 uv2 = uv * 2.0 - 1.0;

                float t = -_Time.y;
                float2x2 uvRotMat = float2x2(cos(t), sin(t), -sin(t), cos(t));
                float2 uvRot = mul(uvRotMat, uv2);

                uv2 = uvRot;
                
                // Heart Shape
                /*float heartBlur = 0.1;
                float2 heartBase = float2(uv2.x * 0.7, uv2.y - sqrt(abs(uv2.x)) * 0.8 + 0.2);
                float heart = smoothstep(0.5, 0.5 - heartBlur, length(heartBase));*/

                float2  heartPos = float2(0.0, 0.0);
                float2  heartSizeWH = float2(0.4, 0.4);
                float heartBlur = 0.01;
                float2  uvHeart = (uv2 - heartPos) / (heartSizeWH * float2(1.15, 0.97));
                float2  heartBase = float2(uvHeart.x, uvHeart.y - sqrt(abs(uvHeart.x)) * 0.7 + 0.18);
                float heart = smoothstep(0.87, 0.87 - heartBlur, length(heartBase));

                col += heart;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
