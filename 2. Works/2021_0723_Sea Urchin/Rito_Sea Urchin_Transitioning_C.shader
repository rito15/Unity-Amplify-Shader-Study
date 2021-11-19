// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Sea Urchin_Transitioning_C"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 6
		_Tiling("Tiling", Range( 1 , 24)) = 4
		_Sharpness("Sharpness", Range( 0 , 100)) = 50
		_Height("Height", Range( 0 , 1)) = 0.1
		[Header(Color Options)][Space(6)]_BodyColorA("Body Color A", Color) = (1,1,1,0)
		_BodyColorB("Body Color B", Color) = (0.9597633,1,0,0)
		_ThornColor("Thorn Color", Color) = (1,0,0,0)
		_ColorMixThreshold("Color Mix Threshold", Range( -1 , 1)) = 0
		_ColorMixSmoothness("Color Mix Smoothness", Range( 0.01 , 1)) = 0.4045754
		[Header(Transitioning Options)][Space(6)]_Transition("Transition", Range( 0 , 1)) = 0
		_TransitionSmoothness("Transition Smoothness", Range( 0 , 1)) = 0.5
		_TransitionDirection("Transition Direction", Vector) = (0,1,0,0)
		_TransitioningHeight("Transitioning Height", Range( 0 , 0.2)) = 0.05
		_TransitioningPower("Transitioning Power", Range( 0 , 20)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
		};

		uniform float _Tiling;
		uniform float _Sharpness;
		uniform float _Height;
		uniform float _Transition;
		uniform float _TransitionSmoothness;
		uniform float3 _TransitionDirection;
		uniform float _TransitioningPower;
		uniform float _TransitioningHeight;
		uniform float4 _BodyColorA;
		uniform float4 _BodyColorB;
		uniform float4 _ThornColor;
		uniform float _ColorMixThreshold;
		uniform float _ColorMixSmoothness;
		uniform float _EdgeLength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float smoothstepResult14 = smoothstep( 0.0 , 1.0 , distance( frac( ( v.texcoord.xy * floor( _Tiling ) ) ) , float2( 0.5,0.5 ) ));
			float Thorn_Mask28 = pow( ( 1.0 - smoothstepResult14 ) , _Sharpness );
			float3 ase_vertexNormal = v.normal.xyz;
			float temp_output_47_0 = (1.0 + (_Transition - 0.0) * (( -1.0 - _TransitionSmoothness ) - 1.0) / (1.0 - 0.0));
			float3 normalizeResult43 = normalize( _TransitionDirection );
			float3 normalizeResult61 = normalize( ase_vertexNormal );
			float dotResult45 = dot( normalizeResult43 , normalizeResult61 );
			float smoothstepResult63 = smoothstep( temp_output_47_0 , ( temp_output_47_0 + _TransitionSmoothness ) , dotResult45);
			float Transition_Mask52 = smoothstepResult63;
			float3 Transitioning_Height83 = ( ase_vertexNormal * pow( sin( ( Transition_Mask52 * UNITY_PI ) ) , _TransitioningPower ) * _TransitioningHeight );
			v.vertex.xyz += ( ( Thorn_Mask28 * ase_vertexNormal * _Height * Transition_Mask52 ) + Transitioning_Height83 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float smoothstepResult14 = smoothstep( 0.0 , 1.0 , distance( frac( ( i.uv_texcoord * floor( _Tiling ) ) ) , float2( 0.5,0.5 ) ));
			float Thorn_Mask28 = pow( ( 1.0 - smoothstepResult14 ) , _Sharpness );
			float smoothstepResult31 = smoothstep( _ColorMixThreshold , ( _ColorMixThreshold + _ColorMixSmoothness ) , Thorn_Mask28);
			float4 lerpResult38 = lerp( _BodyColorB , _ThornColor , smoothstepResult31);
			float temp_output_47_0 = (1.0 + (_Transition - 0.0) * (( -1.0 - _TransitionSmoothness ) - 1.0) / (1.0 - 0.0));
			float3 normalizeResult43 = normalize( _TransitionDirection );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 normalizeResult61 = normalize( ase_vertexNormal );
			float dotResult45 = dot( normalizeResult43 , normalizeResult61 );
			float smoothstepResult63 = smoothstep( temp_output_47_0 , ( temp_output_47_0 + _TransitionSmoothness ) , dotResult45);
			float Transition_Mask52 = smoothstepResult63;
			float4 lerpResult60 = lerp( _BodyColorA , lerpResult38 , Transition_Mask52);
			float4 Final_Color39 = lerpResult60;
			o.Albedo = Final_Color39.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				float3 worldNormal : TEXCOORD3;
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
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
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
				surfIN.worldNormal = IN.worldNormal;
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
326;242;1886;875;2081.668;794.8948;2.742629;False;False
Node;AmplifyShaderEditor.CommentaryNode;27;-1251.524,-661.5395;Inherit;False;1896.401;503.6706;.;14;28;24;25;18;14;12;26;15;13;11;10;1;4;3;Thorn Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1201.524,-490.5392;Inherit;False;Property;_Tiling;Tiling;5;0;Create;True;0;0;0;False;0;False;4;15;1;24;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;54;-1257.6,-103.7918;Inherit;False;1175.716;592.6268;.;14;52;63;66;45;43;61;47;64;46;44;42;71;72;73;Transition Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.FloorOpNode;4;-944.5239,-486.5392;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1;-1013.524,-611.5394;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;64;-1216.988,401.4399;Inherit;False;Property;_TransitionSmoothness;Transition Smoothness;14;0;Create;True;0;0;0;False;0;False;0.5;0.5868475;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1082.469,327.3867;Inherit;False;Constant;_1_;-1_;12;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-800.5234,-561.5393;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;-929.0677,332.5869;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;44;-1216.926,96.08519;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;42;-1217.964,-53.79173;Inherit;False;Property;_TransitionDirection;Transition Direction;15;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;71;-930.3688,254.5875;Inherit;False;Constant;_1;1;12;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1231.677,239.8438;Inherit;False;Property;_Transition;Transition;13;1;[Header];Create;True;1;Transitioning Options;0;0;False;1;Space(6);False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;61;-968.4479,95.51629;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;43;-968.2616,-49.05714;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;47;-778.1724,186.6089;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;13;-670.3148,-343.9578;Inherit;False;Constant;_05_05;0.5_0.5;1;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FractNode;11;-671.524,-558.5393;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;45;-802.873,-29.19123;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-581.9551,375.9641;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;12;-474.0929,-559.2407;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-407.3357,-273.107;Inherit;False;Constant;_One;One;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-406.9763,-345.779;Inherit;False;Constant;_Zero;Zero;8;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;63;-420.2919,154.8025;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;14;-212.9465,-462.7578;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;18;6.141781,-459.9;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-269.5869,149.1826;Inherit;False;Transition_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-96.9208,-251.6907;Inherit;False;Property;_Sharpness;Sharpness;6;0;Create;True;0;0;0;False;0;False;50;1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;86;-1254.505,543.4224;Inherit;False;1128.884;445.885;.;10;77;74;76;79;75;78;80;85;81;83;Transition Hill;1,1,1,1;0;0
Node;AmplifyShaderEditor.PiNode;77;-1186.963,802.4795;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;207.4514,-396.0789;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-1204.505,711.8386;Inherit;False;52;Transition_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1249.428,1045.249;Inherit;False;1747.184;680.5518;.;12;39;38;23;34;31;55;30;36;32;35;59;60;Color Mix;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-993.9891,742.54;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-990.1069,1588.383;Inherit;False;Property;_ColorMixSmoothness;Color Mix Smoothness;12;0;Create;True;0;0;0;False;0;False;0.4045754;0;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;433.9258,-395.5569;Inherit;False;Thorn_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-991.8373,1512.862;Inherit;False;Property;_ColorMixThreshold;Color Mix Threshold;11;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-717.349,1487.627;Inherit;False;28;Thorn_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-718.2131,1568.032;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-1005.431,843.7516;Inherit;False;Property;_TransitioningPower;Transitioning Power;17;0;Create;True;0;0;0;False;0;False;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;75;-856.5673,742.5396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-1202.928,1454.432;Inherit;False;Property;_ThornColor;Thorn Color;10;0;Create;True;0;0;0;False;0;False;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;78;-711.836,757.1591;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;31;-548.2471,1493.262;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;80;-717.6835,593.4224;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;-714.6298,873.3074;Inherit;False;Property;_TransitioningHeight;Transitioning Height;16;0;Create;True;0;0;0;False;0;False;0.05;0.1;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;59;-1205.5,1283.951;Inherit;False;Property;_BodyColorB;Body Color B;9;0;Create;True;0;0;0;False;0;False;0.9597633,1,0,0;0.9597633,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-514.4746,669.4431;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;38;-305.9844,1385.759;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;23;-1206.135,1108.248;Inherit;False;Property;_BodyColorA;Body Color A;8;1;[Header];Create;True;1;Color Options;0;0;False;1;Space(6);False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;55;-138.4668,1465.938;Inherit;False;52;Transition_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;46.40156,1345.052;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;-381.6232,663.6368;Inherit;False;Transitioning_Height;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;20;6.55341,368.653;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-91.03276,514.2527;Inherit;False;Property;_Height;Height;7;0;Create;True;0;0;0;False;0;False;0.1;0.127;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;1.532537,593.1758;Inherit;False;52;Transition_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-0.7845755,291.4622;Inherit;False;28;Thorn_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;227.6841,398.5849;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;203.9335,1339.771;Inherit;False;Final_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;173.1991,685.5239;Inherit;False;83;Transitioning_Height;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;323.4655,218.3519;Inherit;False;39;Final_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;395.2028,567.4744;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;534.3481,223.9404;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Rito/Sea Urchin_Transitioning_C;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;6;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;10;0;1;0
WireConnection;10;1;4;0
WireConnection;73;0;72;0
WireConnection;73;1;64;0
WireConnection;61;0;44;0
WireConnection;43;0;42;0
WireConnection;47;0;46;0
WireConnection;47;3;71;0
WireConnection;47;4;73;0
WireConnection;11;0;10;0
WireConnection;45;0;43;0
WireConnection;45;1;61;0
WireConnection;66;0;47;0
WireConnection;66;1;64;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;63;0;45;0
WireConnection;63;1;47;0
WireConnection;63;2;66;0
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;14;2;26;0
WireConnection;18;0;14;0
WireConnection;52;0;63;0
WireConnection;24;0;18;0
WireConnection;24;1;25;0
WireConnection;76;0;74;0
WireConnection;76;1;77;0
WireConnection;28;0;24;0
WireConnection;36;0;32;0
WireConnection;36;1;35;0
WireConnection;75;0;76;0
WireConnection;78;0;75;0
WireConnection;78;1;79;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;31;2;36;0
WireConnection;81;0;80;0
WireConnection;81;1;78;0
WireConnection;81;2;85;0
WireConnection;38;0;59;0
WireConnection;38;1;34;0
WireConnection;38;2;31;0
WireConnection;60;0;23;0
WireConnection;60;1;38;0
WireConnection;60;2;55;0
WireConnection;83;0;81;0
WireConnection;19;0;29;0
WireConnection;19;1;20;0
WireConnection;19;2;22;0
WireConnection;19;3;53;0
WireConnection;39;0;60;0
WireConnection;82;0;19;0
WireConnection;82;1;84;0
WireConnection;0;0;41;0
WireConnection;0;11;82;0
ASEEND*/
//CHKSM=0638E5CBCBA7C65B5545A0634CB3DBBB78C4F9C6