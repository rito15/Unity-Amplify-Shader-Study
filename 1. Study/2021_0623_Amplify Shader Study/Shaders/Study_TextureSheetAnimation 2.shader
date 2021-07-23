// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Study/TextureSheetAnimation 2"
{
	Properties
	{
		_TextureSheet("Texture Sheet", 2D) = "white" {}
		_Column("Column", Int) = 4
		_Row("Row", Int) = 3
		_Speed("Speed", Range( 0 , 10)) = 2
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
		uniform int _Column;
		uniform int _Row;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float mulTime17 = _Time.y * _Speed;
			float temp_output_19_0 = floor( mulTime17 );
			float2 appendResult12 = (float2(( temp_output_19_0 + i.uv_texcoord.x ) , ( i.uv_texcoord.y + floor( ( temp_output_19_0 / _Column ) ) )));
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
111;195;1713;905;1579.921;342.0076;1;False;False
Node;AmplifyShaderEditor.RangedFloatNode;18;-1407.691,-194.8902;Inherit;False;Property;_Speed;Speed;3;0;Create;True;0;0;0;False;0;False;2;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-1306.292,-120.7902;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;19;-1146.392,-120.7903;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;2;-1171.801,152.2;Inherit;False;Property;_Column;Column;1;0;Create;True;0;0;0;False;0;False;4;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-987.7927,78.23203;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;7;-1210.09,-43.96804;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FloorOpNode;15;-878.7904,78.33195;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-744.2905,3.931873;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-744.6903,-84.26808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;3;-1172.801,221.1999;Inherit;False;Property;_Row;Row;2;0;Create;True;0;0;0;False;0;False;3;0;False;0;1;INT;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;-596.2916,145.532;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-595.0903,-49.26801;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-459.5909,71.73202;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-345.4995,43.00002;Inherit;True;Property;_TextureSheet;Texture Sheet;0;0;Create;True;0;0;0;False;0;False;-1;473ecccf4995f3b4481040b675b2da22;f66ee8625ad43454aabe438579cc8407;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Study/TextureSheetAnimation 2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;18;0
WireConnection;19;0;17;0
WireConnection;13;0;19;0
WireConnection;13;1;2;0
WireConnection;15;0;13;0
WireConnection;14;0;7;2
WireConnection;14;1;15;0
WireConnection;11;0;19;0
WireConnection;11;1;7;1
WireConnection;5;0;2;0
WireConnection;5;1;3;0
WireConnection;12;0;11;0
WireConnection;12;1;14;0
WireConnection;10;0;12;0
WireConnection;10;1;5;0
WireConnection;1;1;10;0
WireConnection;0;2;1;0
ASEEND*/
//CHKSM=EB28C46DD5178A4160A50F9CC64E36B9B28908AF