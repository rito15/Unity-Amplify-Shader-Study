Shader "Rito/Water"
{
    Properties
    {
        [Header(Textures)]
        _BumpMap("Normal Map", 2D) = "bump" {}
        _Cube("Cube", Cube) = ""{}

        [Space, Header(Basic Options)]
        _Tint("Tint Color", Color) = (0, 0, 0.01, 1)
        _Alpha("Alpha", Range(0, 1)) = 1
        _CubeIntensity("CubeMap Intensity", Range(0, 2)) = 1
        _CubeBrightness("CubeMap Brightness", Range(-2, 2)) = 0
        
        [Space, Header(Penetration Options)]
        _Penetration("Penetration", Range(0, 1)) = 0.2 // 투과율
        _PenetrationThreshold("Penetration Threshold", Range(0, 50)) = 5

        [Space, Header(Normal Map Options)]
        _Tiling("Normal Tiling", Range(1, 10)) = 2
        _Strength("Normal Strength", Range(0, 2)) = 1

        [Space, Header(Fresnel Options)]
        _FresnelPower("Fresnel Power", Range(0, 10)) = 3
        _FresnelIntensity("Fresnel Intensity", Range(0, 5)) = 1

        [Space, Header(Lighting Options)]
        _SpColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpPower("Specular Power", Range(10, 500)) = 300
        _SpIntensity("Specular Intensity", Range(0, 10)) = 2

        [Space, Header(Flow Options)]
        _FlowDirX("Flow Direction X", Range(-1, 1)) = -1
        _FlowDirY("Flow Direction Y", Range(-1, 1)) = 1
        _FlowSpeed("Flow Speed", Range(0, 10)) = 1

        [Space, Header(Wave Options)]
        _WaveCount("Wave Count", Int) = 8
        _WaveHeight("WaveHeight", Range(0, 10)) = 0.1
        _WaveDirX("Wave Direction X", Range(-1, 1)) = -1
        _WaveDirY("Wave Direction Y", Range(-1, 1)) = 1
        _WaveSpeed("Wave Speed", Range(0, 10)) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        CGPROGRAM
        #pragma surface surf WaterSpecular alpha:fade vertex:vert
        #pragma target 3.0

        sampler2D _BumpMap;
        samplerCUBE _Cube;

        struct Input
        {
            float2 uv_BumpMap;
            float3 worldRefl;
            float3 viewDir;
            float3 Normal;
            INTERNAL_DATA
        };

        float _Alpha, _Penetration, _PenetrationThreshold;
        float _CubeIntensity, _CubeBrightness;
        float _Tiling, _Strength;
        float _FresnelPower, _FresnelIntensity;
        float _FlowDirX, _FlowDirY, _FlowSpeed;
        float4 _Tint, _SpColor;
        float _SpPower, _SpIntensity, _DiffIntensity;
        float _WaveHeight, _WaveDirX, _WaveDirY, _WaveSpeed;
        int _WaveCount;

        // Wave
        void vert(inout appdata_full v)
        {
            float t = _Time.y * _WaveSpeed;
            float2 waveDir = normalize(float2(_WaveDirX, _WaveDirY));

            float wave;
            wave  = sin(abs(v.texcoord.x * waveDir.x) * _WaveCount + t) * _WaveHeight;
            wave += sin(abs(v.texcoord.y * waveDir.y) * _WaveCount + t) * _WaveHeight;

            v.vertex.y = wave / 2.;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            float3 originNormal = o.Normal;
            float3 reflColor = texCUBE(_Cube, WorldReflectionVector(IN, originNormal));

            // Flow
            float2 flowDir = normalize(float2(_FlowDirX, _FlowDirY));
            float2 flow = flowDir * _Time.x * _FlowSpeed;
            
            float3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _Tiling + flow));
            float3 normal2 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _Tiling * 0.5 - flow * 0.3)) * 0.5;
            
            o.Normal = (normal1 + normal2) * 0.5;

            // Fresnel
            float ndv = saturate(dot(o.Normal * _Strength, IN.viewDir));
            float fresnel = 1. - pow(ndv, _FresnelPower) * _FresnelIntensity;
            
            // Penetration
            float penet = pow(saturate(dot(originNormal, IN.viewDir)), _PenetrationThreshold) * _Penetration;

            // FInal
            o.Emission = (_Tint * 0.5) + (reflColor * _CubeIntensity * fresnel) + _CubeBrightness;
            o.Alpha = _Alpha - penet;
        }

        float4 LightingWaterSpecular(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        {
            float3 H = normalize(lightDir + viewDir); // Binn Phong
            float spec = saturate(dot(H, s.Normal));
            spec = pow(spec, _SpPower);

            float4 col;
            col.rgb = spec * _SpColor.rgb * _SpIntensity * _LightColor0;
            col.a = s.Alpha + spec;

            return col;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/VertexLit"
}