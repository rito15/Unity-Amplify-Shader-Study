// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WorldPosOffset"
{
	Properties
	{
		_TargetWorldPosition("Target World Position", Vector) = (0,0,0,0)
		_Offset("Offset", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform float3 _TargetWorldPosition;
		uniform float _Offset;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult52 = (float4(ase_vertex3Pos.x , ase_vertex3Pos.y , ase_vertex3Pos.z , 1.0));
			float4 transform10 = mul(unity_ObjectToWorld,appendResult52);
			float4 appendResult13 = (float4(_TargetWorldPosition.x , _TargetWorldPosition.y , _TargetWorldPosition.z , 1.0));
			float4 lerpResult5 = lerp( transform10 , appendResult13 , saturate( ( 2.0 * _Offset ) ));
			float3 appendResult50 = (float3(transform10.x , transform10.y , transform10.z));
			float3 normalizeResult18 = normalize( ( _TargetWorldPosition - appendResult50 ) );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 transform40 = mul(unity_ObjectToWorld,float4( ase_vertexNormal , 0.0 ));
			float3 appendResult47 = (float3(transform40.x , transform40.y , transform40.z));
			float dotResult21 = dot( normalizeResult18 , appendResult47 );
			float4 lerpResult38 = lerp( transform10 , lerpResult5 , (0.0 + (dotResult21 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)));
			float4 lerpResult26 = lerp( lerpResult38 , appendResult13 , _Offset);
			float4 transform7 = mul(unity_WorldToObject,lerpResult26);
			v.vertex.xyz += ( transform7 - float4( ase_vertex3Pos , 0.0 ) ).xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color55 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			o.Albedo = color55.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
160;233;1855;1013;2264.019;916.0895;1.637064;True;False
Node;AmplifyShaderEditor.CommentaryNode;54;-1452.896,-233.4596;Inherit;False;582.0293;304.4612;Origin World Vertex Position;4;10;52;9;53;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;9;-1402.896,-183.4596;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-1362.217,-44.99847;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1210.216,-145.7984;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;51;-836.4952,282.6014;Inherit;False;917.5261;377.2018;Normal Direction - Dot Mask;9;19;40;17;18;47;21;23;22;50;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;10;-1084.867,-146.1664;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;15;-1289.531,74.55283;Inherit;False;421.6773;318.6685;Target World Vertex Position;3;13;14;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-864.8926,-415.4479;Inherit;False;458.0994;185.9002;Offset2 : [0 ~ 1] -> x2 Fast;3;28;31;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;32;-1235.556,-405.1495;Inherit;False;350;166;Offset1 : [0 ~ 1];1;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;1;-1239.531,124.5528;Inherit;False;Property;_TargetWorldPosition;Target World Position;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;19;-786.4952,454.1031;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;50;-755.0162,332.6014;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1185.556,-355.1495;Inherit;False;Property;_Offset;Offset;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-814.8927,-365.448;Inherit;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;40;-595.1558,452.8032;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;17;-554.0917,333.571;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;18;-419.3622,336.3848;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;47;-417.1104,476.9852;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1166.454,277.2214;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-691.3926,-364.5478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;31;-571.7928,-362.8479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-511.0799,-37.08379;Inherit;False;232;209;Lerp1 : Origin -> Target;1;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;21;-254.852,363.1463;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-272.3105,486.3206;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-1013.653,186.6214;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TFHCRemapNode;22;-125.9689,410.0908;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;5;-461.0802,12.91623;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;39;-67.82402,-165.4997;Inherit;False;232;209;Lerp2 : Normal Dot Masked;1;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;38;-17.82424,-115.4999;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;37;122.9456,98.42088;Inherit;False;330.5825;209;Lerp3 : Origin -> Normal Masked Target;1;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;26;207.6675,164.9555;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;3;499.139,324.658;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToObjectTransfNode;7;486.0492,150.7273;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;8;696.3204,214.0261;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;55;627.7947,-78.60633;Inherit;False;Constant;_Color0;Color 0;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;833.8563,-76.83031;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;WorldPosOffset;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;9;1
WireConnection;52;1;9;2
WireConnection;52;2;9;3
WireConnection;52;3;53;0
WireConnection;10;0;52;0
WireConnection;50;0;10;1
WireConnection;50;1;10;2
WireConnection;50;2;10;3
WireConnection;40;0;19;0
WireConnection;17;0;1;0
WireConnection;17;1;50;0
WireConnection;18;0;17;0
WireConnection;47;0;40;1
WireConnection;47;1;40;2
WireConnection;47;2;40;3
WireConnection;28;0;29;0
WireConnection;28;1;2;0
WireConnection;31;0;28;0
WireConnection;21;0;18;0
WireConnection;21;1;47;0
WireConnection;13;0;1;1
WireConnection;13;1;1;2
WireConnection;13;2;1;3
WireConnection;13;3;14;0
WireConnection;22;0;21;0
WireConnection;22;1;23;0
WireConnection;5;0;10;0
WireConnection;5;1;13;0
WireConnection;5;2;31;0
WireConnection;38;0;10;0
WireConnection;38;1;5;0
WireConnection;38;2;22;0
WireConnection;26;0;38;0
WireConnection;26;1;13;0
WireConnection;26;2;2;0
WireConnection;7;0;26;0
WireConnection;8;0;7;0
WireConnection;8;1;3;0
WireConnection;0;0;55;0
WireConnection;0;11;8;0
ASEEND*/
//CHKSM=48C5D9C7F911F31C9D25C4D904071FC6141C9190