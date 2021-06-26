// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Study/HeartBeat"
{
	Properties
	{
		_Frequency("Frequency", Range( 0 , 20)) = 10
		_Amplitude("Amplitude", Range( 0 , 2)) = 0.5
		_Sensitivity("Sensitivity", Range( 0 , 1)) = 0.2
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform float _Amplitude;
		uniform float _Frequency;
		uniform float _Sensitivity;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float mulTime2 = _Time.y * _Frequency;
			float temp_output_13_0 = ( 1.0 - _Sensitivity );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( _Amplitude * ( max( sin( mulTime2 ) , temp_output_13_0 ) - temp_output_13_0 ) * ase_vertexNormal );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color10 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float4 White9 = color10;
			o.Albedo = White9.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
140;327;1249;986;1601.436;476.4501;1.934188;False;False
Node;AmplifyShaderEditor.RangedFloatNode;1;-947.6908,268.6688;Inherit;False;Property;_Frequency;Frequency;0;0;Create;True;0;0;0;False;0;False;10;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;2;-695.4902,273.8688;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-822.8892,363.5688;Inherit;False;Property;_Sensitivity;Sensitivity;2;0;Create;True;0;0;0;False;0;False;0.2;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;-571.9897,368.7688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;3;-545.9901,273.8688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-733.7898,-267.231;Inherit;False;Constant;_White;White;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;4;-426.3901,292.0688;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-310.6899,345.3692;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-435.4894,201.0689;Inherit;False;Property;_Amplitude;Amplitude;1;0;Create;True;0;0;0;False;0;False;0.5;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;7;-340.59,454.5691;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-542.6898,-265.9312;Inherit;False;White;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-124.7896,288.169;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StickyNoteNode;17;-751.0471,-24.80488;Inherit;False;451.5999;133.8;( max( sin(T * F), 1-S ) - (1-S) ) * A;;1,1,1,1;T : Time$F : Frequency$S : Sensitivity$A : Amplitude;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;-159.1897,-4.631059;Inherit;False;9;White;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Study/HeartBeat;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;1;0
WireConnection;13;0;12;0
WireConnection;3;0;2;0
WireConnection;4;0;3;0
WireConnection;4;1;13;0
WireConnection;15;0;4;0
WireConnection;15;1;13;0
WireConnection;9;0;10;0
WireConnection;8;0;5;0
WireConnection;8;1;15;0
WireConnection;8;2;7;0
WireConnection;0;0;11;0
WireConnection;0;11;8;0
ASEEND*/
//CHKSM=8F5CDCFF0BE29A2F54096CE0243A395766567422