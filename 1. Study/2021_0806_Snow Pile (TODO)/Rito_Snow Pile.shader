// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Snow Pile"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 6
		_NoiseScale("Noise Scale", Float) = 4
		_DotRange("Dot Range", Range( -1 , 1)) = 0.3245822
		_NoiseRange("Noise Range", Range( -1 , 1)) = 0
		_SnowIntensity("Snow Intensity", Range( 0 , 10)) = 1
		_Height("Height", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _NoiseRange;
		uniform float _NoiseScale;
		uniform float _SnowIntensity;
		uniform float _DotRange;
		uniform float _Height;
		uniform float _EdgeLength;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float simplePerlin2D2 = snoise( v.texcoord.xy*_NoiseScale );
			simplePerlin2D2 = simplePerlin2D2*0.5 + 0.5;
			float smoothstepResult9 = smoothstep( _NoiseRange , 1.0 , simplePerlin2D2);
			float3 ase_vertex3Pos = v.vertex.xyz;
			float dotResult23 = dot( ase_vertex3Pos , float3(0,1,0) );
			float smoothstepResult25 = smoothstep( _DotRange , 1.0 , dotResult23);
			float Snow_Noise14 = ( smoothstepResult9 * _SnowIntensity * smoothstepResult25 );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( Snow_Noise14 * _Height * ase_vertexNormal * 0.1 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color5 = IsGammaSpace() ? float4(0,0.3396226,0.08128886,0) : float4(0,0.0944128,0.007360357,0);
			float simplePerlin2D2 = snoise( i.uv_texcoord*_NoiseScale );
			simplePerlin2D2 = simplePerlin2D2*0.5 + 0.5;
			float smoothstepResult9 = smoothstep( _NoiseRange , 1.0 , simplePerlin2D2);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float dotResult23 = dot( ase_vertex3Pos , float3(0,1,0) );
			float smoothstepResult25 = smoothstep( _DotRange , 1.0 , dotResult23);
			float Snow_Noise14 = ( smoothstepResult9 * _SnowIntensity * smoothstepResult25 );
			o.Albedo = ( color5 + Snow_Noise14 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
868;446;1642;809;2294.59;-78.31527;1.9;True;False
Node;AmplifyShaderEditor.RangedFloatNode;4;-1537.319,336.3352;Inherit;False;Property;_NoiseScale;Noise Scale;5;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;24;-1627.187,814.7313;Inherit;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;22;-1652.12,657.4474;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;3;-1569.319,205.3352;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;23;-1427.787,708.8312;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1306.668,379.9152;Inherit;False;Property;_NoiseRange;Noise Range;7;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;2;-1357.319,204.3352;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1510.515,954.9841;Inherit;False;Property;_DotRange;Dot Range;6;0;Create;True;0;0;0;False;0;False;0.3245822;0.3245822;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;25;-1118.515,724.5842;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1166.269,487.8153;Inherit;False;Property;_SnowIntensity;Snow Intensity;8;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;9;-1021.969,230.415;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-821.7688,275.9153;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-659.7887,369.5937;Inherit;False;Snow_Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;13;-301.389,431.9934;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-277.3892,575.9943;Inherit;False;Constant;_01;0.1;3;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-397.3895,355.1938;Inherit;False;Property;_Height;Height;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-323.7893,257.5937;Inherit;False;14;Snow_Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-411.7894,99.1937;Inherit;False;14;Snow_Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-472.5014,-91.10378;Inherit;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;0;False;0;False;0,0.3396226,0.08128886,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-86.98923,351.9937;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-214.0016,12.39626;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;112,12.8;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Rito/Snow Pile;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;6;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;2;0;3;0
WireConnection;2;1;4;0
WireConnection;25;0;23;0
WireConnection;25;1;26;0
WireConnection;9;0;2;0
WireConnection;9;1;10;0
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;11;2;25;0
WireConnection;14;0;11;0
WireConnection;19;0;20;0
WireConnection;19;1;16;0
WireConnection;19;2;13;0
WireConnection;19;3;18;0
WireConnection;6;0;5;0
WireConnection;6;1;21;0
WireConnection;0;0;6;0
WireConnection;0;11;19;0
ASEEND*/
//CHKSM=E5CBBC3F11F8F5B3FE5E682D5E2A2C502BBD6CAF