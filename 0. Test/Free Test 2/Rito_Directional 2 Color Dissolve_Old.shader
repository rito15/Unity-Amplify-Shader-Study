// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Directional 2 Color Dissolve_Old"
{
	Properties
	{
		[Header(Dissolve)][Space(8)]_Dissolve("Dissolve", Range( 0 , 1)) = 0
		_MinOffset("Min Offset", Float) = -0.5
		_MaxOffset("Max Offset", Float) = 0.5
		_DissolveDirection("Dissolve Direction", Vector) = (0,1,0,0)
		[Header(Options)][Space(8)]_Smoothness("Smoothness", Range( 0.01 , 1)) = 0.2
		_NoiseScale("Noise Scale", Range( 1 , 20)) = 5
		_ThicknessA("Thickness A", Range( 0 , 0.5)) = 0.05
		_ThicknessB("Thickness B", Range( 0 , 0.5)) = 0.05
		[Header(Colors)][Space(8)]_MainTex("Main Texture", 2D) = "white" {}
		[HDR]_ColorA("Color A", Color) = (0.7215686,1.192157,5.992157,0)
		[HDR]_ColorB("Color B", Color) = (0.972549,5.992157,0.9411765,0)
		[Normal][Space(8)]_BumpMap("Normal Map", 2D) = "bump" {}
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

		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float _NoiseScale;
		uniform float _Dissolve;
		uniform float _ThicknessA;
		uniform float _ThicknessB;
		uniform float _Smoothness;
		uniform float3 _DissolveDirection;
		uniform float _MinOffset;
		uniform float _MaxOffset;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
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
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			o.Normal = UnpackNormal( tex2D( _BumpMap, uv_BumpMap ) );
			float simplePerlin2D5 = snoise( i.uv_texcoord*_NoiseScale );
			simplePerlin2D5 = simplePerlin2D5*0.5 + 0.5;
			float Noise_Pattern28 = simplePerlin2D5;
			float Thick_A_Plus_B67 = ( _ThicknessA + _ThicknessB );
			float temp_output_9_0 = ( _Dissolve * ( 1.0 + Thick_A_Plus_B67 + _Smoothness ) );
			float SMin21 = ( temp_output_9_0 - _Smoothness );
			float SMax20 = temp_output_9_0;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform99 = mul(unity_WorldToObject,float4( _DissolveDirection , 0.0 ));
			float3 normalizeResult100 = normalize( (transform99).xyz );
			float dotResult92 = dot( ase_vertex3Pos , normalizeResult100 );
			float2 _Vector0 = float2(0,1);
			float Progress_Gradient27 = (_Vector0.x + (dotResult92 - _MinOffset) * (_Vector0.y - _Vector0.x) / (_MaxOffset - _MinOffset));
			float smoothstepResult12 = smoothstep( SMin21 , SMax20 , Progress_Gradient27);
			float temp_output_14_0 = step( Noise_Pattern28 , smoothstepResult12 );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 Color_Main82 = ( temp_output_14_0 * tex2D( _MainTex, uv_MainTex ) );
			o.Albedo = Color_Main82.rgb;
			float Thick_A66 = _ThicknessA;
			float smoothstepResult15 = smoothstep( ( SMin21 - Thick_A66 ) , ( SMax20 - Thick_A66 ) , Progress_Gradient27);
			float temp_output_18_0 = step( Noise_Pattern28 , smoothstepResult15 );
			float4 Color_A83 = ( saturate( ( temp_output_18_0 - temp_output_14_0 ) ) * _ColorA );
			float smoothstepResult43 = smoothstep( ( SMin21 - Thick_A_Plus_B67 ) , ( SMax20 - Thick_A_Plus_B67 ) , Progress_Gradient27);
			float temp_output_37_0 = step( Noise_Pattern28 , smoothstepResult43 );
			float4 Color_B84 = ( saturate( ( temp_output_37_0 - temp_output_18_0 ) ) * _ColorB );
			o.Emission = ( Color_A83 + Color_B84 ).rgb;
			float Alpha81 = temp_output_37_0;
			o.Alpha = Alpha81;
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
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
465;474;1468;965;1217.584;1005.743;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;65;-1835.345,698.2627;Inherit;False;912.5243;238.189;.;5;66;67;62;50;51;Thickness Properties;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1783.759,748.2627;Inherit;False;Property;_ThicknessA;Thickness A;6;0;Create;True;0;0;0;False;0;False;0.05;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1785.345,828.0419;Inherit;False;Property;_ThicknessB;Thickness B;7;0;Create;True;0;0;0;False;0;False;0.05;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-1506.685,809.3075;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;108;-1855.659,-648.4311;Inherit;False;1327.766;443.4987;.;11;27;100;101;99;93;102;104;105;106;92;98;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-1375.226,821.2104;Inherit;False;Thick_A_Plus_B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1844.824,230.5307;Inherit;False;925.8057;382.3549;.;9;3;70;8;11;20;21;10;9;2;Smooth Min, Max;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;93;-1830.394,-438.2722;Inherit;False;Property;_DissolveDirection;Dissolve Direction;3;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;3;-1797.607,501.3703;Inherit;False;Property;_Smoothness;Smoothness;4;1;[Header];Create;True;1;Options;0;0;False;1;Space(8);False;0.2;0.5;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;99;-1647.071,-431.315;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-1660.543,362.4052;Inherit;False;Constant;_1;1;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1726.697,430.0732;Inherit;False;67;Thick_A_Plus_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-1514.193,367.8971;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;101;-1469.531,-425.7754;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1797.323,283.0303;Inherit;False;Property;_Dissolve;Dissolve;0;1;[Header];Create;True;1;Dissolve;0;0;False;1;Space(8);False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1391.779,287.0392;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;98;-1465.835,-587.8664;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;100;-1287.77,-428.6377;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;104;-1096.945,-339.1893;Inherit;False;Constant;_Vector0;Vector 0;9;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-1267.295,371.2497;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;92;-1095.949,-586.1257;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1099.707,-479.7234;Inherit;False;Property;_MinOffset;Min Offset;1;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;33;-1852.436,-133.3032;Inherit;False;926.6011;294.1611;.;4;5;1;4;28;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1098.405,-410.8045;Inherit;False;Property;_MaxOffset;Max Offset;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1819.449,47.85785;Inherit;False;Property;_NoiseScale;Noise Scale;5;0;Create;True;0;0;0;False;0;False;5;5;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-1374.8,748.0002;Inherit;False;Thick_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-1131.525,367.8073;Inherit;False;SMin;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;102;-917.4028,-497.1961;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-1802.436,-83.30335;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;46;-861.0729,751.7625;Inherit;False;905.105;396.0794;.;9;37;39;41;43;44;45;63;64;68;Area - B;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1128.648,284.3636;Inherit;False;SMax;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;36;-859.5547,294.6898;Inherit;False;905.1049;396.0795;.;9;18;25;24;15;30;32;60;61;69;Area - A;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-796.6982,459.3859;Inherit;False;21;SMin;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-797.638,595.5745;Inherit;False;66;Thick_A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-797.6526,526.9161;Inherit;False;20;SMax;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;35;-716.6215,-131.888;Inherit;False;742.9955;375.1706;.;6;12;23;29;22;31;14;Area - Main;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-829.9377,1047.784;Inherit;False;67;Thick_A_Plus_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-745.2067,-498.1255;Inherit;False;Progress_Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;5;-1506.279,-40.70215;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-797.9741,980.3997;Inherit;False;20;SMax;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-798.2165,912.8701;Inherit;False;21;SMin;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-814.3321,840.1998;Inherit;False;27;Progress_Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;-607.0781,989.2867;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-609.2473,448.3773;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-649.764,118.6986;Inherit;False;20;SMax;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-666.6215,-15.06969;Inherit;False;27;Progress_Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-1325.335,-41.58547;Inherit;False;Noise_Pattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-608.2853,533.46;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-813.1437,391.171;Inherit;False;27;Progress_Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-607.8593,902.0109;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-649.764,52.51902;Inherit;False;21;SMin;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;43;-438.0622,877.4969;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-428.6008,-81.88794;Inherit;False;28;Noise_Pattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;15;-436.5441,420.4242;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;12;-465.1398,-10.71735;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-403.8616,344.6898;Inherit;False;28;Noise_Pattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-405.3797,801.7625;Inherit;False;28;Noise_Pattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;18;-189.4498,368.2221;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;14;-208.6267,-55.17526;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;37;-190.9679,825.2949;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;47;101.4776,596.0284;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;34;116.0866,253.6407;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;242.7046,255.6407;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;55;171.3644,347.5687;Inherit;False;Property;_ColorA;Color A;9;1;[HDR];Create;True;0;0;0;False;0;False;0.7215686,1.192157,5.992157,0;0,0.08572578,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;57;162.9605,686.5568;Inherit;False;Property;_ColorB;Color B;10;1;[HDR];Create;True;0;0;0;False;0;False;0.972549,5.992157,0.9411765,0;0.007393003,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;49;226.3565,596.0281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;381.0701,292.3693;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;80;74.82973,4.573254;Inherit;True;Property;_MainTex;Main Texture;8;1;[Header];Create;False;1;Colors;0;0;False;1;Space(8);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;374.9814,610.5858;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;496.8294,605.4206;Inherit;True;Color_B;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;112;-479.9447,-685.8953;Inherit;False;911.2603;487.5257;.;7;89;109;85;59;87;86;0;Master Node;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;362.0444,-52.01281;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;498.8641,289.8839;Inherit;True;Color_A;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-147.8445,-587.1501;Inherit;False;83;Color_A;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-147.783,-511.3818;Inherit;False;84;Color_B;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;480.6761,897.7357;Inherit;True;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;494.5657,-58.40276;Inherit;True;Color_Main;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;27.47321,-563.062;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;29.07522,-425.037;Inherit;False;81;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;20.9554,-641.4365;Inherit;False;82;Color_Main;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;109;-457.2465,-616.3954;Inherit;True;Property;_BumpMap;Normal Map;11;1;[Normal];Create;False;0;0;0;False;1;Space(8);False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;210.1157,-635.5693;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Rito/Directional 2 Color Dissolve_Old;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;62;0;50;0
WireConnection;62;1;51;0
WireConnection;67;0;62;0
WireConnection;99;0;93;0
WireConnection;8;0;11;0
WireConnection;8;1;70;0
WireConnection;8;2;3;0
WireConnection;101;0;99;0
WireConnection;9;0;2;0
WireConnection;9;1;8;0
WireConnection;100;0;101;0
WireConnection;10;0;9;0
WireConnection;10;1;3;0
WireConnection;92;0;98;0
WireConnection;92;1;100;0
WireConnection;66;0;50;0
WireConnection;21;0;10;0
WireConnection;102;0;92;0
WireConnection;102;1;105;0
WireConnection;102;2;106;0
WireConnection;102;3;104;1
WireConnection;102;4;104;2
WireConnection;20;0;9;0
WireConnection;27;0;102;0
WireConnection;5;0;1;0
WireConnection;5;1;4;0
WireConnection;64;0;39;0
WireConnection;64;1;68;0
WireConnection;60;0;24;0
WireConnection;60;1;69;0
WireConnection;28;0;5;0
WireConnection;61;0;25;0
WireConnection;61;1;69;0
WireConnection;63;0;41;0
WireConnection;63;1;68;0
WireConnection;43;0;44;0
WireConnection;43;1;63;0
WireConnection;43;2;64;0
WireConnection;15;0;30;0
WireConnection;15;1;60;0
WireConnection;15;2;61;0
WireConnection;12;0;29;0
WireConnection;12;1;23;0
WireConnection;12;2;22;0
WireConnection;18;0;32;0
WireConnection;18;1;15;0
WireConnection;14;0;31;0
WireConnection;14;1;12;0
WireConnection;37;0;45;0
WireConnection;37;1;43;0
WireConnection;47;0;37;0
WireConnection;47;1;18;0
WireConnection;34;0;18;0
WireConnection;34;1;14;0
WireConnection;48;0;34;0
WireConnection;49;0;47;0
WireConnection;56;0;48;0
WireConnection;56;1;55;0
WireConnection;58;0;49;0
WireConnection;58;1;57;0
WireConnection;84;0;58;0
WireConnection;54;0;14;0
WireConnection;54;1;80;0
WireConnection;83;0;56;0
WireConnection;81;0;37;0
WireConnection;82;0;54;0
WireConnection;59;0;87;0
WireConnection;59;1;86;0
WireConnection;0;0;85;0
WireConnection;0;1;109;0
WireConnection;0;2;59;0
WireConnection;0;9;89;0
ASEEND*/
//CHKSM=C1ACA7517475DB1E52420C94B6ECED741D20E95A