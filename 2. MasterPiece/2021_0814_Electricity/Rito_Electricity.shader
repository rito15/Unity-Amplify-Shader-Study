// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Electricity"
{
	Properties
	{
		[HideInInspector]_Cutoff("Cutoff", Float) = 0.5
		_NormalOffset("Normal Offset", Range( 0 , 0.1)) = 0.01
		[HDR][Space(12)]_Color("Color", Color) = (47.93726,43.67059,0,0)
		_Amplitude("Amplitude", Range( 0 , 10)) = 1
		_Speed("Speed", Range( -10 , 10)) = 2
		_RepeatInterval("Repeat Interval", Float) = 1
		[Space(12)]_NoiseScale("Noise Scale", Float) = 4
		_Width("Width", Range( 0 , 1)) = 0.1
		_Threshold("Threshold", Range( 0 , 1)) = 0.6
		_FlowDirection("Flow Direction", Vector) = (0,0,0,0)
		[Header(Flicker)][Space(6)]_FlickerSpeed("Flicker Speed", Float) = 2
		_FlickerPower("Flicker Power", Float) = 8
		_TimeBegin("Time Begin", Float) = 0
		_TimeEnd("Time End", Float) = 4
		[Header(Area Mask)][Space(6)]_MaskThreshold("Mask Threshold", Range( 0 , 1)) = 0.6
		_MaskNoiseScale("Mask Noise Scale", Float) = 4
		_MaskOffset("Mask Offset", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _NormalOffset;
		uniform float4 _Color;
		uniform float2 _FlowDirection;
		uniform float _NoiseScale;
		uniform float _Amplitude;
		uniform float _Speed;
		uniform float _RepeatInterval;
		uniform float _Threshold;
		uniform float _Width;
		uniform float _TimeBegin;
		uniform float _FlickerSpeed;
		uniform float _TimeEnd;
		uniform float _FlickerPower;
		uniform float _MaskThreshold;
		uniform float2 _MaskOffset;
		uniform float _MaskNoiseScale;
		uniform float _Cutoff;


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ase_vertexNormal * _NormalOffset );
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float simplePerlin2D1 = snoise( ( _FlowDirection + i.uv_texcoord )*( _NoiseScale + ( _Amplitude * fmod( ( _Speed * _Time.y ) , _RepeatInterval ) ) ) );
			simplePerlin2D1 = simplePerlin2D1*0.5 + 0.5;
			float Electricity46 = ( step( simplePerlin2D1 , _Threshold ) - step( simplePerlin2D1 , ( _Threshold - ( _Width * 0.1 ) ) ) );
			o.Emission = ( _Color * Electricity46 ).rgb;
			o.Alpha = 1;
			float Flickering_Time49 = saturate( sin( pow( fmod( ( ( _Time.y + _TimeBegin ) * _FlickerSpeed ) , _TimeEnd ) , _FlickerPower ) ) );
			float simplePerlin2D40 = snoise( ( i.uv_texcoord + _MaskOffset )*_MaskNoiseScale );
			simplePerlin2D40 = simplePerlin2D40*0.5 + 0.5;
			float Area_Mask53 = step( _MaskThreshold , simplePerlin2D40 );
			clip( ( ( Electricity46 * Flickering_Time49 ) * Area_Mask53 ) - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
31;117;1863;902;3751.313;1953.563;3.805576;False;False
Node;AmplifyShaderEditor.CommentaryNode;47;-2159.346,-484.769;Inherit;False;1863.099;704.5038;.;22;5;9;65;66;7;75;13;76;11;58;46;10;6;4;1;61;14;2;60;3;12;59;Electricity Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2133.637,-25.62394;Inherit;False;Property;_Speed;Speed;4;0;Create;True;0;0;0;False;0;False;2;4;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-2158.514,295.1718;Inherit;False;1855.825;468.0071;.;12;49;21;16;19;17;20;18;23;24;26;15;25;Flickering Time;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;11;-2026.583,55.62761;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1888.572,128.0756;Inherit;False;Property;_RepeatInterval;Repeat Interval;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2093.894,433.2496;Inherit;False;Property;_TimeBegin;Time Begin;12;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;15;-2108.513,345.1718;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1848.55,14.80614;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;75;-1704.562,52.41214;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-1904.823,383.6623;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1854.045,-102.6749;Inherit;False;Property;_Amplitude;Amplitude;3;0;Create;True;0;0;0;False;0;False;1;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1943.256,491.688;Inherit;False;Property;_FlickerSpeed;Flicker Speed;10;1;[Header];Create;True;1;Flicker;0;0;False;1;Space(6);False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1751.741,534.2996;Inherit;False;Property;_TimeEnd;Time End;13;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1556.865,32.9704;Inherit;False;Property;_Width;Width;7;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;12;-1841.849,-423.2708;Inherit;False;Property;_FlowDirection;Flow Direction;9;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;66;-1432.266,110.4456;Inherit;False;Constant;_01;0.1;15;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1576.528,-81.46397;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1740.368,416.7331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1606.743,-188.9227;Inherit;False;Property;_NoiseScale;Noise Scale;6;0;Create;True;0;0;0;False;1;Space(12);False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;2;-1863.278,-289.9857;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-1600.93,601.4502;Inherit;False;Property;_FlickerPower;Flicker Power;11;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1400.991,-49.17768;Inherit;False;Property;_Threshold;Threshold;8;0;Create;True;0;0;0;False;0;False;0.6;0.5882353;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;17;-1557.962,449.0921;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1589.806,-371.6738;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1444.283,-169.6069;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1269.152,46.66595;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;52;-250.4806,-464.4599;Inherit;False;1067.539;404.1082;.;8;53;42;40;43;45;41;62;63;Area Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-1288.301,-299.6415;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;62;-195.6762,-290.1244;Inherit;False;Property;_MaskOffset;Mask Offset;16;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-1110.9,-5.018301;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;19;-1422.948,525.0811;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;45;-220.4894,-411.554;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-3.535488,-335.1586;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-220.3966,-157.1112;Inherit;False;Property;_MaskNoiseScale;Mask Noise Scale;15;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;6;-961.3693,-70.67453;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;16;-1257.273,524.4839;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;4;-962.3693,-295.8911;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;40;130.6469,-299.1662;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-718.9492,-226.1403;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;122.7922,-398.5322;Inherit;False;Property;_MaskThreshold;Mask Threshold;14;1;[Header];Create;True;1;Area Mask;0;0;False;1;Space(6);False;0.6;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;21;-1110.932,524.081;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;42;409.3165,-330.4922;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;55;-249.7261,11.18435;Inherit;False;1073.803;739.456;.;12;79;78;80;54;44;51;22;0;28;64;27;50;Final;0.5424528,1,0.9339703,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-924.9071,519.5846;Inherit;False;Flickering_Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-512.6511,-226.7025;Inherit;False;Electricity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-164.1842,248.5662;Inherit;False;46;Electricity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-195.7803,329.8417;Inherit;False;49;Flickering_Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;614.6227,-334.9423;Inherit;False;Area_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;176.185,670.7155;Inherit;False;Property;_NormalOffset;Normal Offset;1;0;Create;True;0;0;0;False;0;False;0.01;0.01;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;78;272.8295,531.8996;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;54;102.7304,465.2363;Inherit;False;53;Area_Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;62.38666,251.9573;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;-197.9689,61.18435;Inherit;False;Property;_Color;Color;2;1;[HDR];Create;True;0;0;0;False;1;Space(12);False;47.93726,43.67059,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;65.43266,161.9247;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;64;654.6694,547.7905;Inherit;False;Property;_Cutoff;Cutoff;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StickyNoteNode;56;-2155.612,855.2274;Inherit;False;2971.645;100;.;NOTE : Noise Generator 노드는 모두 노이즈 텍스쳐로 대체하여 사용;0,0,0,1;;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;305.9193,298.8296;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;455.5756,531.8999;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;591.7473,106.1864;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Rito/Electricity;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;False;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;64;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;58;0
WireConnection;13;1;11;0
WireConnection;75;0;13;0
WireConnection;75;1;76;0
WireConnection;26;0;15;0
WireConnection;26;1;25;0
WireConnection;60;0;59;0
WireConnection;60;1;75;0
WireConnection;23;0;26;0
WireConnection;23;1;24;0
WireConnection;17;0;23;0
WireConnection;17;1;18;0
WireConnection;61;0;12;0
WireConnection;61;1;2;0
WireConnection;14;0;3;0
WireConnection;14;1;60;0
WireConnection;65;0;7;0
WireConnection;65;1;66;0
WireConnection;1;0;61;0
WireConnection;1;1;14;0
WireConnection;9;0;5;0
WireConnection;9;1;65;0
WireConnection;19;0;17;0
WireConnection;19;1;20;0
WireConnection;63;0;45;0
WireConnection;63;1;62;0
WireConnection;6;0;1;0
WireConnection;6;1;9;0
WireConnection;16;0;19;0
WireConnection;4;0;1;0
WireConnection;4;1;5;0
WireConnection;40;0;63;0
WireConnection;40;1;41;0
WireConnection;10;0;4;0
WireConnection;10;1;6;0
WireConnection;21;0;16;0
WireConnection;42;0;43;0
WireConnection;42;1;40;0
WireConnection;49;0;21;0
WireConnection;46;0;10;0
WireConnection;53;0;42;0
WireConnection;22;0;50;0
WireConnection;22;1;51;0
WireConnection;28;0;27;0
WireConnection;28;1;50;0
WireConnection;44;0;22;0
WireConnection;44;1;54;0
WireConnection;80;0;78;0
WireConnection;80;1;79;0
WireConnection;0;2;28;0
WireConnection;0;10;44;0
WireConnection;0;11;80;0
ASEEND*/
//CHKSM=47F3895BF1E961CAD393A0D672D5254CB6267074