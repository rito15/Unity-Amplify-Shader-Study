// 설명 : 그랩그랩
Shader "Custom_Unlit/GrabTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }
        LOD 100

        GrabPass {"_GrabTex"} // 그랩

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
                float4 screenPos : TEXCOORD3; // 그랩
                //UNITY_FOG_COORDS(1) // 얘는 포그 적용하면 안됨
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _GrabTex; // 그랩
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);

                o.screenPos = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex)); // 그랩
                // 또는
                //o.screenPos = ComputeScreenPos(o.vertex); // 그랩

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = 1;
                float2 screenUV = i.screenPos.xy / i.screenPos.w;

                col = tex2D(_GrabTex, screenUV);
                // 또는
                //col = tex2Dproj(_GrabTex, i.screenPos);
                
                //col = tex2D(_MainTex, i.uv); 

                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
