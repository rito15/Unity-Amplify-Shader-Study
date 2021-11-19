// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Sea Urchin_Transitioning_A"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 6
		_Tiling("Tiling", Range( 1 , 24)) = 4
		_Sharpness("Sharpness", Range( 0 , 100)) = 50
		_Height("Height", Range( 0 , 1)) = 0.1
		[Header(Color Options)][Space(6)]_BodyColor("Body Color", Color) = (1,1,1,0)
		_ThornColor("Thorn Color", Color) = (0,0,0,0)
		_ColorMixThreshold("Color Mix Threshold", Range( -1 , 1)) = 0
		_ColorMixSmoothness("Color Mix Smoothness", Range( 0.01 , 1)) = 0.4045754
		[Header(Transitioning Options)][Space(6)]_Transition("Transition", Range( 0 , 1)) = 0
		_TransitionDirection("Transition Direction", Vector) = (0,1,0,0)
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
		uniform float3 _TransitionDirection;
		uniform float _Transition;
		uniform float4 _BodyColor;
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
			float3 normalizeResult43 = normalize( _TransitionDirection );
			float3 normalizeResult57 = normalize( ase_vertexNormal );
			float dotResult45 = dot( normalizeResult43 , normalizeResult57 );
			float2 _RemapRange = float2(-2,2);
			float Transition_Mask52 = saturate( ( dotResult45 + (_RemapRange.x + (_Transition - 0.0) * (_RemapRange.y - _RemapRange.x) / (1.0 - 0.0)) ) );
			v.vertex.xyz += ( Thorn_Mask28 * ase_vertexNormal * _Height * Transition_Mask52 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float smoothstepResult14 = smoothstep( 0.0 , 1.0 , distance( frac( ( i.uv_texcoord * floor( _Tiling ) ) ) , float2( 0.5,0.5 ) ));
			float Thorn_Mask28 = pow( ( 1.0 - smoothstepResult14 ) , _Sharpness );
			float smoothstepResult31 = smoothstep( _ColorMixThreshold , ( _ColorMixThreshold + _ColorMixSmoothness ) , Thorn_Mask28);
			float3 normalizeResult43 = normalize( _TransitionDirection );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 normalizeResult57 = normalize( ase_vertexNormal );
			float dotResult45 = dot( normalizeResult43 , normalizeResult57 );
			float2 _RemapRange = float2(-2,2);
			float Transition_Mask52 = saturate( ( dotResult45 + (_RemapRange.x + (_Transition - 0.0) * (_RemapRange.y - _RemapRange.x) / (1.0 - 0.0)) ) );
			float4 lerpResult38 = lerp( _BodyColor , _ThornColor , ( smoothstepResult31 * Transition_Mask52 ));
			float4 Final_Color39 = lerpResult38;
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
326;242;1886;875;2318.426;768.8539;2.466415;False;False
Node;AmplifyShaderEditor.CommentaryNode;27;-1251.524,-661.5395;Inherit;False;1896.401;503.6706;.;14;28;24;25;18;14;12;26;15;13;11;10;1;4;3;Thorn Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1201.524,-490.5392;Inherit;False;Property;_Tiling;Tiling;5;0;Create;True;0;0;0;False;0;False;4;15;1;24;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;4;-944.5239,-486.5392;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1;-1013.524,-611.5394;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-800.5234,-561.5393;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;54;-1246.936,-52.23605;Inherit;False;1168.062;531.1005;.;11;47;48;49;50;42;44;43;45;46;52;57;Transition Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.FractNode;11;-671.524,-558.5393;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;13;-670.3148,-343.9578;Inherit;False;Constant;_05_05;0.5_0.5;1;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;15;-406.9763,-345.779;Inherit;False;Constant;_Zero;Zero;8;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;12;-474.0929,-559.2407;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;44;-1226.072,142.0652;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-407.3357,-273.107;Inherit;False;Constant;_One;One;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;42;-1223.623,-3.536059;Inherit;False;Property;_TransitionDirection;Transition Direction;13;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;14;-212.9465,-462.7578;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;57;-983.5168,114.0844;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1068.573,232.9648;Inherit;False;Property;_Transition;Transition;12;1;[Header];Create;True;1;Transitioning Options;0;0;False;1;Space(6);False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;48;-963.2729,313.5649;Inherit;False;Constant;_RemapRange;RemapRange;10;0;Create;True;0;0;0;False;0;False;-2,2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.NormalizeNode;43;-981.235,2.863894;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;47;-799.4726,236.8647;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;45;-824.1732,21.06446;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;18;6.141781,-459.9;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-96.9208,-251.6907;Inherit;False;Property;_Sharpness;Sharpness;6;0;Create;True;0;0;0;False;0;False;50;1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;207.4514,-396.0789;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-578.8223,111.5369;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1243.301,586.2655;Inherit;False;1748.484;473.8517;.;11;39;38;55;56;34;23;31;30;36;32;35;Color Mix;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-979.21,861.4785;Inherit;False;Property;_ColorMixThreshold;Color Mix Threshold;10;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;433.9258,-395.5569;Inherit;False;Thorn_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;50;-448.7528,110.4637;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-977.4796,936.9988;Inherit;False;Property;_ColorMixSmoothness;Color Mix Smoothness;11;0;Create;True;0;0;0;False;0;False;0.4045754;0;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-305.4067,107.4735;Inherit;False;Transition_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-705.5859,916.6478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-704.7218,836.2433;Inherit;False;28;Thorn_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;31;-535.6198,841.8781;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-305.2394,914.6536;Inherit;False;52;Transition_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-1190.301,803.0493;Inherit;False;Property;_ThornColor;Thorn Color;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;-1192.208,636.2654;Inherit;False;Property;_BodyColor;Body Color;8;1;[Header];Create;True;1;Color Options;0;0;False;1;Space(6);False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-129.0757,845.5233;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;38;16.04274,647.2765;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-51.95683,341.2022;Inherit;False;Property;_Height;Height;7;0;Create;True;0;0;0;False;0;False;0.1;0.127;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;159.9728,641.9535;Inherit;False;Final_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;20;45.62934,195.6024;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;53;40.60847,420.1253;Inherit;False;52;Transition_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;38.29136,118.4117;Inherit;False;28;Thorn_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;260.26,169.6344;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;223.0375,-66.79994;Inherit;False;39;Final_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;406.0401,-63.63593;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Rito/Sea Urchin_Transitioning_A;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;6;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;10;0;1;0
WireConnection;10;1;4;0
WireConnection;11;0;10;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;14;2;26;0
WireConnection;57;0;44;0
WireConnection;43;0;42;0
WireConnection;47;0;46;0
WireConnection;47;3;48;1
WireConnection;47;4;48;2
WireConnection;45;0;43;0
WireConnection;45;1;57;0
WireConnection;18;0;14;0
WireConnection;24;0;18;0
WireConnection;24;1;25;0
WireConnection;49;0;45;0
WireConnection;49;1;47;0
WireConnection;28;0;24;0
WireConnection;50;0;49;0
WireConnection;52;0;50;0
WireConnection;36;0;32;0
WireConnection;36;1;35;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;31;2;36;0
WireConnection;56;0;31;0
WireConnection;56;1;55;0
WireConnection;38;0;23;0
WireConnection;38;1;34;0
WireConnection;38;2;56;0
WireConnection;39;0;38;0
WireConnection;19;0;29;0
WireConnection;19;1;20;0
WireConnection;19;2;22;0
WireConnection;19;3;53;0
WireConnection;0;0;41;0
WireConnection;0;11;19;0
ASEEND*/
//CHKSM=60BF1A65FAF64F51C5511C7B71BBBB73BCF91692