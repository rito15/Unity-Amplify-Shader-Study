// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Test/Checkerboard With Fade"
{
	Properties
	{
		_Resolution("Resolution", Range( 1 , 64)) = 16
		_ColorA("Color A", Color) = (0,0,0,0)
		_ColorB("Color B", Color) = (1,1,1,0)
		_CameraDistance("Camera Distance", Range( 0 , 100)) = 10
		_Smoothness("Smoothness", Range( 1 , 100)) = 10
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _ColorA;
		uniform float4 _ColorB;
		uniform float _Resolution;
		uniform float _CameraDistance;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 appendResult36 = (float3(_ColorA.rgb));
			float3 appendResult37 = (float3(_ColorB.rgb));
			float2 break6 = floor( ( i.uv_texcoord * _Resolution ) );
			float3 lerpResult12 = lerp( appendResult36 , appendResult37 , fmod( ( break6.x + break6.y ) , 2.0 ));
			float3 CheckerboardColor29 = lerpResult12;
			float3 MiddleColor30 = ( ( appendResult36 + appendResult37 ) * 0.5 );
			float3 ase_worldPos = i.worldPos;
			float CamDistLerpValue31 = saturate( ( ( distance( ase_worldPos , _WorldSpaceCameraPos ) - _CameraDistance ) / _Smoothness ) );
			float3 lerpResult34 = lerp( CheckerboardColor29 , MiddleColor30 , CamDistLerpValue31);
			o.Albedo = lerpResult34;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
427;158;1468;777;1671.446;325.4814;1.6;False;False
Node;AmplifyShaderEditor.CommentaryNode;53;-1269.701,-200.0072;Inherit;False;1531.098;679.8145;.;18;4;1;3;2;11;6;37;39;26;12;38;29;30;10;36;8;5;7;Checkerboard;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1;-1140.701,173.6;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-1219.701,294.6;Inherit;False;Property;_Resolution;Resolution;0;0;Create;True;0;0;0;False;0;False;16;0;1;64;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-926.7004,215.6;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;52;-1184.759,576.2867;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;14;-1247.407,716.4769;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FloorOpNode;2;-810.7004,215.6;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;21;-978.5399,576.3358;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-631.2861,41.26262;Inherit;False;Property;_ColorB;Color B;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-632.8005,-150.0072;Inherit;False;Property;_ColorA;Color A;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;6;-707.7004,214.6;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;23;-980.6833,686.186;Inherit;False;Property;_CameraDistance;Camera Distance;3;0;Create;True;0;0;0;False;0;False;10;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-610.5077,312.8073;Inherit;False;Constant;_2_;_2_;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-693.0993,577.1722;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-980.2993,778.8661;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;10;0;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-437.6013,46.39903;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-594.5077,215.4073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-443.3015,-143.5082;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-209.6021,-143.6012;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-230.5015,-54.30098;Inherit;False;Constant;_05_;_0.5_;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;7;-480.5073,225.8073;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-567.5831,576.8357;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;49;-1270.507,523.2993;Inherit;False;1168.635;349.8995;.;1;31;Camera Distance-Based Fade(Lerp Value);1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;12;-235.0856,23.06276;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-88.00159,-143.6009;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;24;-458.1002,576.2718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-88.00231,17.89914;Inherit;False;CheckerboardColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;37.39772,-147.4009;Inherit;False;MiddleColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-321.8508,571.2952;Inherit;False;CamDistLerpValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-78.02299,523.8672;Inherit;False;29;CheckerboardColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-40.02301,594.1672;Inherit;False;30;MiddleColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-72.92299,662.5667;Inherit;False;31;CamDistLerpValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;34;160.777,575.1672;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;323.2371,454.4569;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Test/Checkerboard With Fade;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;1;4;0
WireConnection;2;0;3;0
WireConnection;21;0;52;0
WireConnection;21;1;14;0
WireConnection;6;0;2;0
WireConnection;40;0;21;0
WireConnection;40;1;23;0
WireConnection;37;0;11;0
WireConnection;5;0;6;0
WireConnection;5;1;6;1
WireConnection;36;0;10;0
WireConnection;26;0;36;0
WireConnection;26;1;37;0
WireConnection;7;0;5;0
WireConnection;7;1;8;0
WireConnection;22;0;40;0
WireConnection;22;1;42;0
WireConnection;12;0;36;0
WireConnection;12;1;37;0
WireConnection;12;2;7;0
WireConnection;38;0;26;0
WireConnection;38;1;39;0
WireConnection;24;0;22;0
WireConnection;29;0;12;0
WireConnection;30;0;38;0
WireConnection;31;0;24;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;34;2;35;0
WireConnection;0;0;34;0
ASEEND*/
//CHKSM=507C25D7F993AEFAECAC426495A0B59B226358B6