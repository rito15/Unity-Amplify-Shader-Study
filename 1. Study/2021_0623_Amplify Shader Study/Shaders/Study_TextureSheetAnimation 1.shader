// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Study/TextureSheetAnimation"
{
	Properties
	{
		_TextureSheet("Texture Sheet", 2D) = "white" {}
		_Row("Row", Int) = 3
		_Column("Column", Int) = 2
		_Index("Index", Int) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSheet;
		uniform int _Index;
		uniform int _Row;
		uniform int _Column;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult12 = (float2(( _Index + i.uv_texcoord.x ) , ( i.uv_texcoord.y + floor( ( _Index / _Row ) ) )));
			float2 appendResult5 = (float2((float)_Row , (float)_Column));
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
323;248;1713;917;1786.892;307.9904;1.3;True;False
Node;AmplifyShaderEditor.IntNode;2;-1146.701,149.6;Inherit;False;Property;_Row;Row;1;0;Create;True;0;0;0;False;0;False;3;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;16;-1135.59,-119.0682;Inherit;False;Property;_Index;Index;3;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-962.6923,75.63202;Inherit;False;2;0;INT;0;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;7;-1184.991,-46.56804;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FloorOpNode;15;-853.6901,75.73195;Inherit;False;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-719.59,-86.86809;Inherit;False;2;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-719.1902,1.331873;Inherit;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;3;-1147.701,218.5999;Inherit;False;Property;_Column;Column;2;0;Create;True;0;0;0;False;0;False;2;0;False;0;1;INT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-595.0903,-49.26801;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;-596.2916,145.532;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-459.5909,71.73202;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-345.4995,41.70002;Inherit;True;Property;_TextureSheet;Texture Sheet;0;0;Create;True;0;0;0;False;0;False;-1;f66ee8625ad43454aabe438579cc8407;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Study/TextureSheetAnimation;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;16;0
WireConnection;13;1;2;0
WireConnection;15;0;13;0
WireConnection;11;0;16;0
WireConnection;11;1;7;1
WireConnection;14;0;7;2
WireConnection;14;1;15;0
WireConnection;12;0;11;0
WireConnection;12;1;14;0
WireConnection;5;0;2;0
WireConnection;5;1;3;0
WireConnection;10;0;12;0
WireConnection;10;1;5;0
WireConnection;1;1;10;0
WireConnection;0;2;1;0
ASEEND*/
//CHKSM=18BC31C3E0B66F4C097BF5FF4BD1B23C0ABDC2A0