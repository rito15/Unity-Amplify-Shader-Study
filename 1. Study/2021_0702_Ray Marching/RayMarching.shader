// https://www.youtube.com/watch?v=S8AWd66hoCo

Shader "Rito/RayMarching"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
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

            #include "UnityCG.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST  100
            #define SURF_DIST 0.001

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
                o.hitPos = v.vertex;

                return o;
            }
            
            /*****************************************************************
                                             Functions
            ******************************************************************/
            // 트랜스폼의 회전 행렬 추출
            float4x4 GetModelRotationMatrix()
            {
                float4x4 rotationMatrix;

                vector sx = vector(unity_ObjectToWorld._m00, unity_ObjectToWorld._m10, unity_ObjectToWorld._m20, 0);
                vector sy = vector(unity_ObjectToWorld._m01, unity_ObjectToWorld._m11, unity_ObjectToWorld._m21, 0);
                vector sz = vector(unity_ObjectToWorld._m02, unity_ObjectToWorld._m12, unity_ObjectToWorld._m22, 0);

                float scaleX = length(sx);
                float scaleY = length(sy);
                float scaleZ = length(sz);

                rotationMatrix[0] = float4(unity_ObjectToWorld._m00 / scaleX, unity_ObjectToWorld._m01 / scaleY, unity_ObjectToWorld._m02 / scaleZ, 0);
                rotationMatrix[1] = float4(unity_ObjectToWorld._m10 / scaleX, unity_ObjectToWorld._m11 / scaleY, unity_ObjectToWorld._m12 / scaleZ, 0);
                rotationMatrix[2] = float4(unity_ObjectToWorld._m20 / scaleX, unity_ObjectToWorld._m21 / scaleY, unity_ObjectToWorld._m22 / scaleZ, 0);
                rotationMatrix[3] = float4(0, 0, 0, 1);

                return rotationMatrix;
            }

            // 위치 벡터 회전
            float3 RotatePosObjectToWorld(float4x4 rotationMatrix, float3 pos)
            {
                return mul(rotationMatrix, pos).xyz;
            }

            float3 RotatePosWorldToObject(float4x4 rotationMatrix, float3 pos)
            {
                return mul(pos, rotationMatrix).xyz;
            }
            
            // 방향 벡터 회전
            float3 RotateDirObjectToWorld(float4x4 rotationMatrix, float3 dir)
            {
                return mul((float3x3)rotationMatrix, dir);
            }

            float3 RotateDirWorldToObject(float4x4 rotationMatrix, float3 dir)
            {
                return mul(dir, (float3x3)rotationMatrix);
            }

            /*****************************************************************
                                  Signed Distance Functions
            ******************************************************************/
            float SdSphere(float3 p, float3 pos, float radius)
            {
                return length(p - pos) - radius;
            }

            float SdSphere2(float3 p, float3 pos, float radius, float3 scale)
            {
                p -= pos;
                p /= scale;
                p += pos;

                return length(p - pos) - radius;
            }

            float SdTorus(float3 p, float3 pos, float radius, float width)
            {
                p = p - pos;
                float r = radius;
                float w = width;
                float2 q = float2(length(p.xz) - r, p.y);
                return length(q) - w;
            }

            float SdBox(float3 p, float3 pos, float3 size)
            {
                float3 q = abs(p - pos) - size;
                return length(max(q, 0.0)) + min( max(q.x, max(q.y,q.z) ), 0.0);
            }
            
            /*****************************************************************
                                        Operator Functions
            ******************************************************************/
            float2x2 GetRotationMatrix2x2(float degree)
            {
                float radian = radians(degree);
                float s = sin(radian);
                float c = cos(radian);

                return float2x2(c, -s, s, c);
            }

            float3 RotateX(float3 p, float3 pos, float degree)
            {
                p -= pos;
                p.yz = mul(GetRotationMatrix2x2(degree), p.yz);
                p += pos;

                return p;
            }
            float3 RotateY(float3 p, float3 pos, float degree)
            {
                p -= pos;
                p.xz = mul(GetRotationMatrix2x2(degree), p.xz);
                p += pos;

                return p;
            }
            float3 RotateZ(float3 p, float3 pos, float degree)
            {
                p -= pos;
                p.xy = mul(GetRotationMatrix2x2(degree), p.xy);
                p += pos;

                return p;
            }

            float3 Scale(float3 p, float3 pos, float3 scale)
            {
                p -= pos;
                p /= scale;
                p += pos;
                return p;
            }

            // Polynomial smooth min (k = 0.1);
            float smin(float a, float b, float k)
            {
                float h = saturate(0.5 + 0.5 * (b - a) / k);
                return lerp(b, a, h) - k * h * (1.0 - h);
            }

            float smin(float a, float b)
            {
                return smin(a, b, 0.2);
            }

            float3 Displacement(float3 p, float dist, float intensity)
            {
                float3 disp = sin(p * dist) * intensity;
                return p + disp;
            }
            
            /*****************************************************************
                                   Ray Marching Functions
            ******************************************************************/
            // Sphere + Torus + Sphere*8
            float SunShape(float3 p)
            {
                float t = _Time.y;
                float3 centerPos = float3(-1.0, 0, 2.0);

                float torus = SdTorus(RotateX(p, centerPos, 90), centerPos, 0.5, 0.1);
                float s1 = SdSphere(p, centerPos, 0.3 + sin(t * 3.0) * 0.1);

                float d = smin(torus, s1);
                
                float3 s2_pos = centerPos; s2_pos.y += 0.9;

                for(int i = 0; i < 8; i++)
                {
                    float3 s2_p = RotateZ(p, centerPos, 45.0 * (float)i + t * 50.0);
                    float s2 = SdSphere2(s2_p, s2_pos, 0.1, float3(1.0, 2.0, 1.0));

                    d = smin(d, s2);
                }

                return d;
            }

            // Final SD Functions
            float GetDist(float3 p)
            {
                float t = _Time.y;
                float d = SunShape(p);
                
                float3 pos2 = float3(1.0, 0, 2.0);
                float scale = 0.7 + sin(t * 2.0) * 0.1;

                float3 p2 = p;
                p2 = RotateX(p2, pos2, t * 60.0);
                p2 = RotateZ(p2, pos2, t * 90.0);

                float box = SdBox(p2, pos2, scale);
                float sp = SdSphere(p, pos2, scale * 1.3);

                float d2 = max(box, -sp);

                d = smin(d, d2, 0.4);

                return d;
            }

            float3 GetNormal(float3 p)
            {
                float2 e = float2(0.01, 0);
                float3 n = GetDist(p) - float3(
                    GetDist(p - e.xyy),
                    GetDist(p - e.yxy),
                    GetDist(p - e.yyx)
                );
                return normalize(n);
            }

            float GetLight(float3 N, float3 L)
            {
                return saturate(dot(N, L));
            }

            float Raymarch(float3 ro, float3 rd)
            {
                float dO = 0; // 누적 전진 거리
                float dS;     // 이번 스텝에서 전진할 거리

                for(int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = ro + dO * rd;
                    dS = GetDist(p);
                    dO += dS;

                    if(dS < SURF_DIST || dO > MAX_DIST)
                        break;
                }

                return dO;
            }

            /*****************************************************************
                                       Fragment Function
            ******************************************************************/
            fixed4 frag (v2f i) : SV_Target
            {
                float4x4 rotMatrix = GetModelRotationMatrix();

                // Object Light Direction
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                L = RotateDirWorldToObject(rotMatrix, L);

                float2 uv = i.uv - 0.5;
                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - ro);

                float d = Raymarch(ro, rd);
                fixed4 col = 0;
                col.a = 1;

                if(d < MAX_DIST)
                {
                    float3 p = ro + rd * d;
                    float3 N = GetNormal(p);
                    col.rgb = GetLight(N, L);
                }
                else
                    discard;

                return col;
            }
            ENDCG
        }
    }
}
