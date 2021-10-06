Shader "Custom/BasicVertFragShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType"="Opaque" "Queue"="Geometry" "LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) // unityShadowCoord4 _ShadowCoord : TEXCOORD1
                fixed3 diffuse : COLOR0;
                fixed3 ambient : COLOR1;
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                
                // Lambert
                half3 N = UnityObjectToWorldNormal(v.normal);
                half3 L = _WorldSpaceLightPos0;
                half NdL = saturate(dot(N, L));

                // Outputs
                o.pos     = UnityObjectToClipPos(v.vertex);
                o.uv      = v.uv;
                o.diffuse = NdL * _LightColor0;
                o.ambient = ShadeSH9(half4(N, 1));
                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                col.rgb *= i.diffuse;
                col.rgb *= SHADOW_ATTENUATION(i);
                col.rgb += i.ambient;

                return col;
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode"="ShadowCaster" }

            CGPROGRAM

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest
            //#pragma fragmentoption ARB_precision_hint_nicest

            #include "UnityCG.cginc"
            #include "UnityStandardShadow.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
        //UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
