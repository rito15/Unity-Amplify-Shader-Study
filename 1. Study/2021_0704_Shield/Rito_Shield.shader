// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Shield"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (0.6981132,4,3.866618,0)
		_DepthOffset("Depth Offset", Range( 0 , 1)) = 0.75
		_FresnelPower("Fresnel Power", Range( 1 , 10)) = 3
		[Header(Pattern)][SingleLineTexture][Space(6)]_PatternTexture("Pattern Texture", 2D) = "white" {}
		_PatternTiling("Pattern Tiling", Vector) = (1,1,0,0)
		_PatternScrolling("Pattern Scrolling", Vector) = (0,0,0,0)
		[Header(Opacity)][Space(6)]_PatternOpacity("Pattern Opacity", Range( 0 , 1)) = 0.2
		_EdgeOpacity("Edge Opacity", Range( 0 , 1)) = 0.5
		[Header(Distortion)][Space(6)]_DistortionStrength("Distortion Strength", Range( 0 , 1)) = 0.1
		_DistortionScale("Distortion Scale", Range( 0 , 12)) = 1
		_DistortionSpeed("Distortion Speed", Range( 0 , 1)) = 0.1
		_DistrortionDirectionXY("Distrortion Direction XY", Vector) = (0,1,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float4 _Color;
		uniform sampler2D _PatternTexture;
		uniform float2 _PatternTiling;
		uniform float2 _PatternScrolling;
		uniform float _DistortionSpeed;
		uniform float2 _DistrortionDirectionXY;
		uniform float _DistortionScale;
		uniform float _DistortionStrength;
		uniform float _PatternOpacity;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthOffset;
		uniform float _FresnelPower;
		uniform float _EdgeOpacity;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )


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
			float mulTime30 = _Time.y * 0.1;
			float2 uv_TexCoord26 = i.uv_texcoord * _PatternTiling + ( _PatternScrolling * mulTime30 );
			float mulTime47 = _Time.y * _DistortionSpeed;
			float2 normalizeResult68 = normalize( _DistrortionDirectionXY );
			float2 uv_TexCoord46 = i.uv_texcoord + ( mulTime47 * normalizeResult68 );
			float simplePerlin2D45 = snoise( uv_TexCoord46*_DistortionScale );
			simplePerlin2D45 = simplePerlin2D45*0.5 + 0.5;
			float UV_Distortion60 = ( simplePerlin2D45 * _DistortionStrength * 0.1 );
			float PatternOpacity34 = ( ( 1.0 - tex2D( _PatternTexture, ( uv_TexCoord26 + UV_Distortion60 ) ).r ) * _PatternOpacity );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth1 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float DepthValue19 = saturate( ( 1.0 - ( eyeDepth1 + -ase_screenPos.w + _DepthOffset ) ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV7 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode7 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV7, _FresnelPower ) );
			float EdgeOpacity39 = ( ( DepthValue19 + fresnelNode7 ) * _EdgeOpacity );
			float4 screenColor41 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_screenPosNorm + UV_Distortion60 ).xy);
			float4 SceneColor49 = screenColor41;
			o.Emission = ( ( _Color * ( PatternOpacity34 + EdgeOpacity39 ) ) + SceneColor49 ).rgb;
			o.Alpha = 1;
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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.worldNormal = IN.worldNormal;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
485;383;1713;973;3881.827;686.4015;3.017946;True;False
Node;AmplifyShaderEditor.CommentaryNode;61;-2758.902,741.572;Inherit;False;1341.495;355.8949;.;12;67;68;53;47;69;46;60;52;51;55;45;54;UV Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;67;-2692.346,894.241;Inherit;False;Property;_DistrortionDirectionXY;Distrortion Direction XY;11;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;53;-2737.316,815.4309;Inherit;False;Property;_DistortionSpeed;Distortion Speed;10;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;68;-2474.519,901.8176;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;47;-2479.786,818.8905;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2305.937,822.2626;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;20;-2560.53,-203.2352;Inherit;False;970.9845;413.7647;.;8;2;17;14;16;8;13;1;19;Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-2158.391,796.4718;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;54;-2307.806,923.3597;Inherit;False;Property;_DistortionScale;Distortion Scale;9;0;Create;True;0;0;0;False;0;False;1;0.1;0;12;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;2;-2505.355,-79.31555;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;63;-2125.728,266.0464;Inherit;False;1549.184;431.1014;.;12;25;23;24;34;59;62;28;27;29;26;30;22;Pattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.NegateNode;17;-2336.913,19.79174;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;45;-1952.599,791.572;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;1;-2510.53,-153.2353;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1887.671,1000.409;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2464.483,94.52957;Inherit;False;Property;_DepthOffset;Depth Offset;1;0;Create;True;0;0;0;False;0;False;0.75;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-2008.332,918.9981;Inherit;False;Property;_DistortionStrength;Distortion Strength;8;1;[Header];Create;True;1;Distortion;0;0;False;1;Space(6);False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1745.202,843.4027;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;30;-2058.325,552.9751;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;28;-2075.728,427.9752;Inherit;False;Property;_PatternScrolling;Pattern Scrolling;5;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-2188.724,-13.76625;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1622.466,847.2598;Inherit;False;UV_Distortion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;8;-2075.194,-15.729;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;27;-1902.307,316.0464;Inherit;False;Property;_PatternTiling;Pattern Tiling;4;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1869.362,468.0032;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-1680.11,504.8531;Inherit;False;60;UV_Distortion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-1563.033,-167.2905;Inherit;False;992.4153;382.533;.;7;31;37;32;7;21;18;39;Edge : Depth + Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;13;-1936.026,-17.01769;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1708.68,358.2223;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1813.54,-19.93163;Inherit;False;DepthValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-1482.753,424.5031;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1513.033,50.85405;Inherit;False;Property;_FresnelPower;Fresnel Power;2;0;Create;True;0;0;0;False;0;False;3;5;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;7;-1252.518,-43.68354;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;-1367.182,395.1896;Inherit;True;Property;_PatternTexture;Pattern Texture;3;2;[Header];[SingleLineTexture];Create;True;1;Pattern;0;0;False;1;Space(6);False;-1;36abeb6eea1606c41bb8d0aa15dd97eb;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;21;-1218.041,-117.2905;Inherit;False;19;DepthValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1388.437,753.5592;Inherit;False;805.2114;339.9423;.;5;44;48;41;49;64;Scene Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-1023.171,-77.86091;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1225.317,581.1479;Inherit;False;Property;_PatternOpacity;Pattern Opacity;6;1;[Header];Create;True;1;Opacity;0;0;False;1;Space(6);False;0.2;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-1077.701,420.1117;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1297.282,118.1176;Inherit;False;Property;_EdgeOpacity;Edge Opacity;7;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-924.334,418.1949;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;44;-1332.678,803.5592;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1338.437,977.5015;Inherit;False;60;UV_Distortion;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-898.2968,-19.42476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-1112.948,872.5611;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-800.5439,415.2394;Inherit;False;PatternOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-762.3795,-17.02596;Inherit;False;EdgeOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-537.4174,291.1089;Inherit;False;39;EdgeOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-543.8176,216.5294;Inherit;False;34;PatternOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;41;-976.6898,857.4374;Inherit;False;Global;_GrabScreen0;Grab Screen 0;8;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-435.2343,44.4583;Inherit;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;0;False;0;False;0.6981132,4,3.866618,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-807.2259,857.7678;Inherit;False;SceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-347.9037,224.5833;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-211.9817,292.421;Inherit;False;49;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-192.9599,103.4132;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-31.95761,201.8289;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;83.90278,158.2167;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Rito/Shield;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;68;0;67;0
WireConnection;47;0;53;0
WireConnection;69;0;47;0
WireConnection;69;1;68;0
WireConnection;46;1;69;0
WireConnection;17;0;2;4
WireConnection;45;0;46;0
WireConnection;45;1;54;0
WireConnection;52;0;45;0
WireConnection;52;1;51;0
WireConnection;52;2;55;0
WireConnection;16;0;1;0
WireConnection;16;1;17;0
WireConnection;16;2;14;0
WireConnection;60;0;52;0
WireConnection;8;0;16;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;13;0;8;0
WireConnection;26;0;27;0
WireConnection;26;1;29;0
WireConnection;19;0;13;0
WireConnection;59;0;26;0
WireConnection;59;1;62;0
WireConnection;7;3;18;0
WireConnection;22;1;59;0
WireConnection;37;0;21;0
WireConnection;37;1;7;0
WireConnection;23;0;22;1
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;31;0;37;0
WireConnection;31;1;32;0
WireConnection;48;0;44;0
WireConnection;48;1;64;0
WireConnection;34;0;24;0
WireConnection;39;0;31;0
WireConnection;41;0;48;0
WireConnection;49;0;41;0
WireConnection;9;0;35;0
WireConnection;9;1;40;0
WireConnection;42;0;11;0
WireConnection;42;1;9;0
WireConnection;43;0;42;0
WireConnection;43;1;50;0
WireConnection;0;2;43;0
ASEEND*/
//CHKSM=B0FEB4700DAD887AE9BAD9F1B66FB63327331252