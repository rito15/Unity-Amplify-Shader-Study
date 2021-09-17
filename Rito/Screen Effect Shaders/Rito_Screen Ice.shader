// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Screen Ice"
{
	Properties
	{
		[HideInInspector]_MainTex("MainTex", 2D) = "white" {}
		_IceTexture("IceTexture", 2D) = "white" {}
		_Range("Range", Range( 0 , 1)) = 0
		_NoiseScale("Noise Scale", Float) = 2
		_PowerA("Power A", Float) = 5
		_PowerB("Power B", Float) = 3
		_Opacity("Opacity", Range( 0 , 2)) = 1
		_Smoothness("Smoothness", Range( 1 , 10)) = 2
		_Distortion("Distortion", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
		Cull Back
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

			uniform sampler2D _MainTex;
			uniform float _NoiseScale;
			uniform float _Smoothness;
			uniform float _Range;
			uniform float _PowerA;
			uniform float _PowerB;
			uniform float _Opacity;
			uniform sampler2D _IceTexture;
			uniform float4 _IceTexture_ST;
			uniform float _Distortion;
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
				float simplePerlin2D21 = snoise( i.ase_texcoord1.xy*_NoiseScale );
				simplePerlin2D21 = simplePerlin2D21*0.5 + 0.5;
				float temp_output_64_0 = ( 2.0 * _Range );
				float RangeB74 = saturate( ( temp_output_64_0 - 1.0 ) );
				float RangeA67 = saturate( temp_output_64_0 );
				float2 temp_cast_0 = (1.0).xx;
				float2 temp_cast_1 = (_PowerA).xx;
				float2 break37 = ( RangeB74 + pow( abs( ( RangeA67 * ( ( i.ase_texcoord1.xy * 2.0 ) - temp_cast_0 ) ) ) , temp_cast_1 ) );
				float RectArea59 = pow( ( break37.x + break37.y ) , _PowerB );
				float smoothstepResult25 = smoothstep( simplePerlin2D21 , _Smoothness , RectArea59);
				float NoisedArea48 = ( smoothstepResult25 * _Opacity );
				float2 temp_cast_2 = (NoisedArea48).xx;
				float2 uv_IceTexture = i.ase_texcoord1.xy * _IceTexture_ST.xy + _IceTexture_ST.zw;
				float4 tex2DNode3 = tex2D( _IceTexture, uv_IceTexture );
				float2 lerpResult58 = lerp( ( i.ase_texcoord1.xy + NoisedArea48 ) , ( i.ase_texcoord1.xy - temp_cast_2 ) , tex2DNode3.rg);
				float2 lerpResult77 = lerp( i.ase_texcoord1.xy , lerpResult58 , _Distortion);
				float4 lerpResult6 = lerp( tex2D( _MainTex, lerpResult77 ) , tex2DNode3 , NoisedArea48);
				
				
				finalColor = lerpResult6;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
4;117;1863;902;2045.374;611.3786;1.9;True;False
Node;AmplifyShaderEditor.CommentaryNode;76;-690.1808,-1189.9;Inherit;False;965.0814;373.192;.;9;65;46;64;67;71;72;66;73;74;Remap Range Property : [0, 0.5] => A [0, 1], [0.5, 1] => B [0, 1];1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-497.479,-1139.9;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-640.1808,-1035.31;Inherit;False;Property;_Range;Range;2;0;Create;True;0;0;0;False;0;False;0;0.3596037;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;61;-689.994,-763.1842;Inherit;False;1895.27;463.9232;.;17;28;32;30;29;31;43;36;35;34;41;37;38;39;59;40;69;75;Rect Area;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-362.479,-1114.9;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;66;-224.479,-1117.9;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-583.994,-543.7743;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;32;-639.994,-664.7744;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;72;-336.6031,-932.7085;Inherit;False;Constant;_Float5;Float 5;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-443.994,-492.7741;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-434.994,-629.7744;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-92.479,-1118.9;Inherit;False;RangeA;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-212.4224,-1006.02;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-290.994,-589.7745;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-256.4098,-689.1024;Inherit;False;67;RangeA;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-69.8699,-666.7815;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;73;-79.26476,-1001.532;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;50.90058,-1007.516;Inherit;False;RangeB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;36;82.32231,-591.6718;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;35;80.01451,-512.6769;Inherit;False;Property;_PowerA;Power A;4;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;34;224.5655,-577.1855;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;203.5083,-655.92;Inherit;False;74;RangeB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;378.9648,-633.2936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;37;501.2538,-629.2618;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;38;622.2536,-630.2618;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;679.4537,-415.2609;Inherit;False;Property;_PowerB;Power B;5;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;62;-676.4566,-226.2803;Inherit;False;1355.801;469.1611;.;9;24;23;21;26;25;56;55;60;48;Noised Area;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;39;833.2537,-629.2618;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-595.2568,-47.13683;Inherit;False;Property;_NoiseScale;Noise Scale;3;0;Create;True;0;0;0;False;0;False;2;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;23;-626.4566,-168.0367;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;981.2754,-633.481;Inherit;True;RectArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-147.8255,-176.2803;Inherit;False;59;RectArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-158.6562,-16.33714;Inherit;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;0;False;0;False;2;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;21;-409.3563,-173.2369;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;25;21.24366,-100.337;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-21.45584,126.8808;Inherit;False;Property;_Opacity;Opacity;6;0;Create;True;0;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;312.9437,-41.11919;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;455.344,-53.71868;Inherit;True;NoisedArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;63;-670.6565,320.4807;Inherit;False;1667.255;557.9193;.;12;51;50;57;52;6;1;3;58;2;49;78;77;Screen Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-616.2563,592.8806;Inherit;False;48;NoisedArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;51;-622.4224,417.6763;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-317.3461,469.3732;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;3;-489.0373,694.889;Inherit;True;Property;_IceTexture;IceTexture;1;0;Create;True;0;0;0;False;0;False;-1;45f0b5e93b68bb74890856d5f5188e22;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-332.7054,573.9034;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-155.6506,628.1866;Inherit;False;Property;_Distortion;Distortion;8;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;58;-151.2384,503.4819;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;77;132.1977,421.5716;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;383.595,765.5567;Inherit;False;48;NoisedArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;284.0695,396.9494;Inherit;True;Property;_MainTex;MainTex;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;6;622.0642,657.548;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;772.3647,659.3481;Float;False;True;-1;2;ASEMaterialInspector;100;1;Rito/Screen Ice;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;64;0;65;0
WireConnection;64;1;46;0
WireConnection;66;0;64;0
WireConnection;29;0;32;0
WireConnection;29;1;28;0
WireConnection;67;0;66;0
WireConnection;71;0;64;0
WireConnection;71;1;72;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;43;0;69;0
WireConnection;43;1;31;0
WireConnection;73;0;71;0
WireConnection;74;0;73;0
WireConnection;36;0;43;0
WireConnection;34;0;36;0
WireConnection;34;1;35;0
WireConnection;41;0;75;0
WireConnection;41;1;34;0
WireConnection;37;0;41;0
WireConnection;38;0;37;0
WireConnection;38;1;37;1
WireConnection;39;0;38;0
WireConnection;39;1;40;0
WireConnection;59;0;39;0
WireConnection;21;0;23;0
WireConnection;21;1;24;0
WireConnection;25;0;60;0
WireConnection;25;1;21;0
WireConnection;25;2;26;0
WireConnection;55;0;25;0
WireConnection;55;1;56;0
WireConnection;48;0;55;0
WireConnection;52;0;51;0
WireConnection;52;1;50;0
WireConnection;57;0;51;0
WireConnection;57;1;50;0
WireConnection;58;0;52;0
WireConnection;58;1;57;0
WireConnection;58;2;3;0
WireConnection;77;0;51;0
WireConnection;77;1;58;0
WireConnection;77;2;78;0
WireConnection;2;1;77;0
WireConnection;6;0;2;0
WireConnection;6;1;3;0
WireConnection;6;2;49;0
WireConnection;1;0;6;0
ASEEND*/
//CHKSM=FA13C338D48B90EEA62A2F60DE6A6F78307575B6