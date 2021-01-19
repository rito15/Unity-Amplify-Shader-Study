// 설명 : 
Shader "Custom/OutlineObject"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DepthMul("Depth Outline Multiplier", Range(0,4)) = 1
		_DepthPow("Depth Outline Bias", Range(1,4)) = 1
		_NormalMul("Normal Outline Multiplier", Range(0,4)) = 1
		_NormalPow("Normal Outline Bias", Range(1,4)) = 1
		_OutlineLimt("OutlineColorLimit",range(0,1)) = 0.5
		_GrayScalePow("GrayScalePow",float) = 1
		_ToneTex("ToneTex",2D) = "white"{}
		_ToneLimit("ToneLimit",Vector) = (0,0,0,0)
		_ForeCol("ForegroundColor",Color) = (1,1,1,1)
		_BackCol("BackgroundColor",Color) = (0,0,0,1)
	}
		SubShader
		{
			// No culling or depth
			//Cull Off ZWrite Off ZTest Always

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				sampler2D _MainTex;
				sampler2D _CameraDepthNormalsTexture;
				float4 _CameraDepthNormalsTexture_TexelSize;
				float _DepthMul;
				float _DepthPow;
				float _NormalMul;
				float _NormalPow;

				sampler2D _ToneTex;
				float4 _ToneTex_TexelSize;
				float4 _ToneLimit;
				float _GrayScalePow;
				float4 _ForeCol;
				float4 _BackCol;
				float _OutlineLimt;

				void Compare(inout float depthOutline, inout float normalOutline,  float baseDepth, float3 baseNormal, float2 uv, float2 offset)
				{
					//옆픽셀과의 차를 계산하는 함수
					float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);
					float3 neighborNormal;
					float neighborDepth;
					DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
					neighborDepth = neighborDepth * _ProjectionParams.z;

					depthOutline += baseDepth - neighborDepth;

					float3 normalDifference = baseNormal - neighborNormal;
					normalOutline += normalDifference.r + normalDifference.g + normalDifference.b;

				}

				float4 frag(v2f i) : SV_Target
				{
					float4 col = tex2D(_MainTex, i.uv);

					//뎁스를 이용한 외곽선 제작
					float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
					float3 normal;
					float depth;
					DecodeDepthNormal(depthNormal, depth, normal);
					depth = depth * _ProjectionParams.z;

					float depthDifference = 0;
					float normalDifference = 0;

					Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(1, 0));
					Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(0, 1));
					Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(-1, 0));
					Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(0, -1));

					depthDifference = depthDifference * _DepthMul;
					depthDifference = saturate(depthDifference);
					depthDifference = pow(depthDifference, _DepthPow);

					normalDifference = normalDifference * _NormalMul;
					normalDifference = saturate(normalDifference);
					normalDifference = pow(normalDifference, _NormalPow);
					float outlineFinal = saturate(depthDifference + normalDifference);
					//외곽선 제작끝

					//모노톤 제작
					float grayScale = (col.r + col.g + col.b) / 3;
					grayScale = pow(grayScale, _GrayScalePow);
					float4 tone = tex2D(_ToneTex, (i.uv * _ScreenParams.xy * _ToneTex_TexelSize.xy));

					float toneResult = (grayScale > _ToneLimit.x) ? 1 : (grayScale > _ToneLimit.y) ? tone.r : (grayScale > _ToneLimit.z) ? tone.g : (grayScale > _ToneLimit.w) ? tone.b : 0;

					float3 toneFinal;
					toneFinal.rgb = (toneResult * _ForeCol.rgb) + ((1 - toneResult) * _BackCol.rgb);
					//모노톤제작 끝

					//모노톤과 외곽선을 합칩니다.
					float4 final;
					final.rgb = lerp(toneFinal, (grayScale > _OutlineLimt) ? _BackCol : _ForeCol, outlineFinal);
					final.a = 1;

					final = normalDifference;
					return final;
				}
				ENDCG
			}
		}
}
