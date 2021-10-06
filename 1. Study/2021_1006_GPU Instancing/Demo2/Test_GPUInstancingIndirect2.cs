using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 날짜 : 2021-10-06 PM 3:20:11
// 작성자 : Rito

using Random = UnityEngine.Random;

public class Test_GPUInstancingIndirect2 : MonoBehaviour
{
    public int instanceCount = 100000;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    public int subMeshIndex = 0;

    private int cachedInstanceCount = -1;
    private int cachedSubMeshIndex = -1;
    private ComputeBuffer positionBuffer;
    private ComputeBuffer argsBuffer;
    private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

    void Start()
    {
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        UpdateBuffers();
    }

    void Update()
    {
        // 인스턴스 개수 또는 서브메시 인덱스가 변경될 경우 버퍼 재생성
        if (cachedInstanceCount != instanceCount || cachedSubMeshIndex != subMeshIndex)
            UpdateBuffers();

        // Pad input
        if (Input.GetAxisRaw("Horizontal") != 0.0f)
            instanceCount = (int)Mathf.Clamp(instanceCount + Input.GetAxis("Horizontal") * 40000, 1.0f, 5000000.0f);

        // 렌더링 영역 설정 : 카메라의 프러스텀이 Bounds와 겹치지 않으면 컬링된다.
        Bounds renderBounds = new Bounds(Vector3.zero, new Vector3(100.0f, 100.0f, 100.0f));

        // Render
        Graphics.DrawMeshInstancedIndirect(
            instanceMesh,     // 그려낼 메시
            subMeshIndex,     // 서브메시 인덱스
            instanceMaterial, // 그려낼 마테리얼
            renderBounds,     // 렌더링 영역
            argsBuffer        // 메시 데이터 버퍼
        );
    }

    void OnGUI()
    {
        GUI.Label(new Rect(265, 25, 200, 30), "Instance Count: " + instanceCount.ToString());
        instanceCount = (int)GUI.HorizontalSlider(new Rect(25, 20, 200, 30), (float)instanceCount, 1.0f, 5000000.0f);
    }

    /// <summary> 인스턴스 개수 또는 서브메시 인덱스가 변경될 경우 버퍼 재생성 </summary>
    void UpdateBuffers()
    {
        // 서브메시 인덱스 범위 제한
        if (instanceMesh != null)
            subMeshIndex = Mathf.Clamp(subMeshIndex, 0, instanceMesh.subMeshCount - 1);

        // 위치 버퍼
        // xyz : 3D 위치
        // w   : 크기
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = new ComputeBuffer(instanceCount, 16);
        Vector4[] positions = new Vector4[instanceCount];

        for (int i = 0; i < instanceCount; i++)
        {
            float angle = Random.Range(0.0f, Mathf.PI * 2.0f);
            float distance = Random.Range(20.0f, 100.0f);
            float height = Random.Range(-2.0f, 2.0f);
            float size = Random.Range(0.05f, 0.25f);
            positions[i] = new Vector4(
                Mathf.Sin(angle) * distance, // Pos X
                height,                      // Pos Y
                Mathf.Cos(angle) * distance, // Pos Z
                size                         // Scale
            );
        }
        positionBuffer.SetData(positions);
        instanceMaterial.SetBuffer("positionBuffer", positionBuffer);

        // Indirect Args Buffer : 메시 데이터 초기화
        if (instanceMesh != null)
        {
            args[0] = (uint)instanceMesh.GetIndexCount(subMeshIndex);
            args[1] = (uint)instanceCount;
            args[2] = (uint)instanceMesh.GetIndexStart(subMeshIndex);
            args[3] = (uint)instanceMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args[0] = args[1] = args[2] = args[3] = 0;
        }
        argsBuffer.SetData(args);

        // 변화 감지를 위해 필드에 데이터 저장
        cachedInstanceCount = instanceCount;
        cachedSubMeshIndex = subMeshIndex;
    }

    void OnDisable()
    {
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = null;

        if (argsBuffer != null)
            argsBuffer.Release();
        argsBuffer = null;
    }
}