﻿// https://www.patreon.com/posts/rendertexture-15961186
// https://pastebin.com/rMx1PVXi

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary> 마우스 드래그로 텍스쳐에 그림 그리기 </summary>
public class TexturePaintBrush : MonoBehaviour
{
    /***********************************************************************
    *                               Public Fields
    ***********************************************************************/
    #region .

    public int resolution = 512;
    [Range(0.01f, 1f)] public float brushSize = 0.1f;
    public Texture2D brushTexture;
    public Color brushColor = Color.white;

    #endregion
    /***********************************************************************
    *                               Private Fields
    ***********************************************************************/
    #region .

    private Texture2D CopiedBrushTexture; // 실시간으로 색상 칠하는데 사용되는 브러시 텍스쳐 카피본
    private Texture2D clearTex;
    private Vector2 sameUvPoint; // 직전 프레임에 마우스가 위치한 대상 UV 지점 (동일 위치에 중첩해서 그리는 현상 방지)

    private static readonly string PaintTexProperty = "_PaintTex";
    private readonly Dictionary<Collider, RenderTexture> targetDict
        = new Dictionary<Collider, RenderTexture>();


    #endregion

    /***********************************************************************
    *                               Unity Events
    ***********************************************************************/
    #region .
    void Start()
    {
        CreateClearTexture();

        // 등록한 브러시 텍스쳐가 없을 경우, 원 모양의 텍스쳐 생성
        if (brushTexture == null)
        {
            CreateDefaultBrushTexture();
        }

        CopyBrushTexture();
    }

    void Update()
    {
        if (Input.GetMouseButton(0) == false) return;

        if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out var hit)) // delete previous and uncomment for mouse painting
        {
            Collider coll = hit.collider;
            if (coll != null)
            {
#if UNITY_EDITOR
                // 색상 변경을 감지한 경우, Brush Texture 복제
                if (brushColorChangedFlag)
                {
                    CopyBrushTexture();
                    brushColorChangedFlag = false;
                }
#endif

                // 대상 콜라이더를 처음 감지한 경우, 딕셔너리에 등록
                if (!targetDict.ContainsKey(coll))
                {
                    Renderer rend = hit.transform.GetComponent<Renderer>();
                    targetDict.Add(coll, GetClearRT());
                    rend.material.SetTexture(PaintTexProperty, targetDict[coll]);
                }

                // 동일한 지점에는 중첩하여 다시 그리지 않음
                if (sameUvPoint != hit.lightmapCoord)
                {
                    sameUvPoint = hit.lightmapCoord;
                    Vector2 pixelUV = hit.lightmapCoord;
                    pixelUV.y *= resolution;
                    pixelUV.x *= resolution;
                    DrawTexture(targetDict[coll], pixelUV.x, pixelUV.y);
                }
            }
        }
    }
    #endregion
    /***********************************************************************
    *                               Public Methods
    ***********************************************************************/
    #region .
    /// <summary> 브러시 색상 변경 </summary>
    public void SetBrushColor(in Color color)
    {
        brushColor = color;
        CopyBrushTexture();
    }
    
    #endregion
    /***********************************************************************
    *                               Private Methods
    ***********************************************************************/
    #region .
    /// <summary> 텅 빈 텍스쳐 생성 </summary>
    private void CreateClearTexture()
    {
        clearTex = new Texture2D(1, 1);
        clearTex.SetPixel(0, 0, Color.clear);
        clearTex.Apply();
    }

    /// <summary> 기본 형태(원)의 브러시 텍스쳐 생성 </summary>
    private void CreateDefaultBrushTexture()
    {
        ref var res = ref resolution;
        float hRes = res * 0.5f;
        float sqrSize = hRes * hRes;

        brushTexture = new Texture2D(res, res);
        brushTexture.filterMode = FilterMode.Point;
        //brushTexture.alphaIsTransparency = true;

        for (int y = 0; y < res; y++)
        {
            for (int x = 0; x < res; x++)
            {
                // Sqaure Length From Center
                float sqrLen = (hRes - x) * (hRes - x) + (hRes - y) * (hRes - y);
                float alpha = Mathf.Max(sqrSize - sqrLen, 0f) / sqrSize;

                //brushTexture.SetPixel(x, y, (sqrLen < sqrSize ? brushColor : Color.clear));
                brushTexture.SetPixel(x, y, new Color(1f, 1f, 1f, alpha));
            }
        }

        brushTexture.Apply();
    }

    /// <summary> 초기 렌더 텍스쳐 생성 </summary>
    private RenderTexture GetClearRT()
    {
        RenderTexture rt = new RenderTexture(resolution, resolution, 32);
        Graphics.Blit(clearTex, rt);
        return rt;
    }

    /// <summary> 원본 브러시 텍스쳐 -> 실제 브러시 텍스쳐(색상 적용) 복제 </summary>
    private void CopyBrushTexture()
    {
        if (brushTexture == null) return;

        // 기존의 카피 텍스쳐는 메모리 해제
        DestroyImmediate(CopiedBrushTexture);

        // 새롭게 할당
        {
            CopiedBrushTexture = new Texture2D(brushTexture.width, brushTexture.height);
            CopiedBrushTexture.filterMode = FilterMode.Point;
            //CopiedBrushTexture.alphaIsTransparency = true;
        }

        int height = brushTexture.height;
        int width = brushTexture.width;

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                Color c = brushColor;
                c.a *= brushTexture.GetPixel(x, y).a;

                CopiedBrushTexture.SetPixel(x, y, c);
            }
        }

        CopiedBrushTexture.Apply();
    }

    /// <summary> 렌더 텍스쳐에 브러시 텍스쳐로 그리기 </summary>
    void DrawTexture(RenderTexture rt, float posX, float posY)
    {
        RenderTexture.active = rt; // 페인팅을 위해 활성 렌더 텍스쳐 임시 할당
        GL.PushMatrix();           // 매트릭스 저장
        GL.LoadPixelMatrix(0, resolution, resolution, 0);      // 알맞은 크기로 픽셀 매트릭스 설정

        float brushPixelSize = brushSize * resolution;

        // 렌더 텍스쳐에 브러시 텍스쳐를 이용해 그리기
        Graphics.DrawTexture(
            new Rect(
                posX - brushPixelSize * 0.5f,
                (rt.height - posY) - brushPixelSize * 0.5f,
                brushPixelSize,
                brushPixelSize
            ),
            CopiedBrushTexture
        );

        GL.PopMatrix();              // 매트릭스 복구
        RenderTexture.active = null; // 활성 렌더 텍스쳐 해제
    }

    #endregion
    /***********************************************************************
    *                               Editor Only
    ***********************************************************************/
    #region .
#if UNITY_EDITOR
    // 색상 변경 감지하여 변경 플래그 설정
    private Color prevBrushColor;
    private bool brushColorChangedFlag = false;
    private void OnValidate()
    {
        if (Application.isPlaying && prevBrushColor != brushColor)
        {
            brushColorChangedFlag = true;
            prevBrushColor = brushColor;
        }
    }
#endif
    #endregion

}