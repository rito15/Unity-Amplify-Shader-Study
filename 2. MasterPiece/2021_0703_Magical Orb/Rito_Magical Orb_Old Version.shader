// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Magical Orb_Old Version"
{
	Properties
	{
		[Header(Pattern)][SingleLineTexture][Space(8)]_PatternTexture("Pattern Texture", 2D) = "white" {}
		_TilingXY("Tiling XY", Vector) = (1,1,0,0)
		[HDR]_PatternColor("Pattern Color", Color) = (0.3632075,1,0.8648483,0)
		_ScrollingSpeed("Scrolling Speed", Range( 0 , 4)) = 0.5
		[Header(Displacement)][Space(8)]_DisplacementSpeed("Displacement Speed", Range( 0 , 1)) = 0.5
		_DisplacementScale("Displacement Scale", Range( 1 , 12)) = 2
		_DisplacementRange("Displacement Range", Range( 0 , 1)) = 0.5
		[Header(Distortion)][Space(8)]_DistortionSpeed("Distortion Speed", Range( 0 , 1)) = 0.2
		_DistortionScale("Distortion Scale", Range( 0 , 10)) = 4
		_DistortionStrength("Distortion Strength", Range( 0 , 1)) = 0.1
		[Header(Fresnel)][Space(8)]_FresnelPower("Fresnel Power", Range( 0 , 10)) = 5
		_FresnelIntensity("Fresnel Intensity", Range( 0 , 4)) = 1
		[HDR]_FresnelColor("Fresnel Color", Color) = (0.5960785,2,1.819608,0)
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

		uniform float _DisplacementSpeed;
		uniform float _DisplacementScale;
		uniform float _DisplacementRange;
		uniform float4 _PatternColor;
		uniform sampler2D _PatternTexture;
		uniform float2 _TilingXY;
		uniform float _ScrollingSpeed;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _DistortionSpeed;
		uniform float _DistortionScale;
		uniform float _DistortionStrength;
		uniform float4 _FresnelColor;
		uniform float _FresnelIntensity;
		uniform float _FresnelPower;


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float mulTime3 = _Time.y * _DisplacementSpeed;
			float simplePerlin2D6 = snoise( ( ase_vertex3Pos + mulTime3 ).xy*_DisplacementScale );
			simplePerlin2D6 = simplePerlin2D6*0.5 + 0.5;
			float3 VertexDisplacement14 = ( ase_vertexNormal * simplePerlin2D6 * _DisplacementRange * 0.1 );
			v.vertex.xyz += VertexDisplacement14;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float temp_output_20_0 = ( _Time.y * _ScrollingSpeed * 0.1 );
			float2 temp_cast_0 = (temp_output_20_0).xx;
			float2 uv_TexCoord23 = i.uv_texcoord * _TilingXY + temp_cast_0;
			float2 temp_cast_1 = (-temp_output_20_0).xx;
			float2 uv_TexCoord24 = i.uv_texcoord * _TilingXY + temp_cast_1;
			float4 PatternColor29 = ( _PatternColor * ( tex2D( _PatternTexture, uv_TexCoord23 ).b + tex2D( _PatternTexture, uv_TexCoord24 ).b ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 temp_cast_2 = (0.5).xx;
			float mulTime36 = _Time.y * _DistortionSpeed;
			float cos62 = cos( mulTime36 );
			float sin62 = sin( mulTime36 );
			float2 rotator62 = mul( i.uv_texcoord - temp_cast_2 , float2x2( cos62 , -sin62 , sin62 , cos62 )) + temp_cast_2;
			float simplePerlin2D38 = snoise( rotator62*_DistortionScale );
			simplePerlin2D38 = simplePerlin2D38*0.5 + 0.5;
			float4 screenColor46 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_screenPosNorm + ( simplePerlin2D38 * _DistortionStrength ) ).xy);
			float4 Distortion49 = screenColor46;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV54 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode54 = ( 0.0 + _FresnelIntensity * pow( 1.0 - fresnelNdotV54, _FresnelPower ) );
			float4 FresnelColor58 = ( _FresnelColor * fresnelNode54 );
			o.Emission = ( PatternColor29 + Distortion49 + FresnelColor58 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				vertexDataFunc( v, customInputData );
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
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
122;107;1713;947;2123.797;-107.7279;1;False;False
Node;AmplifyShaderEditor.CommentaryNode;50;-2081.898,426.2583;Inherit;False;1670.63;544.7673;.;13;49;46;48;47;61;38;45;39;62;36;40;41;35;Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;34;-2079.236,-115.2556;Inherit;False;1613.101;476.564;.;14;19;17;31;20;16;23;24;22;25;33;26;27;28;29;Pattern Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1931.041,58.9594;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2029.235,122.9195;Inherit;False;Property;_ScrollingSpeed;Scrolling Speed;3;0;Create;True;0;0;0;False;0;False;0.5;0.2;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1904.645,191.3468;Inherit;False;Constant;_01_;0.1_;7;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2033.898,748.976;Inherit;False;Property;_DistortionSpeed;Distortion Speed;7;1;[Header];Create;True;1;Distortion;0;0;False;1;Space(8);False;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1744.123,103.2931;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;36;-1779.83,747.3255;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-1824.531,544.7257;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-1755.431,664.3256;Inherit;False;Constant;_05;0.5;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;16;-1744.47,-15.71767;Inherit;False;Property;_TilingXY;Tiling XY;1;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;39;-1660.331,856.6252;Inherit;False;Property;_DistortionScale;Distortion Scale;8;0;Create;True;0;0;0;False;0;False;4;4;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;62;-1581.684,646.3464;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;33;-1738.987,215.2269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;13;-2080.169,-672.4365;Inherit;False;1296.915;491.7744;.;11;9;8;11;10;6;7;5;4;3;1;14;Vertex Displacement;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-2030.168,-416.6092;Inherit;False;Property;_DisplacementSpeed;Displacement Speed;4;1;[Header];Create;True;1;Displacement;0;0;False;1;Space(8);False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1376.444,855.8951;Inherit;False;Property;_DistortionStrength;Distortion Strength;9;0;Create;True;0;0;0;False;0;False;0.1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;-761.8225,-624.4389;Inherit;False;996.8203;438.8207;.;6;56;54;53;57;55;58;Fresnel Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-1544.358,-32.41908;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;38;-1371.831,640.1256;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-1545.589,148.7732;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;47;-1080.272,484.2583;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-1057.144,726.3497;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;4;-1786.342,-560.1607;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;-1345.909,120.4233;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;22;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;-710.5697,-371.206;Inherit;False;Property;_FresnelIntensity;Fresnel Intensity;11;0;Create;True;0;0;0;False;0;False;1;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1774.731,-411.331;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;-1345.909,-60.76881;Inherit;True;Property;_PatternTexture;Pattern Texture;0;2;[Header];[SingleLineTexture];Create;True;1;Pattern;0;0;False;1;Space(8);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-711.8226,-301.618;Inherit;False;Property;_FresnelPower;Fresnel Power;10;1;[Header];Create;True;1;Fresnel;0;0;False;1;Space(8);False;5;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-891.4016,601.5369;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1756.787,-321.6124;Inherit;False;Property;_DisplacementScale;Displacement Scale;5;0;Create;True;0;0;0;False;0;False;2;4;1;12;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;56;-419.1205,-574.4388;Inherit;False;Property;_FresnelColor;Fresnel Color;12;1;[HDR];Create;True;0;0;0;False;0;False;0.5960785,2,1.819608,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-1586.846,-494.7186;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;27;-1032.529,-65.25557;Inherit;False;Property;_PatternColor;Pattern Color;2;1;[HDR];Create;True;0;0;0;False;0;False;0.3632075,1,0.8648483,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-1034.994,107.3083;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;54;-441.1954,-405.9679;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;46;-781.2824,595.9736;Inherit;False;Global;_GrabScreen0;Grab Screen 0;10;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-1314.522,-278.3359;Inherit;False;Constant;_01;0.1;3;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;11;-1366.242,-622.4366;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;6;-1433.795,-469.3861;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-810.9285,45.74335;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1436.962,-361.7228;Inherit;False;Property;_DisplacementRange;Displacement Range;6;0;Create;True;0;0;0;False;0;False;0.5;4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-181.273,-494.0389;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-619.2682,595.2533;Inherit;False;Distortion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;10.99811,-495.3569;Inherit;False;FresnelColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1134.027,-442.9971;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-690.1336,40.813;Inherit;False;PatternColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-997.1181,-448.1695;Inherit;False;VertexDisplacement;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-298.5169,136.1348;Inherit;False;58;FresnelColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-297.9669,0.3588995;Inherit;False;29;PatternColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-282.8013,68.78742;Inherit;False;49;Distortion;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-209.8983,261.6771;Inherit;False;14;VertexDisplacement;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-115.6577,48.22898;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Rito/Magical Orb_Old Version;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;19;0
WireConnection;20;1;17;0
WireConnection;20;2;31;0
WireConnection;36;0;35;0
WireConnection;62;0;41;0
WireConnection;62;1;40;0
WireConnection;62;2;36;0
WireConnection;33;0;20;0
WireConnection;23;0;16;0
WireConnection;23;1;20;0
WireConnection;38;0;62;0
WireConnection;38;1;39;0
WireConnection;24;0;16;0
WireConnection;24;1;33;0
WireConnection;61;0;38;0
WireConnection;61;1;45;0
WireConnection;25;1;24;0
WireConnection;3;0;1;0
WireConnection;22;1;23;0
WireConnection;48;0;47;0
WireConnection;48;1;61;0
WireConnection;5;0;4;0
WireConnection;5;1;3;0
WireConnection;26;0;22;3
WireConnection;26;1;25;3
WireConnection;54;2;55;0
WireConnection;54;3;53;0
WireConnection;46;0;48;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;28;0;27;0
WireConnection;28;1;26;0
WireConnection;57;0;56;0
WireConnection;57;1;54;0
WireConnection;49;0;46;0
WireConnection;58;0;57;0
WireConnection;9;0;11;0
WireConnection;9;1;6;0
WireConnection;9;2;8;0
WireConnection;9;3;10;0
WireConnection;29;0;28;0
WireConnection;14;0;9;0
WireConnection;52;0;30;0
WireConnection;52;1;51;0
WireConnection;52;2;60;0
WireConnection;0;2;52;0
WireConnection;0;11;15;0
ASEEND*/
//CHKSM=E1E88EB3379B6762EF1E8E82812C35565527F65D