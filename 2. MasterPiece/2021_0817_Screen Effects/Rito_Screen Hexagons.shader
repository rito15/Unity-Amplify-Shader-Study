// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Screen Hexagons"
{
	Properties
	{
		
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest Always
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

					float2 voronoihash3( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi3( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash3( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.707 * sqrt(dot( r, r ));
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return (F2 + F1) * 0.5;
					}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float time3 = 2.0;
				float2 Hexagon_Input_TileLength5_g6 = float2( 2,1 );
				float2 Hexagon_Input_Tiling2_g6 = float2( 12,12 );
				float2 texCoord4_g6 = i.ase_texcoord1.xy * Hexagon_Input_Tiling2_g6 + float2( 0,0 );
				float2 break74_g6 = ( Hexagon_Input_TileLength5_g6 * texCoord4_g6 );
				float temp_output_10_0_g6 = fmod( floor( break74_g6.x ) , 2.0 );
				float2 appendResult13_g6 = (float2(break74_g6.x , ( break74_g6.y + ( temp_output_10_0_g6 * 0.5 ) )));
				float2 Hexagon_Temp_0239_g6 = floor( appendResult13_g6 );
				float2 temp_cast_0 = (1.0).xx;
				float2 temp_cast_1 = (0.5).xx;
				float2 temp_output_17_0_g6 = ( fmod( appendResult13_g6 , temp_cast_0 ) - temp_cast_1 );
				float2 Hexagon_Temp_0461_g6 = abs( temp_output_17_0_g6 );
				float2 break23_g6 = Hexagon_Temp_0461_g6;
				float2 temp_cast_2 = (0.5).xx;
				float2 Hexagon_Temp_0318_g6 = temp_output_17_0_g6;
				float2 break24_g6 = sign( Hexagon_Temp_0318_g6 );
				float2 appendResult35_g6 = (float2(break24_g6.x , step( 0.0 , break24_g6.y )));
				float2 appendResult33_g6 = (float2(break24_g6.x , -step( break24_g6.y , 0.0 )));
				float Hexagon_Temp_0128_g6 = temp_output_10_0_g6;
				float2 lerpResult38_g6 = lerp( appendResult35_g6 , appendResult33_g6 , Hexagon_Temp_0128_g6);
				float2 coords3 = ( ( Hexagon_Temp_0239_g6 + ( ( 1.0 - step( ( break23_g6.y + ( break23_g6.x * 1.5 ) ) , 1.0 ) ) * lerpResult38_g6 ) ) / Hexagon_Input_Tiling2_g6 ) * 101.0;
				float2 id3 = 0;
				float2 uv3 = 0;
				float voroi3 = voronoi3( coords3, time3, id3, uv3, 0 );
				float4 temp_cast_3 = (voroi3).xxxx;
				
				
				finalColor = temp_cast_3;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
340;266;1863;872;1434.815;-168.4075;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;5;-760.7326,724.3522;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;101;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-751.6326,634.6523;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;81;-1040.948,402.0494;Inherit;True;Hex Lattice_Custom;-1;;6;8906ba221ed370147b31413079050c73;0;4;66;FLOAT2;12,12;False;65;FLOAT2;2,1;False;63;FLOAT2;0.1,0.2;False;69;FLOAT;1;False;2;FLOAT;67;FLOAT2;68
Node;AmplifyShaderEditor.SamplerNode;1;-323.8278,306.9945;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;3;-571.6959,461.7523;Inherit;True;0;1;1;3;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-5.327779,326.9945;Float;False;True;-1;2;ASEMaterialInspector;100;1;Rito/Screen Hexagons;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;3;0;81;68
WireConnection;3;1;4;0
WireConnection;3;2;5;0
WireConnection;0;0;3;0
ASEEND*/
//CHKSM=AB305F39DB8CE50678D9619C75B5A0A35BDCA098