
// 단순 마스크

// 렌더링 안함
// Ref 1 타겟이 뒤에 있는 경우 보여줌

Shader "Custom/StencilMask01"
{
    Properties {}
    SubShader
    {
        Tags 
        {
            "RenderType"="Opaque"
            "Queue"="Geometry-1" // 반드시 대상보다 먼저 그려져야 하므로
        }

        Stencil
        {
            Ref 1
            Comp Never   // 항상 렌더링 하지 않음
            Fail Replace // 렌더링 실패한 부분의 스텐실 버퍼에 1을 채움
        }

        CGPROGRAM
        #pragma surface surf nolight noforwardadd nolightmap noambient novertexlights noshadow

        struct Input { float4 color:COLOR; };

        void surf (Input IN, inout SurfaceOutput o){}
        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0, 0, 0, 0);
        }
        ENDCG
    }
    FallBack ""
}
