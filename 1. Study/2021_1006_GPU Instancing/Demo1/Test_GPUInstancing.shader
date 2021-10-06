Shader "Rito/Test_GPUInstancing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma target 4.5

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;

        #if SHADER_TARGET >= 45
            StructuredBuffer<float4> positionBuffer;
        #endif

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 diffuse : TEXCOORD2;
                SHADOW_COORDS(4)
            };

            v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
            {
            #if SHADER_TARGET >= 45
                float4 data = positionBuffer[instanceID];
            #else
                float4 data = 0;
            #endif

                float3 localPosition = v.vertex.xyz * data.w;    // 스케일 적용
                float3 worldPosition = data.xyz + localPosition; // 위치 적용
                float3 worldNormal   = v.normal;

                float3 NdL = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));
                float3 diffuse = (NdL * _LightColor0.rgb);

                v2f o;
                o.pos     = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
                o.uv      = v.texcoord;
                o.diffuse = diffuse;

                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed  shadow   = SHADOW_ATTENUATION(i);
                fixed4 albedo   = tex2D(_MainTex, i.uv);
                float3 lighting = i.diffuse * shadow;
                fixed4 output   = fixed4(albedo.rgb * lighting, albedo.a);

                UNITY_APPLY_FOG(i.fogCoord, output);
                return output;
            }

            ENDCG
        }
    }
}
