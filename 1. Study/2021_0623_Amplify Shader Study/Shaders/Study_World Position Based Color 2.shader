// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Study/World Position Based Color 2"
{
	Properties
	{
		_Distribution("Distribution", Range( 0.01 , 1)) = 0.1
		_Seed("Seed", Vector) = (12.34,23.45,34.56,0)
		_ColorA("Color A", Color) = (1,0,0,0)
		_ColorB("Color B", Color) = (0,0,1,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half filler;
		};

		uniform float4 _ColorA;
		uniform float4 _ColorB;
		uniform float3 _Seed;
		uniform float _Distribution;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 transform5 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 break14 = ( float4( _Seed , 0.0 ) * transform5 );
			float4 lerpResult18 = lerp( _ColorA , _ColorB , frac( ( ( break14.x + break14.y + break14.z ) * _Distribution ) ));
			o.Albedo = lerpResult18.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
593;219;1309;869;1075.115;144.679;1;False;False
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;5;-994.9958,315.4068;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;11;-1035.985,170.127;Inherit;False;Property;_Seed;Seed;1;0;Create;True;0;0;0;False;0;False;12.34,23.45,34.56;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-805.0838,231.927;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;14;-681.584,233.2269;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-564.7432,234.5831;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-708.8846,377.5264;Inherit;False;Property;_Distribution;Distribution;0;0;Create;True;0;0;0;False;0;False;0.1;0.01;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-428.0822,276.1264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-372.7995,-79.99996;Inherit;False;Property;_ColorA;Color A;2;0;Create;True;0;0;0;False;0;False;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;17;-372.7995,96.00002;Inherit;False;Property;_ColorB;Color B;3;0;Create;True;0;0;0;False;0;False;0,0,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;7;-296.4809,275.7269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;-148.7997,6.127357E-05;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Study/World Position Based Color 2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;11;0
WireConnection;12;1;5;0
WireConnection;14;0;12;0
WireConnection;6;0;14;0
WireConnection;6;1;14;1
WireConnection;6;2;14;2
WireConnection;9;0;6;0
WireConnection;9;1;10;0
WireConnection;7;0;9;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;18;2;7;0
WireConnection;0;0;18;0
ASEEND*/
//CHKSM=2DAD93BEF3553076E284E4DDE29B023F1A99A4AA