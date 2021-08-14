// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Test/Polar Coord"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half filler;
		};

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
44;93;1863;926;325.2059;947.9171;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;98;-1601.724,-47.69885;Inherit;False;2123.915;847.4919;.;26;87;66;63;72;69;70;62;64;65;75;56;57;58;67;68;81;89;61;88;95;96;94;93;97;73;79;Radar;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-1354.202,-755.731;Inherit;False;1345.734;578.3539;.;13;22;19;18;23;24;25;29;26;27;28;9;20;21;Clock Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.StepOpNode;9;-243.4685,-512.7349;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1261.306,-592.1373;Inherit;False;Constant;_0_5_;0_5_;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1097.289,-572.6256;Inherit;False;Constant;_2_;2_;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;87;-972.3005,180.2615;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;66;-225.0018,179.9749;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;63;-587.2404,462.3544;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;29.07069,337.3451;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;69;-226.0289,442.9457;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-372.6286,529.3458;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-911.0062,458.4559;Inherit;False;Constant;_Start;Start;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;64;-723.7212,593.9357;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;65;-912.1853,534.7652;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;75;-565.9327,688.7932;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1199.972,180.9777;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-1346.832,162.0704;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;58;-1551.724,119.08;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-1508.828,233.9523;Inherit;False;Constant;_05;0.5;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1344.812,252.1866;Inherit;False;Constant;_20;2.0;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;81;-1255.574,407.0927;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;89;-1136.645,407.6605;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;61;-607.3997,180.269;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;88;-725.8776,180.5611;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;95;-107.4871,76.08401;Inherit;False;Constant;_10;1.0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;96;-98.85769,2.30116;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;94;28.72499,4.741956;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;93;-945.6201,2.893568;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;287.1913,209.1969;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;28;-802.7546,-346.446;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;27;-614.8901,-288.3769;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;26;-469.8069,-416.4572;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-820.8751,-422.9556;Inherit;False;Constant;_Float6;Float 6;0;0;Create;True;0;0;0;False;0;False;0.1736503;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1392.619,1460.698;Inherit;False;Property;_Float2;Float 2;0;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;36;-387.6023,1467.747;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;37;-970.3134,1253.064;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;38;25.94488,1136.657;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-133.1221,1278.654;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-819.9546,969.8962;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;41;-445.797,1266.438;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;42;-590.8798,1394.518;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;43;-778.7442,1336.449;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;44;-981.1815,935.4476;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-978.1598,1027.813;Inherit;False;Constant;_Float3;Float 3;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1144.663,995.6604;Inherit;False;Constant;_Float4;Float 4;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;47;-1188.655,881.2963;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;48;-622.1197,969.4209;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ATan2OpNode;49;-359.6369,969.5356;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;50;-494.0156,1026.428;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;51;-1110.498,1347.333;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1364.828,1250.214;Inherit;False;Constant;_Float5;Float 5;0;0;Create;True;0;0;0;False;0;False;0.4122574;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;53;276.0935,1359.439;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;104.4938,1440.039;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-952.4501,-643.8334;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;-1099.31,-662.7405;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;18;-1304.202,-705.731;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;23;-755.05,-643.2352;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NegateNode;24;-626.9461,-568.0277;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;25;-492.5673,-643.1205;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-832.4306,683.593;Inherit;False;Constant;_Angle;Angle;2;0;Create;True;0;0;0;False;0;False;45;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-1512.976,402.8929;Inherit;False;Constant;_Rotation;Rotation;2;0;Create;True;0;0;0;False;0;False;360;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;816.09,39.94135;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Test/Polar Coord;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;25;0
WireConnection;9;1;26;0
WireConnection;87;0;56;0
WireConnection;87;2;89;0
WireConnection;66;0;61;0
WireConnection;66;1;63;0
WireConnection;63;0;62;0
WireConnection;63;3;65;0
WireConnection;63;4;64;0
WireConnection;72;0;69;0
WireConnection;72;1;66;0
WireConnection;69;0;61;0
WireConnection;69;1;70;0
WireConnection;70;0;63;0
WireConnection;70;1;75;0
WireConnection;64;0;65;0
WireConnection;75;0;73;0
WireConnection;56;0;57;0
WireConnection;56;1;68;0
WireConnection;57;0;58;0
WireConnection;57;1;67;0
WireConnection;81;0;79;0
WireConnection;89;0;81;0
WireConnection;61;0;88;0
WireConnection;61;1;88;1
WireConnection;88;0;87;0
WireConnection;96;0;93;0
WireConnection;94;0;96;0
WireConnection;94;1;95;0
WireConnection;93;0;56;0
WireConnection;97;0;94;0
WireConnection;97;1;72;0
WireConnection;27;0;28;0
WireConnection;26;0;29;0
WireConnection;26;3;28;0
WireConnection;26;4;27;0
WireConnection;36;0;35;0
WireConnection;37;0;52;0
WireConnection;37;3;51;0
WireConnection;38;0;41;0
WireConnection;38;1;39;0
WireConnection;38;2;49;0
WireConnection;39;0;41;0
WireConnection;39;1;36;0
WireConnection;40;0;44;0
WireConnection;40;1;45;0
WireConnection;41;0;52;0
WireConnection;41;3;43;0
WireConnection;41;4;42;0
WireConnection;42;0;43;0
WireConnection;44;0;47;0
WireConnection;44;1;46;0
WireConnection;48;0;40;0
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;50;0;48;1
WireConnection;51;0;35;0
WireConnection;53;0;54;0
WireConnection;53;1;38;0
WireConnection;22;0;19;0
WireConnection;22;1;21;0
WireConnection;19;0;18;0
WireConnection;19;1;20;0
WireConnection;23;0;22;0
WireConnection;24;0;23;1
WireConnection;25;0;23;0
WireConnection;25;1;24;0
ASEEND*/
//CHKSM=96B92C219DA3E31DC399FDAEC2FA1979320C4899