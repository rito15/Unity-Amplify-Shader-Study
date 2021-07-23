// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Sea Urchin_Colored"
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
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _Tiling;
		uniform float _Sharpness;
		uniform float _Height;
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
			v.vertex.xyz += ( Thorn_Mask28 * ase_vertexNormal * _Height );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float smoothstepResult14 = smoothstep( 0.0 , 1.0 , distance( frac( ( i.uv_texcoord * floor( _Tiling ) ) ) , float2( 0.5,0.5 ) ));
			float Thorn_Mask28 = pow( ( 1.0 - smoothstepResult14 ) , _Sharpness );
			float smoothstepResult31 = smoothstep( _ColorMixThreshold , ( _ColorMixThreshold + _ColorMixSmoothness ) , Thorn_Mask28);
			float4 lerpResult38 = lerp( _BodyColor , _ThornColor , smoothstepResult31);
			float4 Final_Color39 = lerpResult38;
			o.Albedo = Final_Color39.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
0;126;1886;893;2058.335;890.2947;1.6;True;False
Node;AmplifyShaderEditor.CommentaryNode;27;-1251.524,-661.5395;Inherit;False;1896.401;503.6706;.;14;28;24;25;18;14;12;26;15;13;11;10;1;4;3;Thorn Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1201.524,-490.5392;Inherit;False;Property;_Tiling;Tiling;5;0;Create;True;0;0;0;False;0;False;4;15;1;24;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;4;-944.5239,-486.5392;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1;-1013.524,-611.5394;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-800.5234,-561.5393;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;11;-671.524,-558.5393;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;13;-670.3148,-343.9578;Inherit;False;Constant;_05_05;0.5_0.5;1;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DistanceOpNode;12;-474.0929,-559.2407;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-407.3357,-273.107;Inherit;False;Constant;_One;One;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-406.9763,-345.779;Inherit;False;Constant;_Zero;Zero;8;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;14;-212.9465,-462.7578;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;18;6.141781,-459.9;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-96.9208,-251.6907;Inherit;False;Property;_Sharpness;Sharpness;6;0;Create;True;0;0;0;False;0;False;50;1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;207.4514,-396.0789;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-1248.377,-86.21051;Inherit;False;1290.274;478.7332;.;9;30;31;36;32;35;34;39;38;23;Color Mix;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-984.2851,189.0025;Inherit;False;Property;_ColorMixThreshold;Color Mix Threshold;10;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-982.5547,264.5227;Inherit;False;Property;_ColorMixSmoothness;Color Mix Smoothness;11;0;Create;True;0;0;0;False;0;False;0.4045754;0;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;433.9258,-395.5569;Inherit;False;Thorn_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-710.661,244.1718;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-709.7969,163.7673;Inherit;False;28;Thorn_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-1195.377,130.5732;Inherit;False;Property;_ThornColor;Thorn Color;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;-1197.284,-36.21051;Inherit;False;Property;_BodyColor;Body Color;8;1;[Header];Create;True;1;Color Options;0;0;False;1;Space(6);False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;31;-540.6949,169.4021;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;38;-293.0326,-26.79947;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-149.1024,-32.12247;Inherit;False;Final_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;149.81,103.2921;Inherit;False;28;Thorn_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;59.56181,326.0822;Inherit;False;Property;_Height;Height;7;0;Create;True;0;0;0;False;0;False;0.1;0.127;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;20;157.148,180.4826;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;371.7786,154.5148;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;318.5561,-133.1198;Inherit;False;39;Final_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;501.5587,-133.1558;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Rito/Sea Urchin_Colored;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;6;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;10;0;1;0
WireConnection;10;1;4;0
WireConnection;11;0;10;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;14;2;26;0
WireConnection;18;0;14;0
WireConnection;24;0;18;0
WireConnection;24;1;25;0
WireConnection;28;0;24;0
WireConnection;36;0;32;0
WireConnection;36;1;35;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;31;2;36;0
WireConnection;38;0;23;0
WireConnection;38;1;34;0
WireConnection;38;2;31;0
WireConnection;39;0;38;0
WireConnection;19;0;29;0
WireConnection;19;1;20;0
WireConnection;19;2;22;0
WireConnection;0;0;41;0
WireConnection;0;11;19;0
ASEEND*/
//CHKSM=C81346F2EB673064FF562F9038C3A9EA81E1300B