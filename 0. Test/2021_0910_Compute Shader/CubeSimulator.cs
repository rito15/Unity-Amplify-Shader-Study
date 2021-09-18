using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 날짜 : 2021-09-19 AM 1:59:19
// 작성자 : Rito

// TODO : 버튼 누르면 큐브들 위치, 색상 랜덤 설정

/// <summary> 
/// 큐브 위치, 색상 시뮬레이션
/// </summary>
public class CubeSimulator : MonoBehaviour
{
    private struct Cube
    {
        public Vector3 position;
        public Color color;
    }

    public ComputeShader computeShader;

    private List<MeshRenderer> cubeList;
    private Cube[] cubeArray;
    private ComputeBuffer cubeBuffer;

    private void CreateCubes(int count)
    {
        
    }
}