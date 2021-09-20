// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Directional 2 Color Dissolve"
{
	Properties
	{
		[Header(Dissolve)][Space(6)]_Dissolve("Dissolve", Range( 0 , 1)) = 0.5
		_MinOffset("Min Offset", Float) = -1
		_MaxOffset("Max Offset", Float) = 1
		_DissolveDirection("Dissolve Direction", Vector) = (0,1,0,0)
		[Header(Options)][Space(6)]_Smoothness("Smoothness", Range( 0.01 , 1)) = 0.4
		_ThicknessA("Thickness A", Range( 0 , 0.5)) = 0.05
		_ThicknessB("Thickness B", Range( 0 , 0.5)) = 0.05
		_NoiseScale("Noise Scale", Range( 0 , 20)) = 10
		[Header(Colors)][Space(6)]_MainTexture("Main Texture", 2D) = "white" {}
		[HDR]_ColorA("Color A", Color) = (0.7682998,3.073199,2.368924,0)
		[HDR]_ColorB("Color B", Color) = (4,3.858824,0.7686275,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _NoiseScale;
		uniform float _ThicknessA;
		uniform float _ThicknessB;
		uniform float _Dissolve;
		uniform float _Smoothness;
		uniform float3 _DissolveDirection;
		uniform float _MinOffset;
		uniform float _MaxOffset;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _ColorA;
		uniform float4 _ColorB;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float simplePerlin2D29 = snoise( i.uv_texcoord*_NoiseScale );
			simplePerlin2D29 = simplePerlin2D29*0.5 + 0.5;
			float Noise47 = simplePerlin2D29;
			float Thickness_A_Plus_B72 = ( _ThicknessA + _ThicknessB );
			float temp_output_63_0 = ( ( 1.0 + Thickness_A_Plus_B72 ) * _Dissolve );
			float SMin43 = temp_output_63_0;
			float SMax44 = ( (-_Smoothness + (temp_output_63_0 - 0.0) * (1.0 - -_Smoothness) / (1.0 - 0.0)) + _Smoothness );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult107 = normalize( _DissolveDirection );
			float dotResult109 = dot( ase_vertex3Pos , normalizeResult107 );
			float Gradient2 = (0.0 + (dotResult109 - _MinOffset) * (1.0 - 0.0) / (_MaxOffset - _MinOffset));
			float smoothstepResult31 = smoothstep( SMin43 , SMax44 , Gradient2);
			float temp_output_27_0 = step( Noise47 , smoothstepResult31 );
			float Area_Main90 = temp_output_27_0;
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 Color_Albedo100 = ( Area_Main90 * tex2D( _MainTexture, uv_MainTexture ) );
			o.Albedo = Color_Albedo100.rgb;
			float Thickness_A54 = _ThicknessA;
			float smoothstepResult38 = smoothstep( ( SMin43 - Thickness_A54 ) , ( SMax44 - Thickness_A54 ) , Gradient2);
			float temp_output_39_0 = step( Noise47 , smoothstepResult38 );
			float Area_A91 = ( temp_output_39_0 - temp_output_27_0 );
			float smoothstepResult74 = smoothstep( ( SMin43 - Thickness_A_Plus_B72 ) , ( SMax44 - Thickness_A_Plus_B72 ) , Gradient2);
			float temp_output_82_0 = step( Noise47 , smoothstepResult74 );
			float Area_B92 = ( temp_output_82_0 - temp_output_39_0 );
			float4 Color_Emission101 = ( ( Area_A91 * _ColorA ) + ( Area_B92 * _ColorB ) );
			o.Emission = Color_Emission101.rgb;
			float Opacity105 = temp_output_82_0;
			o.Alpha = Opacity105;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
211;54;1468;965;3598.892;722.0165;2.012519;True;False
Node;AmplifyShaderEditor.CommentaryNode;89;-3027.76,126.5652;Inherit;False;693.0833;265.7795;.;5;71;72;54;41;70;Thickness Values;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2976.676,276.3447;Inherit;False;Property;_ThicknessB;Thickness B;6;0;Create;True;0;0;0;False;0;False;0.05;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-2977.76,176.5652;Inherit;False;Property;_ThicknessA;Thickness A;5;0;Create;True;0;0;0;False;0;False;0.05;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-2699.676,257.3447;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;88;-3036.053,-475.9767;Inherit;False;1084.495;530.75;.;10;37;34;44;43;36;33;63;61;28;57;Calculate SMin, SMax;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-2586.676,252.3447;Inherit;False;Thickness_A_Plus_B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-2986.053,-344.6226;Inherit;False;72;Thickness_A_Plus_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2900.773,-424.3446;Inherit;False;Constant;_Float6;Float 6;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2938.839,-58.8914;Inherit;False;Property;_Smoothness;Smoothness;4;1;[Header];Create;True;1;Options;0;0;False;1;Space(6);False;0.4;0.4;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-2763.35,-365.3763;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;86;-3035.66,-1056.8;Inherit;False;1085.006;511.9027;.;8;110;108;2;113;112;109;107;106;Make Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2935.603,-239.3666;Inherit;False;Property;_Dissolve;Dissolve;0;1;[Header];Create;True;1;Dissolve;0;0;False;1;Space(6);False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-2631.748,-258.9764;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;37;-2623.093,-110.1503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;106;-3013.371,-858.7871;Inherit;False;Property;_DissolveDirection;Dissolve Direction;3;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;36;-2481.272,-180.52;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;108;-2860.771,-1002.986;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;107;-2829.371,-853.7871;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-2612.111,-727.0927;Inherit;False;Property;_MinOffset;Min Offset;1;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;109;-2661.371,-936.787;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-2615.111,-655.0927;Inherit;False;Property;_MaxOffset;Max Offset;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2297.282,-80.22669;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;87;-3033.384,486.3759;Inherit;False;767.7477;309;.;4;30;29;47;73;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;110;-2411.371,-791.787;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;98;-1904.468,-1049.99;Inherit;False;1449.33;1110.381;.;30;53;38;49;50;40;51;52;39;42;55;31;26;45;46;48;27;83;74;75;76;77;78;79;80;82;81;90;91;92;105;Dissolve Areas;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-2177.09,-253.5955;Inherit;False;SMin;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2983.384,658.0266;Inherit;False;Property;_NoiseScale;Noise Scale;7;0;Create;True;0;0;0;False;0;False;10;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-2175.558,-84.02796;Inherit;False;SMax;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-2584.175,177.1987;Inherit;False;Thickness_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;30;-2900.661,539.3759;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;81;-1854.468,-55.6091;Inherit;False;72;Thickness_A_Plus_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-1833.169,-399.9308;Inherit;False;54;Thickness_A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-1828.506,-550.077;Inherit;False;43;SMin;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-1823.805,-210.9553;Inherit;False;43;SMin;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-1823.805,-137.9551;Inherit;False;44;SMax;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;29;-2715.661,536.3759;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1828.506,-477.077;Inherit;False;44;SMax;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;2;-2148.699,-796.6962;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-1632.007,-848.1478;Inherit;False;43;SMin;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1631.126,-920.5597;Inherit;False;2;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-1608.805,-277.9551;Inherit;False;2;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-1585.953,-542.0243;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-1581.252,-202.9026;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-1583.478,-86.90247;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-1613.506,-617.077;Inherit;False;2;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-2489.635,536.9152;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;-1588.179,-426.0242;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-1632.007,-772.7479;Inherit;False;44;SMax;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;31;-1415.159,-916.3947;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-1347.506,-630.077;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-1342.805,-290.9551;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;38;-1407.203,-556.4539;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-1359.038,-999.9899;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;74;-1402.503,-217.3321;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;39;-1137.071,-607.9316;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;82;-1132.37,-268.8098;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;27;-1151.809,-965.5722;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;53;-888.2399,-770.7542;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;-887.7125,-359.6436;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-685.7563,-775.213;Inherit;False;Area_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;99;-2181.949,159.0821;Inherit;False;966.2074;840.9506;.;12;101;100;69;97;96;85;94;68;93;95;84;67;Apply Colors;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-679.1382,-363.996;Inherit;False;Area_B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2013.98,479.0965;Inherit;False;91;Area_A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;-2012.167,746.8116;Inherit;False;92;Area_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;84;-2051.057,820.7536;Inherit;False;Property;_ColorB;Color B;10;1;[HDR];Create;True;0;0;0;False;0;False;4,3.858824,0.7686275,0;0.02271891,0,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;67;-2051.872,551.9167;Inherit;False;Property;_ColorA;Color A;9;1;[HDR];Create;True;0;0;0;False;0;False;0.7682998,3.073199,2.368924,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-898.825,-970.4484;Inherit;False;Area_Main;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;96;-2131.948,283.3225;Inherit;True;Property;_MainTexture;Main Texture;8;1;[Header];Create;True;1;Colors;0;0;False;1;Space(6);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1843.736,483.3716;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1842.62,750.9089;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-2013.884,209.0821;Inherit;False;90;Area_Main;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1843.559,213.8319;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-1598.629,627.9991;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1405.998,626.4787;Inherit;False;Color_Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-1597.984,279.0186;Inherit;False;Color_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-879.0135,-124.0634;Inherit;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;114;-1087.198,206.2058;Inherit;False;517.1199;524.9035;.;4;103;102;104;0;Master Node;0.4198113,1,0.9439446,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-1012.741,469.0307;Inherit;False;105;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-1037.198,324.9445;Inherit;False;101;Color_Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-1028.307,256.2059;Inherit;False;100;Color_Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-825.0778,260.1094;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Rito/Directional 2 Color Dissolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;71;0;41;0
WireConnection;71;1;70;0
WireConnection;72;0;71;0
WireConnection;61;0;62;0
WireConnection;61;1;57;0
WireConnection;63;0;61;0
WireConnection;63;1;28;0
WireConnection;37;0;33;0
WireConnection;36;0;63;0
WireConnection;36;3;37;0
WireConnection;107;0;106;0
WireConnection;109;0;108;0
WireConnection;109;1;107;0
WireConnection;34;0;36;0
WireConnection;34;1;33;0
WireConnection;110;0;109;0
WireConnection;110;1;112;0
WireConnection;110;2;113;0
WireConnection;43;0;63;0
WireConnection;44;0;34;0
WireConnection;54;0;41;0
WireConnection;29;0;30;0
WireConnection;29;1;73;0
WireConnection;2;0;110;0
WireConnection;40;0;49;0
WireConnection;40;1;55;0
WireConnection;77;0;75;0
WireConnection;77;1;81;0
WireConnection;78;0;76;0
WireConnection;78;1;81;0
WireConnection;47;0;29;0
WireConnection;42;0;50;0
WireConnection;42;1;55;0
WireConnection;31;0;26;0
WireConnection;31;1;45;0
WireConnection;31;2;46;0
WireConnection;38;0;51;0
WireConnection;38;1;40;0
WireConnection;38;2;42;0
WireConnection;74;0;79;0
WireConnection;74;1;77;0
WireConnection;74;2;78;0
WireConnection;39;0;52;0
WireConnection;39;1;38;0
WireConnection;82;0;80;0
WireConnection;82;1;74;0
WireConnection;27;0;48;0
WireConnection;27;1;31;0
WireConnection;53;0;39;0
WireConnection;53;1;27;0
WireConnection;83;0;82;0
WireConnection;83;1;39;0
WireConnection;91;0;53;0
WireConnection;92;0;83;0
WireConnection;90;0;27;0
WireConnection;68;0;93;0
WireConnection;68;1;67;0
WireConnection;85;0;95;0
WireConnection;85;1;84;0
WireConnection;97;0;94;0
WireConnection;97;1;96;0
WireConnection;69;0;68;0
WireConnection;69;1;85;0
WireConnection;101;0;69;0
WireConnection;100;0;97;0
WireConnection;105;0;82;0
WireConnection;0;0;102;0
WireConnection;0;2;103;0
WireConnection;0;9;104;0
ASEEND*/
//CHKSM=9349C98153B1CFDAAA7326F0DAAACF5E00903D46