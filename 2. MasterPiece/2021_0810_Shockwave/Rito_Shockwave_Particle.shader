// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Rito/Shockwave_Particle"
{
	Properties
	{
		_Progress("Progress", Range( 0 , 1)) = 0
		_RingWidth("Ring Width", Range( 0 , 1)) = 0.1
		_RingSmoothness("Ring Smoothness", Range( 0.001 , 1)) = 0.2
		_Intensity("Intensity", Range( 0 , 1)) = 0.3
		_ColorOpacity("Color Opacity", Range( 0 , 1)) = 0.1
		_NoiseScale("Noise Scale", Float) = 2
		_DistortionIntensity("Distortion Intensity", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Unlit alpha:fade keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float4 screenPos;
		};

		uniform float _ColorOpacity;
		uniform float _RingWidth;
		uniform float _Progress;
		uniform float _RingSmoothness;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _DistortionIntensity;
		uniform float _NoiseScale;
		uniform float _Intensity;


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


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float temp_output_59_0 = (-_RingWidth + (_Progress - 0.0) * (1.0 - -_RingWidth) / (1.0 - 0.0));
			float temp_output_29_0 = saturate( ( _RingWidth + temp_output_59_0 ) );
			float temp_output_55_0 = ( ( 1.0 - temp_output_59_0 ) + _RingSmoothness );
			float2 temp_cast_0 = (0.5).xx;
			float UV_CircleBase9 = length( ( ( i.uv_texcoord - temp_cast_0 ) * 2.0 ) );
			float smoothstepResult12 = smoothstep( temp_output_29_0 , ( temp_output_29_0 - temp_output_55_0 ) , UV_CircleBase9);
			float temp_output_31_0 = saturate( temp_output_59_0 );
			float smoothstepResult20 = smoothstep( temp_output_31_0 , ( temp_output_31_0 - temp_output_55_0 ) , UV_CircleBase9);
			float Ring57 = ( smoothstepResult12 - smoothstepResult20 );
			float2 temp_cast_1 = (( _DistortionIntensity * UV_CircleBase9 )).xx;
			float2 uv_TexCoord47 = i.uv_texcoord + temp_cast_1;
			float simplePerlin2D35 = snoise( uv_TexCoord47*_NoiseScale );
			simplePerlin2D35 = simplePerlin2D35*0.5 + 0.5;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor33 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( simplePerlin2D35 * _Intensity * Ring57 * i.vertexColor.a ) + ase_grabScreenPosNorm ).xy);
			float4 FinalColor51 = ( ( _ColorOpacity * Ring57 * i.vertexColor ) + screenColor33 );
			o.Emission = FinalColor51.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
0;177;1863;842;2660.732;103.257;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;10;-2348.893,-852.275;Inherit;False;894.3838;349.286;.;7;3;5;4;8;6;2;9;UV Circle Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-2347.181,-450.8351;Inherit;False;1957.342;573.2464;.;18;57;22;17;31;55;29;14;27;54;59;13;60;20;12;11;18;19;15;Ring;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;3;-2298.893,-802.2747;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-2251.509,-671.9886;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2329.867,-353.8528;Inherit;False;Property;_RingWidth;Ring Width;1;0;Create;True;0;0;0;False;0;False;0.1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2230.32,-240.894;Inherit;False;Property;_Progress;Progress;0;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;60;-2094.766,-166.551;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-2097.51,-737.9887;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2089.511,-618.9887;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;59;-1957.49,-237.2446;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1937.512,-696.9886;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1729.286,-160.0685;Inherit;False;Property;_RingSmoothness;Ring Smoothness;2;0;Create;True;0;0;0;False;0;False;0.2;0;0.001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;2;-1803.694,-693.3748;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;54;-1610.851,-230.8495;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1602.993,-362.8138;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;29;-1448.019,-362.8813;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-1678.511,-697.9886;Inherit;False;UV_CircleBase;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;31;-1447.004,-79.28159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1438.906,-232.4403;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2339.743,169.1382;Inherit;False;1953.688;577.8761;.;18;34;51;44;62;64;49;33;45;61;40;41;35;47;42;66;48;65;68;Grab Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-1253.083,-123.1964;Inherit;False;9;UV_CircleBase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;-1281.104,-397.6423;Inherit;False;9;UV_CircleBase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-1242.659,-297.0103;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-1218.713,-25.15136;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2221.36,381.9238;Inherit;False;9;UV_CircleBase;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2216.975,305.6883;Inherit;False;Property;_DistortionIntensity;Distortion Intensity;6;0;Create;True;0;0;0;False;0;False;2;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;12;-1048.895,-392.585;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;20;-1049.884,-118.6938;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-783.8513,-254.8378;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-2008.198,303.6649;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-588.233,-260.2763;Inherit;False;Ring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1799.665,373.1096;Inherit;False;Property;_NoiseScale;Noise Scale;5;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-1860.033,251.5774;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;68;-1797.964,562.0488;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;61;-1609.866,535.8161;Inherit;False;57;Ring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1707.158,455.6241;Inherit;False;Property;_Intensity;Intensity;3;0;Create;True;0;0;0;False;0;False;0.3;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;35;-1623.095,331.2238;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;34;-1404.137,560.0704;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1405.724,423.042;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1148.55,423.8036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1210.14,227.8085;Inherit;False;Property;_ColorOpacity;Color Opacity;4;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1100.738,305.9763;Inherit;False;57;Ring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;33;-1016.565,420.5413;Inherit;False;Global;_GrabScreen0;Grab Screen 0;5;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-908.5765,250.4634;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-751.8326,402.4985;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-607.0991,398.4766;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-775.9344,-821.9556;Inherit;False;51;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-614.0791,-866.9891;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Rito/Shockwave_Particle;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;60;0;17;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;59;0;13;0
WireConnection;59;3;60;0
WireConnection;6;0;4;0
WireConnection;6;1;8;0
WireConnection;2;0;6;0
WireConnection;54;0;59;0
WireConnection;27;0;17;0
WireConnection;27;1;59;0
WireConnection;29;0;27;0
WireConnection;9;0;2;0
WireConnection;31;0;59;0
WireConnection;55;0;54;0
WireConnection;55;1;14;0
WireConnection;15;0;29;0
WireConnection;15;1;55;0
WireConnection;18;0;31;0
WireConnection;18;1;55;0
WireConnection;12;0;11;0
WireConnection;12;1;29;0
WireConnection;12;2;15;0
WireConnection;20;0;19;0
WireConnection;20;1;31;0
WireConnection;20;2;18;0
WireConnection;22;0;12;0
WireConnection;22;1;20;0
WireConnection;66;0;48;0
WireConnection;66;1;65;0
WireConnection;57;0;22;0
WireConnection;47;1;66;0
WireConnection;35;0;47;0
WireConnection;35;1;42;0
WireConnection;40;0;35;0
WireConnection;40;1;41;0
WireConnection;40;2;61;0
WireConnection;40;3;68;4
WireConnection;45;0;40;0
WireConnection;45;1;34;0
WireConnection;33;0;45;0
WireConnection;62;0;49;0
WireConnection;62;1;64;0
WireConnection;62;2;68;0
WireConnection;44;0;62;0
WireConnection;44;1;33;0
WireConnection;51;0;44;0
WireConnection;0;2;53;0
ASEEND*/
//CHKSM=88B731F50D033A32F0268AD295C2E3AF9DCA0EDC