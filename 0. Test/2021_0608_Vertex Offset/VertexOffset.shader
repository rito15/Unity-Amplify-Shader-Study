// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "VertexOffset"
{
	Properties
	{
		_TargetPosition("Target Position", Vector) = (0,0,0,0)
		_Progress("Progress", Range( 0 , 5)) = 0
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

		uniform float3 _TargetPosition;
		uniform float _Progress;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 transform3 = mul(unity_WorldToObject,float4( _TargetPosition , 0.0 ));
			float4 lerpResult5 = lerp( float4( ase_vertex3Pos , 0.0 ) , transform3 , _Progress);
			float4 _Vector1 = float4(-1,1,0,1);
			float4 lerpResult13 = lerp( float4( ase_vertex3Pos , 0.0 ) , ( lerpResult5 + ( ase_vertex3Pos.y * ( ( 1.0 - _Progress ) - 1.0 ) ) ) , (_Vector1.z + (ase_vertex3Pos.y - _Vector1.x) * (_Vector1.w - _Vector1.z) / (_Vector1.y - _Vector1.x)));
			v.vertex.xyz += lerpResult13.xyz;
			v.vertex.w = 1;
		}

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
413;312;1511;815;1453.939;796.4044;1.9;True;True
Node;AmplifyShaderEditor.RangedFloatNode;4;-959.0206,184.9866;Inherit;False;Property;_Progress;Progress;1;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;7;-649.5034,251.9097;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-749.5079,360.8702;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;2;-822.2924,-87.96208;Inherit;False;Property;_TargetPosition;Target Position;0;0;Create;True;0;0;0;False;0;False;0,0,0;5,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;6;-813.6906,-267.5192;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-604.7244,348.9294;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;3;-628.0058,-89.9808;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;16;-202.3521,-334.8836;Inherit;False;Constant;_Vector1;Vector 1;2;0;Create;True;0;0;0;False;0;False;-1,1,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;5;-379.1672,-209.6825;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-368.8923,344.4514;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;14;-18.39301,-345.8895;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-204.7046,308.6288;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;13;52.50541,197.7306;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;475.7044,-137.1596;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;VertexOffset;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;4;0
WireConnection;11;0;7;0
WireConnection;11;1;12;0
WireConnection;3;0;2;0
WireConnection;5;0;6;0
WireConnection;5;1;3;0
WireConnection;5;2;4;0
WireConnection;9;0;6;2
WireConnection;9;1;11;0
WireConnection;14;0;6;2
WireConnection;14;1;16;1
WireConnection;14;2;16;2
WireConnection;14;3;16;3
WireConnection;14;4;16;4
WireConnection;10;0;5;0
WireConnection;10;1;9;0
WireConnection;13;0;6;0
WireConnection;13;1;10;0
WireConnection;13;2;14;0
WireConnection;0;11;13;0
ASEEND*/
//CHKSM=A79F5BC9FD05E86582A3D7CAD4777AD3824C0EF6