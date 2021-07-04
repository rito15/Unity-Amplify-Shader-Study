// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/WorldPositionOffset_02"
{
	Properties
	{
		_TargetPosition("Target Position", Vector) = (0,0,0,0)
		_T("T", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform float3 _TargetPosition;
		uniform float _T;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 appendResult3 = (float4(_TargetPosition , 1.0));
			float4 transform2 = mul(unity_WorldToObject,appendResult3);
			float3 Target_Object_Position13 = (transform2).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float2 _RemapNew = float2(-1,2);
			float3 normalizeResult20 = normalize( ( Target_Object_Position13 - ase_vertex3Pos ) );
			float3 ase_vertexNormal = v.normal.xyz;
			float dotResult28 = dot( normalizeResult20 , ase_vertexNormal );
			float LerpValue25 = saturate( ( (_RemapNew.x + (_T - 0.0) * (_RemapNew.y - _RemapNew.x) / (1.0 - 0.0)) + dotResult28 ) );
			float3 lerpResult5 = lerp( float3( 0,0,0 ) , ( Target_Object_Position13 - ase_vertex3Pos ) , LerpValue25);
			v.vertex.xyz += lerpResult5;
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
225;265;1713;991;2464.506;391.9158;1.765269;False;False
Node;AmplifyShaderEditor.CommentaryNode;15;-1585.801,-157.9999;Inherit;False;971.4363;307.2996;.;6;4;3;2;1;8;13;Target Position : World To Object;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;1;-1535.801,-107.9999;Inherit;False;Property;_TargetPosition;Target Position;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;4;-1492.801,33.29969;Inherit;False;Constant;_1;1;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;3;-1352.801,-103.9999;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;2;-1229.3,-103.9999;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;8;-1064.065,-103.1175;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-883.3638,-103.1175;Inherit;False;Target_Object_Position;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;27;-1732.159,215.3494;Inherit;False;1112.532;568.9672;.;12;10;28;29;17;18;20;19;22;21;23;24;25;Calculate T : Remap [0, 1] -> [-1, 2];1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1713.295,474.9235;Inherit;False;13;Target_Object_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;18;-1652.495,550.1237;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;-1482.895,497.3237;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;20;-1359.695,498.9238;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;29;-1380.25,607.1686;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-1708.638,283.0022;Inherit;False;Property;_T;T;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;23;-1406.329,339.8628;Inherit;False;Constant;_RemapNew;Remap New;2;0;Create;True;0;0;0;False;0;False;-1,2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DotProductOpNode;28;-1207.823,541.1686;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;22;-1258.828,289.3631;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1069.528,461.9624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;24;-962.3915,462.4187;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-845.3911,457.2184;Inherit;False;LerpValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;6;-534.7036,383.739;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;14;-595.8039,313.5391;Inherit;False;13;Target_Object_Position;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-355.7597,426.5554;Inherit;False;25;LerpValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-351.4045,321.3389;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;11;-225.3048,8.039351;Inherit;False;Constant;_Color0;Color 0;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;5;-200.4401,298.5567;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-33.54011,12.35688;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Rito/WorldPositionOffset_02;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;3;4;0
WireConnection;2;0;3;0
WireConnection;8;0;2;0
WireConnection;13;0;8;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;20;0;19;0
WireConnection;28;0;20;0
WireConnection;28;1;29;0
WireConnection;22;0;10;0
WireConnection;22;3;23;1
WireConnection;22;4;23;2
WireConnection;21;0;22;0
WireConnection;21;1;28;0
WireConnection;24;0;21;0
WireConnection;25;0;24;0
WireConnection;9;0;14;0
WireConnection;9;1;6;0
WireConnection;5;1;9;0
WireConnection;5;2;26;0
WireConnection;0;0;11;0
WireConnection;0;11;5;0
ASEEND*/
//CHKSM=87482BA81B368239E9E8122383DC05EF2D1CC9DE