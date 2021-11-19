// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Tree Growth_Body"
{
	Properties
	{
		_Grow("Grow", Range( 0 , 1)) = 0
		_AlphaClip("Alpha Clip", Range( 0 , 1)) = 0.95
		_Scale("Scale", Float) = -5
		_Tint("Tint", Color) = (0.3962264,0.1944226,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _Grow;
		uniform float _AlphaClip;
		uniform float _Scale;
		uniform float4 _Tint;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float UV_Y_Mask19 = saturate( ( ( v.texcoord.xy.y - _Grow ) + ( 1.0 - _AlphaClip ) ) );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( UV_Y_Mask19 * _Scale * ase_vertexNormal );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _Tint.rgb;
			o.Alpha = 1;
			float UV_Y_Mask19 = saturate( ( ( i.uv_texcoord.y - _Grow ) + ( 1.0 - _AlphaClip ) ) );
			clip( ( 1.0 - UV_Y_Mask19 ) - _AlphaClip );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
231;242;1642;845;1264.176;456.2195;1.65586;False;False
Node;AmplifyShaderEditor.CommentaryNode;17;-684.9357,-286.5625;Inherit;False;902.8752;369.6713;UV.Y Mask;8;19;24;15;26;10;9;3;11;;0,0.5943396,0.08048353,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-657.8768,-1.842791;Inherit;False;Property;_AlphaClip;Alpha Clip;1;0;Create;True;0;0;0;False;0;False;0.95;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;9;-581.7789,-235.6251;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-664.483,-115.4388;Inherit;False;Property;_Grow;Grow;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-384.1058,-188.7185;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;-404.9145,2.031039;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-245.4627,-101.233;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;11;-123.7195,-181.1256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;18;-681.199,90.90453;Inherit;False;363.2323;128.4172;Alpha Clipping;2;14;21;;0,0.754717,0.7297305,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;8.404806,-185.4413;Inherit;True;UV_Y_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;23;-682.7104,230.3111;Inherit;False;366.7455;334.0658;Move Vertices;4;7;5;22;13;;0.5377358,0,0.4596644,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-664.3872,135.7874;Inherit;False;19;UV_Y_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-657.0076,275.7553;Inherit;False;19;UV_Y_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;5;-654.789,416.3044;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-619.1115,346.2917;Inherit;False;Property;_Scale;Scale;2;0;Create;True;0;0;0;False;0;False;-5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-452.147,325.9751;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;14;-475.6484,142.4234;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;-193.7246,88.94867;Inherit;False;Property;_Tint;Tint;3;0;Create;True;0;0;0;False;0;False;0.3962264,0.1944226,0,0;0.3962264,0.1944226,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;12.14873,94.15251;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Rito/Tree Growth_Body;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;6;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;15;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;2
WireConnection;10;1;3;0
WireConnection;24;0;15;0
WireConnection;26;0;10;0
WireConnection;26;1;24;0
WireConnection;11;0;26;0
WireConnection;19;0;11;0
WireConnection;7;0;22;0
WireConnection;7;1;13;0
WireConnection;7;2;5;0
WireConnection;14;0;21;0
WireConnection;0;0;27;0
WireConnection;0;10;14;0
WireConnection;0;11;7;0
ASEEND*/
//CHKSM=8D3D3BACA13A26888F346C1048C6D9D9DEAEE266