// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Screen Hexagons"
{
	Properties
	{
		[HideInInspector]_MainTex("MainTex", 2D) = "white" {}
		[HDR]_Color("Color", Color) = (0.1764706,0.4913095,1,0)
		_Distortion("Distortion", Float) = -1
		[Space(10)]_AreaRange("Area Range", Range( 0 , 1)) = 0.15
		_AreaPower("Area Power", Range( 1 , 10)) = 2
		[Space(10)]_CircleNoiseScale("Circle Noise Scale", Float) = 3
		_CircleSpreadSpeed("Circle Spread Speed", Range( 0 , 1)) = 0.2
		_PatternSpeed("Pattern Speed", Range( 0 , 10)) = 2
		[Space(10)]_PatternBorderOpacity("Pattern Border Opacity", Range( 0 , 100)) = 20
		_PatternColorOpacity("Pattern Color Opacity", Range( 0 , 100)) = 15
		_PatternAreaRange("Pattern Area Range", Range( 0 , 1)) = 0.1

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
			#include "UnityShaderVariables.cginc"


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

			uniform sampler2D _MainTex;
			uniform float _Distortion;
			uniform float _CircleSpreadSpeed;
			uniform float _CircleNoiseScale;
			uniform float _PatternSpeed;
			uniform float _AreaRange;
			uniform float _AreaPower;
			uniform float _PatternBorderOpacity;
			uniform float _PatternColorOpacity;
			uniform float4 _Color;
			uniform float _PatternAreaRange;
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
				float2 CenteredUV15_g7 = ( i.ase_texcoord1.xy - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float simplePerlin2D185 = snoise( ( appendResult23_g7 + -( _Time.y * _CircleSpreadSpeed ) )*_CircleNoiseScale );
				simplePerlin2D185 = simplePerlin2D185*0.5 + 0.5;
				float Circular_Noise149 = simplePerlin2D185;
				float2 Hexagon_Input_EdgeWidth55_g6 = float2( 0.1,0.2 );
				float2 break57_g6 = Hexagon_Input_EdgeWidth55_g6;
				float2 Hexagon_Input_TileLength5_g6 = float2( 2,1 );
				float2 Hexagon_Input_Tiling2_g6 = float2( 12,12 );
				float2 texCoord4_g6 = i.ase_texcoord1.xy * Hexagon_Input_Tiling2_g6 + float2( 0,0 );
				float2 break74_g6 = ( Hexagon_Input_TileLength5_g6 * texCoord4_g6 );
				float temp_output_10_0_g6 = fmod( floor( break74_g6.x ) , 2.0 );
				float2 appendResult13_g6 = (float2(break74_g6.x , ( break74_g6.y + ( temp_output_10_0_g6 * 0.5 ) )));
				float2 temp_cast_0 = (1.0).xx;
				float2 temp_cast_1 = (0.5).xx;
				float2 temp_output_17_0_g6 = ( fmod( appendResult13_g6 , temp_cast_0 ) - temp_cast_1 );
				float2 Hexagon_Temp_0461_g6 = abs( temp_output_17_0_g6 );
				float2 break23_g6 = Hexagon_Temp_0461_g6;
				float Hexagon_Input_HexScale70_g6 = 1.0;
				float smoothstepResult48_g6 = smoothstep( break57_g6.x , break57_g6.y , abs( ( max( ( ( 1.5 * break23_g6.x ) + break23_g6.y ) , ( break23_g6.y * 2.0 ) ) - Hexagon_Input_HexScale70_g6 ) ));
				float temp_output_117_0 = saturate( ( 1.0 - smoothstepResult48_g6 ) );
				float Hex_Pattern_Border118 = temp_output_117_0;
				float time3 = ( _Time.y * _PatternSpeed );
				float2 Hexagon_Temp_0239_g6 = floor( appendResult13_g6 );
				float2 temp_cast_2 = (0.5).xx;
				float2 Hexagon_Temp_0318_g6 = temp_output_17_0_g6;
				float2 break24_g6 = sign( Hexagon_Temp_0318_g6 );
				float2 appendResult35_g6 = (float2(break24_g6.x , step( 0.0 , break24_g6.y )));
				float2 appendResult33_g6 = (float2(break24_g6.x , -step( break24_g6.y , 0.0 )));
				float Hexagon_Temp_0128_g6 = temp_output_10_0_g6;
				float2 lerpResult38_g6 = lerp( appendResult35_g6 , appendResult33_g6 , Hexagon_Temp_0128_g6);
				float2 coords3 = ( ( Hexagon_Temp_0239_g6 + ( ( 1.0 - step( ( break23_g6.y + ( break23_g6.x * 1.5 ) ) , 1.0 ) ) * lerpResult38_g6 ) ) / Hexagon_Input_Tiling2_g6 ) * 244.0;
				float2 id3 = 0;
				float2 uv3 = 0;
				float voroi3 = voronoi3( coords3, time3, id3, uv3, 0 );
				float Hex_Pattern_Body91 = ( ( 1.0 - temp_output_117_0 ) * voroi3 * 0.1 );
				float2 temp_cast_3 = (0.5).xx;
				float CircleArea108 = min( pow( saturate( ( length( ( ( i.ase_texcoord1.xy - temp_cast_3 ) * 2.0 ) ) + ( ( _AreaRange - 0.5 ) * 2.0 ) ) ) , _AreaPower ) , 1.0 );
				float Combined_HexPattern163 = ( ( ( Circular_Noise149 * Hex_Pattern_Border118 ) + Hex_Pattern_Body91 ) * CircleArea108 );
				float2 temp_cast_4 = (( Hex_Pattern_Body91 * CircleArea108 )).xx;
				float4 MainColor193 = tex2D( _MainTex, ( ( i.ase_texcoord1.xy + ( _Distortion * Combined_HexPattern163 ) ) - temp_cast_4 ) );
				float4 Final_Pattern_Color197 = saturate( ( ( ( Combined_HexPattern163 * _PatternBorderOpacity ) + ( Hex_Pattern_Body91 * _PatternColorOpacity ) ) * _Color * min( ( CircleArea108 * _PatternAreaRange * 50.0 ) , 1.0 ) ) );
				
				
				finalColor = ( MainColor193 + Final_Pattern_Color197 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
560;467;1863;860;3301.628;399.107;1.6;True;False
Node;AmplifyShaderEditor.CommentaryNode;115;-2826.39,-432.6539;Inherit;False;1479.461;613.241;.;18;96;94;102;95;97;99;101;106;105;110;112;113;114;107;104;108;206;207;Circle Area;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;150;-2824.349,257.0268;Inherit;False;1476.339;416.8929;.;10;196;124;123;122;185;130;119;147;149;209;Circular Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2733.012,-268.3203;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;94;-2776.39,-382.6539;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;95;-2578.013,-332.3203;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-2633.976,8.587259;Inherit;False;Constant;_Float8;Float 8;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2761.616,-75.03628;Inherit;False;Property;_AreaRange;Area Range;3;0;Create;True;0;0;0;False;1;Space(10);False;0.15;0.3036928;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;93;-1310.25,-434.4702;Inherit;False;1254.12;606.8474;.;13;118;117;116;91;86;3;87;90;89;81;88;205;212;Hex Patterns;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2721.012,-196.3202;Inherit;False;Constant;_Float6;Float 6;2;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;122;-2677.248,517.3129;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-2777.761,584.0502;Inherit;False;Property;_CircleSpreadSpeed;Circle Spread Speed;6;0;Create;True;0;0;0;False;0;False;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-2498.154,544.0328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;-2483.976,-38.41273;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-2433.013,-283.3203;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;81;-1272.533,-359.8652;Inherit;True;Hex Lattice_Custom;-1;;6;8906ba221ed370147b31413079050c73;0;4;66;FLOAT2;12,12;False;65;FLOAT2;2,1;False;63;FLOAT2;0.1,0.2;False;69;FLOAT;1;False;2;FLOAT;67;FLOAT2;68
Node;AmplifyShaderEditor.TexCoordVertexDataNode;147;-2741.232,306.5575;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;114;-2482.976,64.58728;Inherit;False;Constant;_Float10;Float 10;4;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1279.46,-32.50896;Inherit;False;Property;_PatternSpeed;Pattern Speed;7;0;Create;True;0;0;0;False;0;False;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;-2527.975,304.9569;Inherit;True;Polar Coordinates;-1;;7;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;116;-919.4008,-358.3118;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;88;-1173.081,-103.5811;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-2350.976,-13.41273;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;99;-2314.013,-280.3203;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;196;-2354.479,551.7171;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-1007.136,-102.2609;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;104;-2164.089,-197.6498;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-997.7468,14.49374;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;244;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-2175.344,541.7212;Inherit;False;Property;_CircleNoiseScale;Circle Noise Scale;5;0;Create;True;0;0;0;False;1;Space(10);False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;117;-770.3219,-358.3118;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;130;-2145.279,420.8768;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;185;-1967.48,416.3432;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;205;-602.984,-209.1908;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-2168.073,-96.6055;Inherit;False;Property;_AreaPower;Area Power;4;0;Create;True;0;0;0;False;0;False;2;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;3;-776.0806,-128.2179;Inherit;True;0;1;1;3;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;212;-586.6738,-55.33734;Inherit;False;Constant;_Float12;Float 12;11;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;101;-2048.772,-195.5377;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-438.8842,-142.8064;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;149;-1730.548,414.5221;Inherit;True;Circular_Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;164;-1306.99,247.9285;Inherit;False;1248.229;428.1823;.;8;161;156;157;152;151;163;159;153;Combined Pattern;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;106;-1896.437,-179.781;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-1875.352,-32.49251;Inherit;False;Constant;_Float11;Float 11;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-300.6662,-356.8614;Inherit;True;Hex_Pattern_Border;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;206;-1728.692,-119.8109;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-287.2751,-137.176;Inherit;True;Hex_Pattern_Body;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-1274.462,404.1735;Inherit;False;118;Hex_Pattern_Border;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-1245.109,320.4126;Inherit;False;149;Circular_Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-1247.607,521.7084;Inherit;False;91;Hex_Pattern_Body;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-1574.13,-218.9946;Inherit;True;CircleArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-1031.947,321.7136;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;-736.678,593.86;Inherit;False;108;CircleArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-772.7382,370.8531;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-508.1743,451.1779;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;192;-1300.594,760.0872;Inherit;False;1246.427;508.3506;.;11;193;1;84;162;158;109;83;92;165;85;211;Main Color(Screen);1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;195;-2814.46,761.6707;Inherit;False;1458.585;754.1934;.;17;197;184;168;170;191;189;190;187;188;175;179;177;178;174;167;173;171;Final Pattern Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-368.8784,445.2149;Inherit;True;Combined_HexPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1202.874,939.1006;Inherit;False;Property;_Distortion;Distortion;2;0;Create;True;0;0;0;False;0;False;-1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-2751.067,881.1478;Inherit;False;Property;_PatternBorderOpacity;Pattern Border Opacity;8;0;Create;True;0;0;0;False;1;Space(10);False;20;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-2718.302,811.6708;Inherit;False;163;Combined_HexPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-1288.853,1007.634;Inherit;False;163;Combined_HexPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-2764.46,1260.814;Inherit;False;Property;_PatternAreaRange;Pattern Area Range;10;0;Create;True;0;0;0;False;0;False;0.1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-2659.497,1184.707;Inherit;False;108;CircleArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-2638.182,1337.459;Inherit;False;Constant;_Float15;Float 15;10;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-2750.541,1068.523;Inherit;False;Property;_PatternColorOpacity;Pattern Color Opacity;9;0;Create;True;0;0;0;False;0;False;15;25;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-2689.296,998.371;Inherit;False;91;Hex_Pattern_Body;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;83;-1246.146,824.6363;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-2468.662,1212.668;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-2466.243,1334.955;Inherit;False;Constant;_Float14;Float 14;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;-1048.254,945.455;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-2473.565,831.5002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-2469.984,1021.972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1261.211,1099.736;Inherit;False;91;Hex_Pattern_Body;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-1221.86,1167.885;Inherit;False;108;CircleArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;173;-2264.243,903.3986;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-1023.646,1107.481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;-901.8576,895.0956;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;170;-2293.954,1044.754;Inherit;False;Property;_Color;Color;1;1;[HDR];Create;True;0;0;0;False;0;False;0.1764706,0.4913095,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;189;-2322.766,1257.491;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-2064.199,1017.488;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-758.8301,936.7186;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-540.6869,911.3432;Inherit;True;Property;_MainTex;MainTex;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;184;-1934.064,1017.961;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-1776.19,1009.64;Inherit;True;Final_Pattern_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;193;-239.0504,917.3819;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;199;-714.1506,1325.974;Inherit;False;654.2755;244.0608;Comment;4;198;172;194;0;Main Node;0,1,0.1551092,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-622.6334,1375.974;Inherit;False;193;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-664.1508,1454.035;Inherit;False;197;Final_Pattern_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;-423.2334,1394.674;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-285.8752,1393.195;Float;False;True;-1;2;ASEMaterialInspector;100;1;Rito/Screen Hexagons;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;95;0;94;0
WireConnection;95;1;96;0
WireConnection;124;0;122;0
WireConnection;124;1;123;0
WireConnection;112;0;105;0
WireConnection;112;1;110;0
WireConnection;97;0;95;0
WireConnection;97;1;102;0
WireConnection;119;1;147;0
WireConnection;116;0;81;67
WireConnection;113;0;112;0
WireConnection;113;1;114;0
WireConnection;99;0;97;0
WireConnection;196;0;124;0
WireConnection;90;0;88;0
WireConnection;90;1;89;0
WireConnection;104;0;99;0
WireConnection;104;1;113;0
WireConnection;117;0;116;0
WireConnection;130;0;119;0
WireConnection;130;1;196;0
WireConnection;185;0;130;0
WireConnection;185;1;209;0
WireConnection;205;0;117;0
WireConnection;3;0;81;68
WireConnection;3;1;90;0
WireConnection;3;2;87;0
WireConnection;101;0;104;0
WireConnection;86;0;205;0
WireConnection;86;1;3;0
WireConnection;86;2;212;0
WireConnection;149;0;185;0
WireConnection;106;0;101;0
WireConnection;106;1;107;0
WireConnection;118;0;117;0
WireConnection;206;0;106;0
WireConnection;206;1;207;0
WireConnection;91;0;86;0
WireConnection;108;0;206;0
WireConnection;153;0;152;0
WireConnection;153;1;151;0
WireConnection;156;0;153;0
WireConnection;156;1;157;0
WireConnection;159;0;156;0
WireConnection;159;1;161;0
WireConnection;163;0;159;0
WireConnection;187;0;175;0
WireConnection;187;1;188;0
WireConnection;187;2;191;0
WireConnection;211;0;85;0
WireConnection;211;1;165;0
WireConnection;179;0;167;0
WireConnection;179;1;171;0
WireConnection;177;0;174;0
WireConnection;177;1;178;0
WireConnection;173;0;179;0
WireConnection;173;1;177;0
WireConnection;162;0;92;0
WireConnection;162;1;109;0
WireConnection;158;0;83;0
WireConnection;158;1;211;0
WireConnection;189;0;187;0
WireConnection;189;1;190;0
WireConnection;168;0;173;0
WireConnection;168;1;170;0
WireConnection;168;2;189;0
WireConnection;84;0;158;0
WireConnection;84;1;162;0
WireConnection;1;1;84;0
WireConnection;184;0;168;0
WireConnection;197;0;184;0
WireConnection;193;0;1;0
WireConnection;172;0;194;0
WireConnection;172;1;198;0
WireConnection;0;0;172;0
ASEEND*/
//CHKSM=EB3A547325BAA4CB6916789AD4DAD46B9200CCEC