Shader "Rito/Dirt"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {} 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            uniform float _Scale;
            StructuredBuffer<float3> _PositionBuffer;

            v2f vert (appdata_full v, uint instanceID : SV_InstanceID)
            {
                v.vertex *= _Scale;

                float3 instancePos = _PositionBuffer[instanceID];
                float3 worldPos = v.vertex + instancePos;

                v2f o;
                o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1));
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 L = _WorldSpaceLightPos0.xyz;
                fixed3 diff = dot(i.normal, L);
                fixed4 col = fixed4(diff, 1);

                return col;
            }
            ENDCG
        }
    }
}
