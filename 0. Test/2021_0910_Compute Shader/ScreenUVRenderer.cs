using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 날짜 : 2021-09-10 AM 2:23:08
// 작성자 : Rito

/// <summary> 
/// 
/// </summary>
public class ScreenUVRenderer : MonoBehaviour
{
    // 컴퓨트 쉐이더 객체를 인스펙터에서 할당한다.
    public ComputeShader computeShader;
    private RenderTexture _renderTarget;

    // 매프레임 화면의 렌더가 끝나면 호출된다.
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Render(destination);
    }

    private void Render(RenderTexture destination)
    {
        // 렌더 텍스쳐의 초기화를 확인한다.
        InitRenderTexture();

        // 렌더 텍스쳐를 컴퓨트 쉐이더의 result 변수에 입출력 텍스쳐로 할당한다.
        computeShader.SetTexture(0, "result", _renderTarget);

        // 2차원 X, Y 스레드 그룹의 개수를 계산하여 컴퓨트 쉐이더를 실행한다.
        // 각 차원마다 (스레드 그룹 개수 * 스레드 그룹당 스레드 개수)는 해당 차원의 스크린 픽셀 개수이다.
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        computeShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);

        // 결과 텍스쳐를 화면에 출력한다.
        Graphics.Blit(_renderTarget, destination);
    }

    private void InitRenderTexture()
    {
        if (_renderTarget == null || _renderTarget.width != Screen.width || _renderTarget.height != Screen.height)
        {
            // 크기가 다른 렌더 텍스쳐가 이미 존재하고 있었다면 메모리에서 해제한다.
            if (_renderTarget != null)
                _renderTarget.Release();

            // 알맞은 설정의 렌더 텍스쳐를 생성한다.
            // RenderTextureReadWrite는 Linear로 설정하고,
            // 입출력 텍스쳐로 사용하기 위해 enableRandomWrite는 true로 설정해야 한다.

            _renderTarget = new RenderTexture(Screen.width, Screen.height, 0,
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            _renderTarget.enableRandomWrite = true;
            _renderTarget.Create();
        }
    }
}