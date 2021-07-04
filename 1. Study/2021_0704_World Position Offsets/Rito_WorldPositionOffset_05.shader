// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/WorldPositionOffset_05"
{
	Properties
	{
		_TargetPosition("Target Position", Vector) = (0,0,0,0)
		_Range("Range", Float) = 0
		_Smoothness("Smoothness", Range( 0 , 10)) = 1
		_TwirlDirection("Twirl Direction", Range( -0.5 , 0.5)) = 0.3
		_TwirlStrength("Twirl Strength", Range( 0 , 1)) = 0.5
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform float3 _TargetPosition;
		uniform float _TwirlDirection;
		uniform float _Range;
		uniform float _Smoothness;
		uniform float _TwirlStrength;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult3 = (float4(_TargetPosition , 1.0));
			float4 transform2 = mul(unity_WorldToObject,appendResult3);
			float3 Target_Object_Position13 = (transform2).xyz;
			float3 objectSpaceViewDir42 = ObjSpaceViewDir( float4( 0,0,0,1 ) );
			float LerpValue25 = saturate( ( ( _Range - distance( Target_Object_Position13 , ase_vertex3Pos ) ) / _Smoothness ) );
			float3 lerpResult35 = lerp( ase_vertex3Pos , ( Target_Object_Position13 + ( cross( ( Target_Object_Position13 - ase_vertex3Pos ) , objectSpaceViewDir42 ) * _TwirlDirection ) ) , ( LerpValue25 * _TwirlStrength ));
			float3 VertexPosition_Twirled52 = lerpResult35;
			float3 lerpResult5 = lerp( VertexPosition_Twirled52 , Target_Object_Position13 , LerpValue25);
			v.vertex.xyz += ( lerpResult5 - ase_vertex3Pos );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color11 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			o.Albedo = color11.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
344;256;1713;979;2464.37;246.6208;1.992096;False;False
Node;AmplifyShaderEditor.CommentaryNode;15;-1631.488,-141.079;Inherit;False;971.4363;307.2996;.;6;4;3;2;1;8;13;Target Position : World To Object;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;1;-1581.488,-91.07897;Inherit;False;Property;_TargetPosition;Target Position;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;4;-1538.488,50.22066;Inherit;False;Constant;_1;1;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;3;-1398.488,-87.07897;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;2;-1274.987,-87.07897;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;8;-1109.752,-86.19657;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;27;-1633.358,215.3494;Inherit;False;1017.632;377.8672;.;9;25;24;32;33;31;10;30;18;17;Calculate LerpValue = Saturate( (Range - Distance) / Smoothness ) ;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-929.0501,-86.19657;Inherit;False;Target_Object_Position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;18;-1553.694,422.7239;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1614.494,347.5237;Inherit;False;13;Target_Object_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1509.037,268.5021;Inherit;False;Property;_Range;Range;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;30;-1361.913,375.9326;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1326.914,479.7324;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;54;-1632.043,638.9406;Inherit;False;1424.452;662.0207;.;15;6;43;49;42;44;46;45;38;37;50;51;47;39;35;52;Twirl : Cross(VertexToTargetDir, ObjectViewDir);1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-1180.712,274.1328;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;33;-1040.913,353.9326;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1582.043,729.7626;Inherit;False;13;Target_Object_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;6;-1527.671,804.447;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-1339,757.84;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjSpaceViewDirHlpNode;42;-1405.243,946.8627;Inherit;False;1;0;FLOAT4;0,0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;24;-924.6915,353.2188;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;44;-1183.242,849.7631;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-807.691,348.0185;Inherit;False;LerpValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1332.444,1095.062;Inherit;False;Property;_TwirlDirection;Twirl Direction;3;0;Create;True;0;0;0;False;0;False;0.3;0.2;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1138.799,731.8399;Inherit;False;13;Target_Object_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1065.541,1184.961;Inherit;False;Property;_TwirlStrength;Twirl Strength;4;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-954.9419,1107.761;Inherit;False;25;LerpValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1034.842,956.0632;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;51;-863.2002,688.9406;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-789.8428,1111.661;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-884.2428,849.0632;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;35;-641.0435,824.5628;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-476.5915,819.2601;Inherit;False;VertexPosition_Twirled;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-567.0615,314.4691;Inherit;False;13;Target_Object_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-567.5793,249.8978;Inherit;False;52;VertexPosition_Twirled;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-498.2719,381.8886;Inherit;False;25;LerpValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;5;-318.5578,296.5566;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;36;-333.6602,435.8794;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-144.5219,351.8393;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;11;-216.0222,58.03901;Inherit;False;Constant;_Color0;Color 0;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-24.25761,62.35654;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Rito/WorldPositionOffset_05;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;3;4;0
WireConnection;2;0;3;0
WireConnection;8;0;2;0
WireConnection;13;0;8;0
WireConnection;30;0;17;0
WireConnection;30;1;18;0
WireConnection;32;0;10;0
WireConnection;32;1;30;0
WireConnection;33;0;32;0
WireConnection;33;1;31;0
WireConnection;49;0;43;0
WireConnection;49;1;6;0
WireConnection;24;0;33;0
WireConnection;44;0;49;0
WireConnection;44;1;42;0
WireConnection;25;0;24;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;39;0;38;0
WireConnection;39;1;37;0
WireConnection;47;0;50;0
WireConnection;47;1;45;0
WireConnection;35;0;51;0
WireConnection;35;1;47;0
WireConnection;35;2;39;0
WireConnection;52;0;35;0
WireConnection;5;0;53;0
WireConnection;5;1;14;0
WireConnection;5;2;26;0
WireConnection;9;0;5;0
WireConnection;9;1;36;0
WireConnection;0;0;11;0
WireConnection;0;11;9;0
ASEEND*/
//CHKSM=2C9F0C20D8DBF2BEF2B12BD53034D691DDEE5C98