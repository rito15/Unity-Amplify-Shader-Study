// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Sea Urchin"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 6
		_Tint("Tint", Color) = (1,1,1,0)
		_Tiling("Tiling", Range( 1 , 24)) = 4
		_Sharpness("Sharpness", Range( 0 , 100)) = 50
		_Height("Height", Range( 0 , 1)) = 0.1
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
			half filler;
		};

		uniform float _Tiling;
		uniform float _Sharpness;
		uniform float _Height;
		uniform float4 _Tint;
		uniform float _EdgeLength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float smoothstepResult14 = smoothstep( 0.0 , 1.0 , distance( frac( ( v.texcoord.xy * floor( _Tiling ) ) ) , float2( 0.5,0.5 ) ));
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( pow( ( 1.0 - smoothstepResult14 ) , _Sharpness ) * ase_vertexNormal * _Height );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _Tint.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
0;126;1886;893;1456.61;433.6174;1.3046;False;False
Node;AmplifyShaderEditor.RangedFloatNode;3;-1376.511,6.286165;Inherit;False;Property;_Tiling;Tiling;6;0;Create;True;0;0;0;False;0;False;4;15;1;24;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;4;-1119.511,10.28617;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1;-1188.511,-114.714;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-975.5107,-64.7139;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;11;-846.5111,-61.71391;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;13;-845.3018,152.8677;Inherit;False;Constant;_05_05;0.5_0.5;1;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DistanceOpNode;12;-649.0797,-62.41525;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-581.963,151.0465;Inherit;False;Constant;_Zero;Zero;8;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-582.3224,223.7185;Inherit;False;Constant;_One;One;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;14;-387.9332,34.06758;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;18;-168.845,36.92538;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-271.9076,245.1348;Inherit;False;Property;_Sharpness;Sharpness;7;0;Create;True;0;0;0;False;0;False;50;1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-11.34416,462.3463;Inherit;False;Property;_Height;Height;8;0;Create;True;0;0;0;False;0;False;0.1;0.127;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;20;86.24194,316.7468;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;24;32.46446,100.7466;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;300.8718,290.779;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;23;205.9978,-87.02129;Inherit;False;Property;_Tint;Tint;5;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;430.6518,3.108094;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Rito/Sea Urchin;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;6;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
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
WireConnection;19;0;24;0
WireConnection;19;1;20;0
WireConnection;19;2;22;0
WireConnection;0;0;23;0
WireConnection;0;11;19;0
ASEEND*/
//CHKSM=C059D21D2E40B0319D41CA55DA094434A02B0E6C