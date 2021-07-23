// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Study/TextureSheetAnimation 3"
{
	Properties
	{
		_TextureSheet("Texture Sheet", 2D) = "white" {}
		_Column("Column", Int) = 8
		_Row("Row", Int) = 8
		_Speed("Speed", Range( 0 , 20)) = 20
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSheet;
		uniform float _Speed;
		uniform int _Row;
		uniform int _Column;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float mulTime17 = _Time.y * _Speed;
			float temp_output_19_0 = floor( mulTime17 );
			float2 appendResult12 = (float2(( temp_output_19_0 + i.uv_texcoord.x ) , ( (float)_Row - ( ( 1.0 - i.uv_texcoord.y ) + floor( ( temp_output_19_0 / _Column ) ) ) )));
			float2 appendResult5 = (float2((float)_Column , (float)_Row));
			o.Emission = tex2D( _TextureSheet, ( appendResult12 / appendResult5 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
111;195;1713;905;1589.59;367.2791;1.002428;False;False
Node;AmplifyShaderEditor.RangedFloatNode;18;-1510.985,-191.5855;Inherit;False;Property;_Speed;Speed;4;0;Create;True;0;0;0;False;0;False;20;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-1409.587,-117.4854;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;19;-1249.687,-117.4855;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;2;-1279.701,149.6;Inherit;False;Property;_Column;Column;2;0;Create;True;0;0;0;False;0;False;8;0;False;0;1;INT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;7;-1317.991,-46.56804;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-1095.692,75.63202;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;15;-986.6901,75.73195;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-1012.582,2.015004;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-852.1902,1.331873;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;3;-1280.701,218.5999;Inherit;False;Property;_Row;Row;3;0;Create;True;0;0;0;False;0;False;8;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-852.59,-86.86809;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-733.3796,65.71501;Inherit;False;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;-596.2916,145.532;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-595.0903,-49.26801;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-459.5909,71.73202;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;32;-906.906,449.3648;Inherit;False;Constant;_Row_Col;Row_Col;5;0;Create;True;0;0;0;False;0;False;8;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;33;-1065.906,523.3648;Inherit;False;Constant;_Int0;Int 0;5;0;Create;True;0;0;0;False;0;False;20;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;27;-523.906,427.3648;Inherit;True;Property;_TextureSheet1;Texture Sheet;1;0;Create;True;0;0;0;False;0;False;-1;6a1361191bc04624bba264b9fadf7011;f66ee8625ad43454aabe438579cc8407;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;28;-774.906,431.3648;Inherit;False;Flipbook;-1;;1;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;3;False;5;FLOAT;3;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.SimpleTimeNode;30;-933.906,527.3648;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-345.4995,41.70002;Inherit;True;Property;_TextureSheet;Texture Sheet;0;0;Create;True;0;0;0;False;0;False;-1;6a1361191bc04624bba264b9fadf7011;f66ee8625ad43454aabe438579cc8407;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;26;-1273.925,-326.4191;Inherit;False;Constant;_Index;Index;4;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Study/TextureSheetAnimation 3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;18;0
WireConnection;19;0;17;0
WireConnection;13;0;19;0
WireConnection;13;1;2;0
WireConnection;15;0;13;0
WireConnection;25;0;7;2
WireConnection;14;0;25;0
WireConnection;14;1;15;0
WireConnection;11;0;19;0
WireConnection;11;1;7;1
WireConnection;24;0;3;0
WireConnection;24;1;14;0
WireConnection;5;0;2;0
WireConnection;5;1;3;0
WireConnection;12;0;11;0
WireConnection;12;1;24;0
WireConnection;10;0;12;0
WireConnection;10;1;5;0
WireConnection;27;1;28;0
WireConnection;28;4;32;0
WireConnection;28;5;32;0
WireConnection;28;2;30;0
WireConnection;30;0;33;0
WireConnection;1;1;10;0
WireConnection;0;2;1;0
ASEEND*/
//CHKSM=644EA92420029D95B590DBEF0EDDFBD71AA68221