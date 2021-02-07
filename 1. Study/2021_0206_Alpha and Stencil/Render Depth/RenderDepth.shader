Shader "Render Depth"
{
    Properties
    {
        _Multiplier("Multiplier", Float) = 50
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass 
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float depth : TEXCOORD0;
            };

            float _Multiplier;

            v2f vert(appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.depth = length(mul(UNITY_MATRIX_MV, v.vertex)) * _ProjectionParams.w;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return fixed4(i.depth, i.depth, i.depth, 1) * _Multiplier;
            }
            ENDCG
        }
    }
}