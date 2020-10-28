// 설명 : 비내리는 예쁜 유리창
Shader "Unlit/RainyWindow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size("Size", float) = 1
        _T("Time", float) = 1
        _DropSpeed("Drop Speed", float) = 1
        _Distortion("Distortion", range(-5, 5)) = 1
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

            #define S(a, b, t) smoothstep(a, b, t)

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
            float _Size;
            float _T;
            float _DropSpeed;
            float _Distortion;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // 노이즈
            float N21(float2 p)
            {
                p = frac(p * float2(123.34, 345.45));
                p += dot(p, p + 34.345);
                return frac(p.x * p.y);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = 0;
                float t = fmod(_Time.y + _T, 7200); // 2시간마다 반복
                t *= _DropSpeed; // 물방울 떨어지는 속도 계수 곱해주기

                float2 aspect = float2(2, 1);     // 가로 타일링 2배
                float2 uv = i.uv * _Size * aspect;
                uv.y += t * 0.25;

                // UV를 타일링하여, gv는 각각 타일링 된 영역의 uv로 사용
                float2 gv = frac(uv) - 0.5;

                // 각각의 gv 박스에 서로 다른 고윳값 배정
                float2 id = floor(uv);

                // 노이즈(0 ~ 1 범위) => 각각의 gv마다 물방울이 다르게 떨어지도록
                float n = N21(id);
                t += n * 6.2831; // sin 그래프는 2pi 주기이므로 주기별 랜덤 반복

                // ========================================================== //
                // x, y : 각각의 gv 내에서 drop, trail의 위치에 빼주는 offset //
                // ========================================================== //

                float w = i.uv.y * 10;
                float x = (n - 0.5) * 0.6; // -0.3 ~ 0.3 범위 랜덤 값 => 0.4였으나, 잘리는 현상 발견하여 수정
                //x = (0.3 - abs(x));        // 0 ~ 0.3 범위로 조정

                // x : 좌우 offset : sin(3x) * sin(x^6)
                // 불규칙하게 좌우 이동하는 그래프
                x += x * (sin(3 * w) * pow(sin(w), 6) * 0.45);

                // y : 상하 offset : -sin(x + sin(x + sin(x) * 0.5)) * 0.45
                // 내려갈 때는 빠르고 올라갈 때는 느린 그래프
                float y = -sin(t + sin(t + sin(t) * 0.5)) * 0.45;

                // 물방울 하단이 좀더 부드러운 타원꼴을 나타내게 함
                // 각각 -x를 해주는 이유 : x 좌표가 이동해도 형태를 유지하기 위해
                y -= (gv.x - x) * (gv.x - x);

                // gv : 세로로 긴 타원, gv / aspect : 동그란 원
                float2 dropPos = (gv - float2(x, y)) / aspect;
                float drop = S(0.05, 0.03, length(dropPos));   // 물방울 생성

                float2 trailPos = (gv - float2(x, t * 0.25)) / aspect;
                trailPos.y = (frac(trailPos.y * 8) - 0.5) / 8; // 물방을 궤적들을 y 방향으로 8번 타일링(반복)
                float trail = S(0.03, 0.01, length(trailPos)); // 물방울 궤적들 그려주기
                
                float fogTrail = S(-0.05, 0.05, dropPos.y); // trail이 drop보다 아래 있는 경우는 그리지 않음
                fogTrail *= S(0.5, y, gv.y);                // trail에 gradient 효과(위에 있을수록 더 희미해지게)
                trail *= fogTrail;

                // 물방울을 따라 물 자국 남기기
                fogTrail *= S(0.05, 0.04, abs(dropPos.x));
                col += fogTrail * 0.5;

                col += trail;
                col += drop;

                //col *= 0; col.rg = id * 0.1;

                float2 offset = drop * dropPos + trail * trailPos + fogTrail * 0.001;
                col = tex2D(_MainTex, i.uv + offset * _Distortion);
                // 테스트용으로 uv를 0~1에서 remap하여 0.2~0.8로 옮김
                //col = tex2D(_MainTex, ((i.uv * 3 + 1) * 0.2) + offset * _Distortion);

                // Red Grid Border
                //if (gv.x > 0.48 || gv.y > 0.49) col = float4(1, 0, 0, 1);

                return col;
            }
            ENDCG
        }
    }
}
