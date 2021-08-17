// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Screen Shake"
{
	Properties
	{
		_ShakeIntensity("Shake Intensity", Range( 0 , 1)) = 0.05
		[Space(12)]_HorizontalShakeSpeed("Horizontal Shake Speed", Range( 0 , 100)) = 40
		_VerticalShakeSpeed("Vertical Shake Speed", Range( 0 , 100)) = 25
		[HideInInspector]_MainTex("MainTex", 2D) = "white" {}

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
			uniform float _ShakeIntensity;
			uniform float _HorizontalShakeSpeed;
			uniform float _VerticalShakeSpeed;

			
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
				float2 _Vector0 = float2(0,1);
				float2 temp_cast_0 = (_Vector0.x).xx;
				float2 temp_cast_1 = (_Vector0.y).xx;
				float temp_output_25_0 = ( _ShakeIntensity * 0.1 );
				float2 temp_cast_2 = (temp_output_25_0).xx;
				float2 temp_cast_3 = (( 1.0 - temp_output_25_0 )).xx;
				float2 appendResult29 = (float2(_HorizontalShakeSpeed , _VerticalShakeSpeed));
				
				
				finalColor = tex2D( _MainTex, ( (temp_cast_2 + (i.ase_texcoord1.xy - temp_cast_0) * (temp_cast_3 - temp_cast_2) / (temp_cast_1 - temp_cast_0)) + ( temp_output_25_0 * sin( ( appendResult29 * _Time.y ) ) ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
538;343;1863;878;2356.178;817.7877;1.6;True;False
Node;AmplifyShaderEditor.RangedFloatNode;21;-1527.733,71.12439;Inherit;False;Property;_VerticalShakeSpeed;Vertical Shake Speed;2;0;Create;True;0;0;0;False;0;False;25;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1528.229,5.825356;Inherit;False;Property;_HorizontalShakeSpeed;Horizontal Shake Speed;1;0;Create;True;0;0;0;False;1;Space(12);False;40;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1298.356,152.4761;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1422.834,-181.345;Inherit;False;Constant;_01;0.1;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1550.827,-262.9521;Inherit;False;Property;_ShakeIntensity;Shake Intensity;0;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;-1258.134,20.50772;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-1115.036,56.28452;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1275.334,-259.645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;15;-1022.3,-202.8001;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;10;-1067.6,-448.4001;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;28;-1020.318,-336.3616;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinOpNode;7;-992.1307,56.44363;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-865.1741,-12.83805;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;18;-804.4002,-330.7001;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;0,0;False;4;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-587.0997,-137.3;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;2;-452.3,-167.2;Inherit;True;Property;_MainTex;MainTex;3;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-168.1001,-162.8;Float;False;True;-1;2;ASEMaterialInspector;100;1;Rito/Screen Shake;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;7;False;-1;True;False;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;29;0;4;0
WireConnection;29;1;21;0
WireConnection;5;0;29;0
WireConnection;5;1;3;0
WireConnection;25;0;11;0
WireConnection;25;1;26;0
WireConnection;15;0;25;0
WireConnection;7;0;5;0
WireConnection;8;0;25;0
WireConnection;8;1;7;0
WireConnection;18;0;10;0
WireConnection;18;1;28;1
WireConnection;18;2;28;2
WireConnection;18;3;25;0
WireConnection;18;4;15;0
WireConnection;19;0;18;0
WireConnection;19;1;8;0
WireConnection;2;1;19;0
WireConnection;0;0;2;0
ASEEND*/
//CHKSM=AEDB796B6BF062EFCEB32C98DF9DEF161482865C