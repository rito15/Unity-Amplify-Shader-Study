// 설명 : 
Shader "Custom/ShaderOptionsExample"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

        [Space(5)]
        [Header(___________________________________________________________)]
        [Header(Attributes)]

        [Toggle] _MyToggle ("My Toggle", Float) = 1.0
        [IntRange] _IntRange ("Int Range", Range(0, 100)) = 50
        [PowerSlider(3.0)] _Pow ("Power", Range(0.01, 1)) = 0.01

        [Space(5)]
        [Header(___________________________________________________________)]
        [Header(Enums)]

        [Enum(UnityEngine.Rendering.CullMode)] 	_CullMode("Cull Mode", Float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor("Src Factor", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)] _DstFactor("Dst Factor", Float) = 10

        [Space(5)]
        [Header(___________________________________________________________)]
        [Header(Variants)]

        [Toggle(BRIGHTER)] _Brighter("Brighter", Float) = 0
        [KeywordEnum(None, Red, Green, Blue)] _ColorOverwrite("Color Overwrite", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

        Cull   [_CullMode]
		ZTest  [_ZTest]
		ZWrite [_ZWrite]
		Blend  [_SrcFactor] [_DstFactor]

        CGPROGRAM

        #pragma shader_feature BRIGHTER
        #pragma shader_feature _COLOROVERWRITE_NONE _COLOROVERWRITE_RED _COLOROVERWRITE_GREEN _COLOROVERWRITE_BLUE

        #pragma surface surf Standard keepalpha //addshadow

        struct Input { fixed color:COLOR; };

        fixed4 _Color;
        float _MyToggle;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = _Color;

        #if _COLOROVERWRITE_RED
            c.rgb = fixed3(1., 0., 0.);
            
        #elif _COLOROVERWRITE_GREEN
            c.rgb = fixed3(0., 1., 0.);
            
        #elif _COLOROVERWRITE_BLUE
            c.rgb = fixed3(0., 0., 1.);

        #endif

        #ifdef BRIGHTER
            c.rgb *= 2.0;
        #else
        #endif

            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Transparent"
}
