// https://www.patreon.com/posts/rendertexture-15961186
// https://pastebin.com/rMx1PVXi

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary> 마우스 드래그로 텍스쳐에 그림그리기 </summary>
public class TexturePaintBrush : MonoBehaviour
{
    public int resolution = 512;
    [Range(0.01f, 1f)] public float brushSize = 0.1f;
    public Texture2D brushTexture;
    public Color brushColor = Color.red;

    private readonly Dictionary<Collider, RenderTexture> targetDict 
        = new Dictionary<Collider, RenderTexture>();

    private Texture2D CopiedBrushTexture; // 실시간으로 색상 칠하는데 사용되는 브러시 텍스쳐 카피본
    private Texture2D clearMap;
    private Vector2 stored;
    private static readonly string PaintTexProperty = "_PaintTex";

    void Start()
    {
        CreateClearTexture();// clear white texture to draw on

        if (brushTexture == null)
        {
            ref var res = ref resolution;
            float hRes = res * 0.5f;
            float sqrSize = hRes * hRes;

            brushTexture = new Texture2D(res, res);
            brushTexture.filterMode = FilterMode.Point;
            brushTexture.alphaIsTransparency = true;

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

        CopyBrushTexture();
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
            CopiedBrushTexture.alphaIsTransparency = true;
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

    void Update()
    {
        if (Input.GetMouseButton(0) == false) return;

        if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out var hit)) // delete previous and uncomment for mouse painting
        {
            Collider coll = hit.collider;
            if (coll != null)
            {
                // 색상 변경을 감지한 경우, Brush Texture 복제
                if (brushColorChangedFlag)
                {
                    CopyBrushTexture();
                    brushColorChangedFlag = false;
                }

                // 대상 콜라이더를 처음 감지한 경우, 딕셔너리에 등록
                if (!targetDict.ContainsKey(coll))
                {
                    Renderer rend = hit.transform.GetComponent<Renderer>();
                    targetDict.Add(coll, GetClearRT());
                    rend.material.SetTexture(PaintTexProperty, targetDict[coll]);
                }

                // 동일한 지점에는 다시 그리지 않음
                if (stored != hit.lightmapCoord)
                {
                    stored = hit.lightmapCoord;
                    Vector2 pixelUV = hit.lightmapCoord;
                    pixelUV.y *= resolution;
                    pixelUV.x *= resolution;
                    DrawTexture(targetDict[coll], pixelUV.x, pixelUV.y);
                }
            }
        }
    }

    /// <summary> 렌더 텍스쳐에 그리기 </summary>
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

    RenderTexture GetClearRT()
    {
        RenderTexture rt = new RenderTexture(resolution, resolution, 32);
        Graphics.Blit(clearMap, rt);
        return rt;
    }

    void CreateClearTexture()
    {
        clearMap = new Texture2D(1, 1);
        clearMap.SetPixel(0, 0, Color.clear);
        clearMap.Apply();
    }
}