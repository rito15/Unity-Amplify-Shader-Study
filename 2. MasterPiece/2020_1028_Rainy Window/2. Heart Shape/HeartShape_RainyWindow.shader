// 설명 : 하트 모양의 비가 내리는 예쁜 유리창
Shader "Custom/HeartShape_RainyWindow"
{
    Properties
    {
        [HideInInspector] _MainTex("Texture", 2D) = "white" {}

        _SizeX("Size X", float) = 1
        _SizeY("Size Y", float) = 1

        [Space]
        _LayerCount("Drops Count", range(1, 5)) = 3
        _DropSpeed("Drop Speed", float) = 1
        _Distortion("Distortion", range(-10, 5)) = -10

        [Space]
        _Blur("Blur", range(0, 1)) = 0.15
        _BlurResolution("Blur Resolution", float) = 32

        [Space]
        _Brightness("Window Brightness", range(0, 1)) = 0.9
    }
        SubShader
        {
            // GrabTexture를 사용하여 씬을 캡쳐해 사용할 것이기 때문에,
            // 이 쉐이더가 적용되는 오브젝트는 캡쳐의 대상이 되지 않도록(가장 나중에 렌더링 되게)
            // Queue를 Transparent로 설정
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
                    float4 grabUv : TEXCOORD1;
                    UNITY_FOG_COORDS(1)
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex, _GrabTexture;
                float4 _MainTex_ST;
                float _SizeX, _SizeY;
                float _LayerCount;
                float _DropSpeed;
                float _Distortion;
                float _Blur;
                float _BlurResolution;
                float _Brightness;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                    // Grab UV 생성
                    o.grabUv = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));
                    //o.grabUv = ComputeGrabScreenPos(o.vertex);

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

                // 레이어 : 하나의 물방울 효과 UV 세트
                float3 Layer(float2 UV, float t)
                {
                    float2 aspect = float2(2, 1);     // 가로 타일링 2배
                    float2 uv = UV * float2(_SizeX * 0.6, _SizeY) * aspect;
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

                    float w = UV.y * 10;
                    float x = (n - 0.5) * 0.6; // -0.3 ~ 0.3 범위 랜덤 값 => 0.4였으나, 잘리는 현상 발견하여 수정
                    //x = (0.3 - abs(x));        // 0 ~ 0.3 범위로 조정

                    // x : 좌우 offset : sin(3x) * sin(x^6)
                    // 불규칙하게 좌우 이동하는 그래프
                    //x += x * (sin(3 * w) * pow(sin(w), 6) * 0.45);

                    // y : 상하 offset : -sin(x + sin(x + sin(x) * 0.5)) * 0.45
                    // 내려갈 때는 빠르고 올라갈 때는 느린 그래프
                    float y = -sin(t + sin(t + sin(t) * 0.5)) * 0.45;

                    // 물방울 하단이 좀더 부드러운 타원꼴을 나타내게 함
                    // 각각 -x를 해주는 이유 : x 좌표가 이동해도 형태를 유지하기 위해
                    //y -= (gv.x - x) * (gv.x - x);
                    y += sqrt(abs(gv.x - x)) * 0.2;

                    // gv : 세로로 긴 타원, gv / aspect : 동그란 원
                    float2 dropPos = (gv - float2(x, y)) / aspect;
                    float drop = S(0.05, 0.03, length(dropPos));   // 물방울 생성

                    float yy = t * 0.25 + sqrt(abs(gv.x - x)) * 0.2;
                    float2 trailPos = (gv - float2(x, yy)) / aspect;
                    trailPos.y = (frac(trailPos.y * 8) - 0.5) / 8; // 물방을 궤적들을 y 방향으로 8번 타일링(반복)
                    float trail = S(0.03, 0.01, length(trailPos)); // 물방울 궤적들 그려주기

                    float fogTrail = S(-0.05, 0.05, dropPos.y); // trail이 drop보다 아래 있는 경우는 그리지 않음
                    fogTrail *= S(0.5, y, gv.y);                // trail에 gradient 효과(위에 있을수록 더 희미해지게)
                    trail *= fogTrail;

                    // 물방울을 따라 물 자국 남기기
                    fogTrail *= S(0.05, 0.04, abs(dropPos.x));

                    //col += fogTrail * 0.5;
                    //col += trail;
                    //col += drop;

                    // Drop + Trail 모두 계산된 결과
                    float2 offset = drop * dropPos + trail * trailPos;// +fogTrail * 0.001;

                    return float3(offset, fogTrail);
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float4 col = 0;
                    float t = fmod(_Time.y, 7200); // 2시간마다 반복
                    t *= _DropSpeed; // 물방울 떨어지는 속도 계수 곱해주기

                    float3 drops = Layer(i.uv, t);
                    //drops += Layer(i.uv * 1.23, t * 0.5);
                    //drops += Layer(i.uv * 2.34, t * 2);
                    //drops += Layer(i.uv * 1.35 + 8.67, t); // 여러 개의 레이어 추가 가능
                    for (float num = 1; num < _LayerCount; num++)
                    {
                        drops += Layer(i.uv * 1.23 * num, t * (1 + num * 0.2));
                    }

                    float2 dropOffset = drops.xy;
                    float fogTrail = drops.z;

                    // 멀리서 봤을 때 자글자글하지 않고 부드러운 창문으로 보이도록 디테일 줄여주기
                    // fwidth(i.uv) 값은 카메라와 이 오브젝트가 멀어질수록 커짐
                    // fade 값은 카메라와 이 오브젝트가 멀어질수록 작아짐
                    float fade = 1 - saturate(fwidth(i.uv) * 100);


                    // MipMap을 이용한 블러 효과
                    float blur = _Blur * 7 * (1 - fogTrail * fade);

                    //col = tex2Dlod(_MainTex, float4(i.uv + dropOffset * _Distortion, 0, blur));

                    float2 projUv = i.grabUv.xy / i.grabUv.w;
                    projUv += dropOffset * (_Distortion * fade); // Grab에 물방울 추가

                    blur *= 0.01;

                    // GrabPass는 MipMap을 생성하지 않기 때문에,
                    // GrabTexture에 캡처된 화면을 직접 블러시켜 사용
                    // 블러 원리 : 텍스쳐를 여러 방향으로 이동시켜 각각 샘플링하고
                    // 모두 더해준 뒤 샘플 개수로 나누기
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

                    //col = tex2Dproj(_GrabTexture, i.grabUv);
                    //col = tex2D(_GrabTexture, projUv);

                    // Red Grid Border
                    //if (gv.x > 0.48 || gv.y > 0.49) col = float4(1, 0, 0, 1);

                    return col * _Brightness;
                }
                ENDCG
            }
        }
}
