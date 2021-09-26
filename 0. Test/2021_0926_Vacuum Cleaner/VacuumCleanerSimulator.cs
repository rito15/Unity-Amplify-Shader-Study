using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Threading.Tasks;

// 날짜 : 2021-09-26 PM 9:47:41
// 작성자 : Rito
// https://www.youtube.com/watch?v=PGk0rnyTa1U

/// <summary> 
/// 컴퓨트 쉐이더 - 진공 청소기 시뮬레이터
/// </summary>
[DisallowMultipleComponent]
public class VacuumCleanerSimulator : MonoBehaviour
{
    [Header("Dirt Options")]
    [SerializeField] private Mesh dirtMesh;
    [SerializeField] private Material dirtMaterial;

    [Header("Vacuum Cleaner Options")]
    [SerializeField] private Transform vacuumCleaner;
    [Range(1f, 20f)]
    [SerializeField] private float suctionRange = 5f;
    [Range(0f, 10f)]
    [SerializeField] private float suctionForce = 1f;

    [Space]
    [SerializeField] private int instanceNumber = 100000;
    [SerializeField] private float distributionRange = 100f;
    [Range(0.01f, 2f)]
    [SerializeField] private float dirtScale = 1f;

    private ComputeBuffer positionBuffer;
    private ComputeBuffer argsBuffer;
    private Bounds bounds;
    Vector3[] dirtPositions;

    /***********************************************************************
    *                               Unity Events
    ***********************************************************************/
    #region .
    private void Start()
    {
        Init();
    }
    private void Update()
    {
        UpdatePosition();
        dirtMaterial.SetFloat("_Scale", dirtScale);
        Graphics.DrawMeshInstancedIndirect(dirtMesh, 0, dirtMaterial, bounds, argsBuffer);
    }
    private void OnDestroy()
    {
        positionBuffer.Release();
        argsBuffer.Release();
    }
    #endregion
    /***********************************************************************
    *                               Init Methods
    ***********************************************************************/
    #region .
    private void Init()
    {
        uint[] argsData = new uint[] { (uint)dirtMesh.GetIndexCount(0), (uint)instanceNumber, 0, 0, 0 };

        argsBuffer = new ComputeBuffer(1, 5 * sizeof(uint), ComputeBufferType.IndirectArguments);
        argsBuffer.SetData(argsData);

        dirtPositions = new Vector3[instanceNumber];
        for (int i = 0; i < instanceNumber; i++)
        {
            dirtPositions[i] = UnityEngine.Random.insideUnitSphere * distributionRange;
            dirtPositions[i].z /= distributionRange;
        }

        positionBuffer = new ComputeBuffer(instanceNumber, sizeof(float) * 3);
        positionBuffer.SetData(dirtPositions);
        dirtMaterial.SetBuffer("_PositionBuffer", positionBuffer);

        bounds = new Bounds(Vector3.zero, Vector3.one * distributionRange); // ?
    }
    private void UpdatePosition()
    {
        float sqrRange = suctionRange * suctionRange;
        Vector3 centerPos = vacuumCleaner.position;
        float deltaTime = Time.deltaTime;

        Parallel.For(0, instanceNumber, i =>
        {
            if (Vector3.SqrMagnitude(centerPos - dirtPositions[i]) < sqrRange)
                dirtPositions[i] = Vector3.Lerp(dirtPositions[i], centerPos, deltaTime * suctionForce);
        });

        //for (int i = 0; i < instanceNumber; i++)
        //{
        //    if (Vector3.SqrMagnitude(centerPos - dirtPositions[i]) < sqrRange)
        //        dirtPositions[i] = Vector3.Lerp(dirtPositions[i], centerPos, deltaTime * suctionForce);
        //}
        positionBuffer.SetData(dirtPositions);
    }
    #endregion
}