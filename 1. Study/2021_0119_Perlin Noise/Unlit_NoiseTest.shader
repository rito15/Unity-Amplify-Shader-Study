// 설명 : 
Shader "Unlit/NoiseTest"
{
    Properties
    {
        [HideInInspector] _MainTex("Texture", 2D) = "white" {}
        _Tint("Tint", Color) = (1,1,1,1)
        _NoiseBumpX("Noise Bump X", Range(0, 1)) = 0.05
        _NoiseBumpY("Noise Bump Y", Range(0, 1)) = 0.05
        _NoiseBumpZ("Noise Bump Z", Range(0, 1)) = 0.05
        _NoiseFlowX("Noise Flow X", Range(0, 5)) = 1
        _NoiseFlowY("Noise Flow Y", Range(0, 5)) = 1
        _NoiseFlowZ("Noise Flow Z", Range(0, 5)) = 1
        _NoiseDensity("Noise Density", Range(0, 10)) = 1
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                // make fog work
                #pragma multi_compile_fog

                #include "UnityCG.cginc"
                #include "UnityLightingCommon.cginc" // for _LightColor0
                #include "NoiseSimplex.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    fixed4 diff : COLOR0;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;

                half4 _Tint;
                float _NoiseBumpX;
                float _NoiseBumpY;
                float _NoiseBumpZ;
                float _NoiseFlowX;
                float _NoiseFlowY;
                float _NoiseFlowZ;
                float _NoiseDensity;

                v2f vert(appdata v)
                {
                    v2f o;
                    float4 vert = v.vertex;
                    float t = fmod(_Time.y, 600);
                    half density = _NoiseDensity;
                    float noise = snoise(vert.xz * density + t);

                    float3 nf = float3(_NoiseFlowX, _NoiseFlowY, _NoiseFlowZ);
                    float3 nb = float3(_NoiseBumpX, _NoiseBumpY, _NoiseBumpZ);
                    float3 st = sin(nf * t) * 0.05 + 0.95;// 하는 역할이 없음

                    float3 n3 = noise * st * nb;

                    vert.xyz *= sin(t) * 0.05 + 0.95;

                    vert.xyz += n3;


                    // DIFFUSE
                    half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                    o.diff = nl * _LightColor0;

                    o.vertex = UnityObjectToClipPos(vert);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv);


                    col.rgb = _Tint.rgb;
                    col *= i.diff;

                    return col;
                }
                ENDCG
            }
        }
}
