
Shader "Custom/Alpha2Pass"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Alpha("Alpha", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        /****************************************************************
        *                            Pass 1
        *****************************************************************
        * - Zwrite on
        * - Rendering off (ColorMask 0)
        * - 패스 1의 역할 : 알파 소팅 문제가 발생하지 않도록
        *                   Z버퍼에 기록해주기
        *****************************************************************/
        ZWrite On
        ColorMask 0

        CGPROGRAM
        #pragma surface surf nolight noambient noforwardadd nolightmap novertexlights noshadow

        struct Input
        {
            float4 color:COLOR; // Input을 비워두지 않기 위해 작성
        };

        // 서피스 함수 : 아무 것도 하지 않음
        void surf(Input IN, inout SurfaceOutput o){}

        // 라이팅 함수 : 아무 것도 하지 않음
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0,0,0,0);
        }
        ENDCG

        /****************************************************************
        *                            Pass 2
        *****************************************************************
        * - Zwrite off
        * - 패스 2 : 메인 패스. 여기서 모든걸 계산. 빛의 영향도 받음
        *****************************************************************/
        ZWrite Off

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade
        
        sampler2D _MainTex;
        
        struct Input
        {
            float2 uv_MainTex;
        };

        float _Alpha;

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = _Alpha;
        }
        ENDCG
    }
    Fallback "Transparent" // 그림자 생성 X
}
