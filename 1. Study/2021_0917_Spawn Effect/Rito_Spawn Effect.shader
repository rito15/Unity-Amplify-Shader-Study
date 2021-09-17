// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Spawn Effect"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		[HDR][Space(10)]_GridColor("Grid Color", Color) = (0.3349057,0.9003549,1,0)
		_GridPower("Grid Power", Range( 0 , 50)) = 4
		_GridTilingX("Grid Tiling X", Range( 2 , 128)) = 8
		_GridTilingY("Grid Tiling Y", Range( 2 , 128)) = 8
		_DissolveSmoothness("Dissolve Smoothness", Range( 0 , 1)) = 0.5
		_StartingWorldPosition("Starting World Position", Vector) = (0,32,0,0)
		_T("T", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float3 _StartingWorldPosition;
		uniform float _T;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _GridColor;
		uniform float _GridTilingX;
		uniform float _GridTilingY;
		uniform float _GridPower;
		uniform float _DissolveSmoothness;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 appendResult53 = (float4(_StartingWorldPosition , 1.0));
			float4 transform54 = mul(unity_WorldToObject,appendResult53);
			float3 appendResult55 = (float3(transform54.xyz));
			float3 TargetObjPos56 = appendResult55;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float T_1106 = ( 1.0 - saturate( ( 2.0 * _T ) ) );
			float2 _Vector0 = float2(-1,2);
			float3 normalizeResult63 = normalize( ( TargetObjPos56 - ase_vertex3Pos ) );
			float3 ase_vertexNormal = v.normal.xyz;
			float3 normalizeResult88 = normalize( ase_vertexNormal );
			float dotResult65 = dot( normalizeResult63 , normalizeResult88 );
			float3 lerpResult74 = lerp( float3( 0,0,0 ) , ( TargetObjPos56 - ase_vertex3Pos ) , saturate( ( (_Vector0.x + (T_1106 - 0.0) * (_Vector0.y - _Vector0.x) / (1.0 - 0.0)) + dotResult65 ) ));
			float3 WPO_Result75 = lerpResult74;
			v.vertex.xyz += WPO_Result75;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			o.Albedo = tex2D( _MainTexture, uv_MainTexture ).rgb;
			float2 appendResult22 = (float2(_GridTilingX , _GridTilingY));
			float2 temp_cast_1 = (_GridPower).xx;
			float2 break12 = pow( saturate( cos( ( i.uv_texcoord * ceil( appendResult22 ) * 6.28318548202515 ) ) ) , temp_cast_1 );
			float Grid_Result89 = saturate( ( break12.x + break12.y ) );
			float T_2107 = saturate( ( ( _T - 0.5 ) * 2.0 ) );
			float smoothstepResult100 = smoothstep( T_2107 , ( (-_DissolveSmoothness + (T_2107 - 0.0) * (1.0 - -_DissolveSmoothness) / (1.0 - 0.0)) + _DissolveSmoothness ) , ( 1.0 - i.uv_texcoord.y ));
			float T2_Dissolved101 = smoothstepResult100;
			o.Emission = ( _GridColor * Grid_Result89 * T2_Dissolved101 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
14;102;1863;917;3100.234;230.7275;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;77;-1243.413,558.826;Inherit;False;1457.337;852.3777;.;22;75;74;70;69;56;67;66;82;114;53;65;63;81;88;61;64;62;60;55;54;52;51;World Position Movement(T1);0.5235849,1,0.9899481,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-2504.706,-182.9049;Inherit;False;1711.315;452.8198;.;15;89;1;14;13;12;8;121;122;9;2;6;5;22;21;3;Grid;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;51;-1189.939,608.8262;Inherit;False;Property;_StartingWorldPosition;Starting World Position;6;0;Create;True;0;0;0;False;0;False;0,32,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;52;-1100.107,755.6879;Inherit;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2473.845,-15.32482;Inherit;False;Property;_GridTilingX;Grid Tiling X;3;0;Create;True;0;0;0;False;0;False;8;0;2;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;120;-2500.817,393.0619;Inherit;False;967.184;442.8464;.;10;106;107;126;129;131;130;134;128;135;136;Remap T[0, 0.5] => T1[0, 1] | T[0.5, 1] => T2[0, 1];1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2472.926,55.3496;Inherit;False;Property;_GridTilingY;Grid Tiling Y;4;0;Create;True;0;0;0;False;0;False;8;3;2;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-954.4946,647.7924;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;54;-814.1068,646.6879;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;22;-2196.423,4.323282;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2348.356,696.7044;Inherit;False;Constant;_05;0.5;8;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-2332.639,477.954;Inherit;False;Constant;_2;2;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-2472.795,589.2939;Inherit;False;Property;_T;T;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-2191.17,741.2403;Inherit;False;Constant;_2_;2_;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;5;-2074.147,4.175089;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-638.1064,646.6879;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TauNode;6;-2064.147,77.17506;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1;-2143.147,-113.8247;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;128;-2191.171,631.2102;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-2188.551,481.8837;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-502.1068,645.6879;Inherit;False;TargetObjPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-2033.985,663.9572;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;130;-2043.154,481.8837;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-1941.425,-19.99552;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;133;-1906.927,481.8838;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;121;-1807.692,-19.71854;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;131;-1899.067,663.9571;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;62;-1172.834,1195.621;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;60;-1179.694,1101.302;Inherit;False;56;TargetObjPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;102;-2500.559,962.2273;Inherit;False;1221.467;447.604;.;9;101;100;116;96;99;98;119;97;95;Dissolve(T2);1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalVertexDataNode;64;-1001.292,1242.995;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-994.4865,1133.885;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2450.559,1287.194;Inherit;False;Property;_DissolveSmoothness;Dissolve Smoothness;5;0;Create;True;0;0;0;False;0;False;0.5;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;122;-1684.119,-18.55254;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1815.807,61.77453;Inherit;False;Property;_GridPower;Grid Power;2;0;Create;True;0;0;0;False;0;False;4;17.78823;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-1763.633,659.4772;Inherit;False;T_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-1766.489,475.7151;Inherit;False;T_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;81;-1111.794,976.9961;Inherit;False;Constant;_Vector0;Vector 0;11;0;Create;True;0;0;0;False;0;False;-1,2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;116;-2357.744,1104.312;Inherit;False;107;T_2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;88;-824.8758,1241.494;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;63;-864.1552,1140.744;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;96;-2119.445,1246.781;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-1128.509,900.1293;Inherit;False;106;T_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;8;-1535.148,0.1751051;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;98;-2002.929,1023.022;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;82;-948.657,935.9484;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;65;-702.9558,1173.327;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;12;-1396.598,0.3992262;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TFHCRemapNode;97;-1987.929,1172.228;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;70;-490.4529,730.6335;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-550.493,1018.579;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-1794.341,1264.881;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-1287.398,-0.9007006;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;119;-1814.23,1073.493;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;67;-433.3079,1017.192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;100;-1649.137,1085.624;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;69;-305.2361,652.3391;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;14;-1174.154,-1.522161;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1479.672,1083.275;Inherit;False;T2_Dissolved;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;74;-140.6747,817.2565;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;123;-712.0533,-187.757;Inherit;False;918.2961;663.9789;.;7;76;0;90;93;24;117;91;Master Node;0.8735614,0.5896226,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-1007.915,-6.206418;Inherit;False;Grid_Result;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-630.8673,269.9025;Inherit;False;89;Grid_Result;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;24;-654.1063,87.37074;Inherit;False;Property;_GridColor;Grid Color;1;1;[HDR];Create;True;0;0;0;False;1;Space(10);False;0.3349057,0.9003549,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;6.527786,810.0004;Inherit;False;WPO_Result;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-637.9899,354.7717;Inherit;False;101;T2_Dissolved;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;91;-659.4795,-137.757;Inherit;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;76;-300.7434,303.0407;Inherit;False;75;WPO_Result;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-332.141,85.39986;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-114.5611,18.79657;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Rito/Spawn Effect;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;53;0;51;0
WireConnection;53;3;52;0
WireConnection;54;0;53;0
WireConnection;22;0;3;0
WireConnection;22;1;21;0
WireConnection;5;0;22;0
WireConnection;55;0;54;0
WireConnection;128;0;126;0
WireConnection;128;1;135;0
WireConnection;127;0;134;0
WireConnection;127;1;126;0
WireConnection;56;0;55;0
WireConnection;129;0;128;0
WireConnection;129;1;136;0
WireConnection;130;0;127;0
WireConnection;2;0;1;0
WireConnection;2;1;5;0
WireConnection;2;2;6;0
WireConnection;133;0;130;0
WireConnection;121;0;2;0
WireConnection;131;0;129;0
WireConnection;61;0;60;0
WireConnection;61;1;62;0
WireConnection;122;0;121;0
WireConnection;107;0;131;0
WireConnection;106;0;133;0
WireConnection;88;0;64;0
WireConnection;63;0;61;0
WireConnection;96;0;95;0
WireConnection;8;0;122;0
WireConnection;8;1;9;0
WireConnection;82;0;114;0
WireConnection;82;3;81;1
WireConnection;82;4;81;2
WireConnection;65;0;63;0
WireConnection;65;1;88;0
WireConnection;12;0;8;0
WireConnection;97;0;116;0
WireConnection;97;3;96;0
WireConnection;66;0;82;0
WireConnection;66;1;65;0
WireConnection;99;0;97;0
WireConnection;99;1;95;0
WireConnection;13;0;12;0
WireConnection;13;1;12;1
WireConnection;119;0;98;2
WireConnection;67;0;66;0
WireConnection;100;0;119;0
WireConnection;100;1;116;0
WireConnection;100;2;99;0
WireConnection;69;0;56;0
WireConnection;69;1;70;0
WireConnection;14;0;13;0
WireConnection;101;0;100;0
WireConnection;74;1;69;0
WireConnection;74;2;67;0
WireConnection;89;0;14;0
WireConnection;75;0;74;0
WireConnection;93;0;24;0
WireConnection;93;1;90;0
WireConnection;93;2;117;0
WireConnection;0;0;91;0
WireConnection;0;2;93;0
WireConnection;0;11;76;0
ASEEND*/
//CHKSM=39C6E93EF6405D343464C7E272E91FA6E75A10DD