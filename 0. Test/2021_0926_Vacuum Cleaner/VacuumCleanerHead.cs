using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 날짜 : 2021-09-27 PM 3:13:42
// 작성자 : Rito

/// <summary> 
/// 진공 청소기 헤드 - 빨아들이는 부분
/// </summary>
public class VacuumCleanerHead : MonoBehaviour
{
    [SerializeField] private bool run = true;

    [Range(0f, 50f), Tooltip("빨아들이는 힘")]
    [SerializeField] private float suctionForce = 1f;

    [Range(1f, 20f), Tooltip("빨아들이는 범위(거리)")]
    [SerializeField] private float suctionRange = 5f;

    [Range(0.01f, 90f), Tooltip("빨아들이는 원뿔 각도")]
    [SerializeField] private float suctionAngle = 45f;

    [Range(0.01f, 5f), Tooltip("먼지가 사망하는 영역 반지름")]
    [SerializeField] private float deathRange = 0.2f;

    [Range(0.01f, 100f)]
    [SerializeField] private float moveSpeed = 50f;

    public bool Running => run;
    public float SqrSuctionRange => suctionRange * suctionRange;
    public float SuctionForce => suctionForce;
    public float DeathRange => deathRange;
    public Vector3 Position => transform.position;
    public Vector3 Forward => transform.forward;

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        DrawPrizmGizmo(Position, suctionRange, suctionAngle);
        //Gizmos.DrawWireSphere(Position + Forward * suctionRange, suctionRange);

        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(Position, deathRange);
    }

    private void Update()
    {
        // On/Off
        if (Input.GetKeyDown(KeyCode.Space))
            run ^= true;

        // Move
        float x = Input.GetAxisRaw("Horizontal");
        float z = Input.GetAxisRaw("Vertical");
        float y = 0f;
        if (Input.GetKey(KeyCode.E)) y += 1f;
        else if (Input.GetKey(KeyCode.Q)) y -= 1f;

        Vector3 moveVec = new Vector3(x, y, z).normalized * moveSpeed;

        if (Input.GetKey(KeyCode.LeftShift))
            moveVec *= 2f;

        transform.Translate(moveVec * Time.deltaTime, Space.World);
    }

    // origin : 원뿔 꼭대기
    // height : 원뿔 높이
    // angle  : 원뿔 각도
    private void DrawPrizmGizmo(Vector3 origin, float height, float angle, int sample = 24)
    {
        float deltaRad = Mathf.PI * 2f / sample;
        float circleRadius = Mathf.Tan(angle * Mathf.Deg2Rad) * height;
        Vector3 forward = Vector3.forward * height;

        Vector3 prevPoint = default;
        for (int i = 0; i <= sample; i++)
        {
            float delta = deltaRad * i;
            Vector3 circlePoint = new Vector3(Mathf.Cos(delta), Mathf.Sin(delta), 0f) * circleRadius;
            circlePoint += forward;

            circlePoint = transform.TransformPoint(circlePoint);

            Gizmos.DrawLine(circlePoint, origin);
            if (i > 0)
                Gizmos.DrawLine(circlePoint, prevPoint);
            prevPoint = circlePoint;
        }
    }
}