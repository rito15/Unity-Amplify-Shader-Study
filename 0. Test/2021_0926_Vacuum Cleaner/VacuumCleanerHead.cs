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
    [Range(0f, 50f)]
    [SerializeField] private float suctionForce = 1f;
    [Range(1f, 20f)]
    [SerializeField] private float suctionRange = 5f;
    [Range(0.01f, 5f)]
    [SerializeField] private float deathRange = 0.2f;

    [Range(0.01f, 100f)]
    [SerializeField] private float moveSpeed = 50f;

    public bool Running => run;
    public float SqrSuctionRange => suctionRange * suctionRange;
    public float SuctionForce => suctionForce;
    public float DeathRange => deathRange;
    public Vector3 Position => transform.position;

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireSphere(Position, suctionRange);

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
}