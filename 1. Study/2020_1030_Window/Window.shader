// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// 참고 : https://funfunhanblog.tistory.com/46

// 설명 : 유리창 쉐이더(투과, 블러, 반사)
// 게임오브젝트에 겹치는 Reflection Probe 필요
Shader "Custom/Window"
{
    Properties
    {
        [HideInInspector] _MainTex("Texture", 2D) = "white" {}

        _Blur("Blur", range(0, 1)) = 0.3
        _BlurResolution("Blur Resolution", float) = 32

        [Space]
        _Brightness("Window Brightness", range(0, 1)) = 0.9
        _Reflection("Reflection", range(0, 1)) = 0.3
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
        LOD 100

        GrabPass { "_GrabTexture" }

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 grabUv : TEXCOORD1;
                half3 worldRefl : TEXCOORD2;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // 노이즈
            float N21(float2 p)
            {
                p = frac(p * float2(123.34, 345.45));
                p += dot(p, p + 34.345);
                return frac(p.x * p.y);
            }

            sampler2D _MainTex, _GrabTexture;
            float4 _MainTex_ST;
            float _Blur;
            float _BlurResolution;
            float _Brightness;
            float _Reflection;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // Grab UV 생성
                o.grabUv = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));

                // 월드 반사 계산
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldRefl = reflect(-worldViewDir, worldNormal);

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = 0;
                float blur = _Blur * 0.02;
                float2 projUv = i.grabUv.xy / i.grabUv.w;

                const float numSamples = _BlurResolution;  // 샘플 개수에 따라 블러 해상도 증가
                float a = N21(i.uv) * 6.2831; // 회전 시작 값 : 노이즈 기반으로 설정
                for (float num = 0; num < numSamples; num++)
                {
                    float2 offs = float2(sin(num), cos(num)) * blur;

                    // 거리가 같은 원 위의 지점들로 이동시켜 블러하는 것이 아니라,
                    // 랜덤 위치로 텍스쳐를 샘플링시켜 블러 효과 만들기
                    float d = frac(sin((num + 1) * 546.0) * 5424.0);
                    d = sqrt(d);
                    offs *= d;

                    col += tex2D(_GrabTexture, projUv + offs);
                    a++;
                }
                col /= numSamples;

                //col = tex2D(_GrabTexture, projUv);

                // 리플렉션
                half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
                half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);

                col = lerp(col, float4(skyColor.rgb, 0), _Reflection);

                return col * _Brightness;
            }
            ENDCG
        }
    }
}
