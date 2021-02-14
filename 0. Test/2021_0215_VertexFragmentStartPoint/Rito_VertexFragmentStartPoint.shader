Shader "Rito/VertexFragmentStartPoint"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION; // Object Position
                float3 normal : NORMAL;   // Object Normal
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION; // Clip Position
                float2 uv : TEXCOORD0;
                float3 wPos : TEXCOORD1;
                float3 wNormal : TEXCOORD2;

                // Tangent -> World 회전 변환을 위한 3x3 매트릭스
                float3 tspace0 : TEXCOORD3; // tangent.x, bitangent.x, normal.x
                float3 tspace1 : TEXCOORD4; // tangent.y, bitangent.y, normal.y
                float3 tspace2 : TEXCOORD5; // tangent.z, bitangent.z, normal.z

            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);

                // Calculate Bitangent
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 wBitangent = cross(wNormal, wTangent) * tangentSign;

                // Tangent To World 행렬
                o.tspace0 = float3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = float3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = float3(wTangent.z, wBitangent.z, wNormal.z);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.wNormal = wNormal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = 1.;
                fixed alpha = 1.;

                // World Vectors
                float3 wPos    = i.wPos;
                float3 wNormal = normalize(i.wNormal);
                float3 wView   = normalize(UnityWorldSpaceViewDir(wPos));
                float3 wLight  = UnityWorldSpaceLightDir(wPos);
                float3 wHalf   = normalize(wLight + wView);
                float3 wLReflect = reflect(-wLight, wNormal);

                // Calculate World Normal From Normal Map
                float3 tNormal0 = UnpackNormal(tex2D(_BumpMap, i.uv));
                float3 wNormal0;
                wNormal0.x = dot(i.tspace0, tNormal0);
                wNormal0.y = dot(i.tspace1, tNormal0);
                wNormal0.z = dot(i.tspace2, tNormal0);
                
                //wNormal = wNormal0;

                // Lighting Term
                float ndl = dot(wNormal, wLight);
                float ndv = dot(wNormal, wView);
                float ndh = dot(wNormal, wHalf);
                float rdv = dot(wLReflect, wView);

                float diffuse = saturate(ndl);
                float specPhong = pow(saturate(rdv), 30.) * .4;
                float specBlinnPhong = pow(saturate(ndh), 80.) * .4;
                float fresnel = pow(1. - saturate(ndv), 3.) * .5;

                // Final Color

                //col = tex2D(_MainTex, i.uv);
                float light = saturate(diffuse + specBlinnPhong);
                col *= light * _LightColor0;
                col += fresnel;

                return fixed4(col, alpha);
            }
            ENDCG
        }
    }
}
