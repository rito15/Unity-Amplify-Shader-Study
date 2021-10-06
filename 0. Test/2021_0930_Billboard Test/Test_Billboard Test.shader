Shader "Unlit/Test_Billboard Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WorldPos("World Position", Vector) = (0, 0, 0, 0)
        _Scale("Scale", Range(0, 5)) = 1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _WorldPos;
            float _Scale;

            float4 Billboard(float4 vertex)
            {
                float3 camUpVec      =  normalize( UNITY_MATRIX_V._m10_m11_m12 );
			    float3 camForwardVec = -normalize( UNITY_MATRIX_V._m20_m21_m22 );
			    float3 camRightVec   =  normalize( UNITY_MATRIX_V._m00_m01_m02 );
			    float4x4 camRotMat   = float4x4( camRightVec, 0, camUpVec, 0, camForwardVec, 0, 0, 0, 0, 1 );
                
			    vertex = mul( vertex , unity_ObjectToWorld );
			    vertex = mul( vertex , camRotMat );
			    vertex = mul( vertex , unity_WorldToObject );

                return UnityObjectToClipPos(vertex);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = Billboard(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(0.5, 0.5, 0.5, 1);
                return col;
            }
            ENDCG
        }
    }
}
