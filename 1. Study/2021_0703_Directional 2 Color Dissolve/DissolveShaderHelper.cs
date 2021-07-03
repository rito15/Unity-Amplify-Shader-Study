using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

// 날짜 : 2021-07-03 PM 9:31:52
// 작성자 : Rito

namespace Rito
{
    /// <summary> 
    /// Directional 2 Color Dissolve 쉐이더 Min, Max Offset 계산 도우미
    /// </summary>
    public class DissolveShaderHelper : MonoBehaviour
    {
        private MeshFilter mf;
        private MeshRenderer mr;
        private Mesh mesh;
        private Material mat; // shared material

        private Vector3 direction = Vector3.up;
        private float minDot;
        private float maxDot;

#if UNITY_EDITOR
        [CustomEditor(typeof(DissolveShaderHelper))]
        private class CE : UnityEditor.Editor
        {
            private DissolveShaderHelper m;

            private void OnEnable()
            {
                if (m == null)
                    m = target as DissolveShaderHelper;

                if (m != null)
                {
                    InitReferences();
                }
            }

            public override void OnInspectorGUI()
            {
                if (m.mesh == null) return;

                m.direction = EditorGUILayout.Vector3Field("Dissolve Direction", m.direction);

                EditorGUILayout.LabelField($"Min : {m.minDot:F2}");
                EditorGUILayout.LabelField($"Max : {m.maxDot:F2}");

                if (GUILayout.Button("Calculate and Apply to Material (Fast)"))
                {
                    CalculateMinMaxDots();
                    ApplyMaterialProperties();
                }
                if (GUILayout.Button("Calculate and Apply to Material (Accurate)"))
                {
                    CalculateMinMaxDots2();
                    ApplyMaterialProperties();
                }
            }

            private void InitReferences()
            {
                m.TryGetComponent(out m.mf);
                m.TryGetComponent(out m.mr);
                if (m.mf != null) m.mesh = m.mf.sharedMesh;
                if (m.mr != null) m.mat  = m.mr.sharedMaterial;
            }

            private void ApplyMaterialProperties()
            {
                if (m.mat == null) return;

                m.mat.SetVector("_DissolveDirection", m.direction);
                m.mat.SetFloat("_MinOffset", m.minDot);
                m.mat.SetFloat("_MaxOffset", m.maxDot);
            }

            /// <summary> Bounds를 이용한 근사치 계산 </summary>
            private void CalculateMinMaxDots()
            {
                if (m.mesh == null) return;

                Bounds bounds = m.mesh.bounds;
                Vector3 min = bounds.min;
                Vector3 max = bounds.max;
                Vector3 tick = bounds.size / 10;

                m.minDot = 99999f;
                m.maxDot = -99999f;
                Vector3 nDir = m.direction.normalized;

                for (float z = min.z; z <= max.z; z += tick.z)
                    for (float y = min.y; y <= max.y; y += tick.y)
                        for (float x = min.x; x <= max.x; x += tick.x)
                        {
                            float dot = Vector3.Dot(new Vector3(x, y, z), nDir);
                            if (dot > m.maxDot) m.maxDot = dot;
                            else if (dot < m.minDot) m.minDot = dot;
                        }
            }

            /// <summary> 모든 정점을 순회하여 정밀 계산 </summary>
            private void CalculateMinMaxDots2()
            {
                if (m.mesh == null) return;

                // 최대 3천개의 정점만 순회하도록 최적화
                const int MaxVertCount = 3000;
                int vertCount = m.mesh.vertexCount;
                int tick = vertCount > MaxVertCount ? vertCount / 3000 : 1;

                m.minDot = 99999f;
                m.maxDot = -99999f;
                Vector3 nDir = m.direction.normalized;

                for (int i = 0; i < vertCount; i += tick)
                {
                    float dot = Vector3.Dot(m.mesh.vertices[i], nDir);
                    if (dot > m.maxDot) m.maxDot = dot;
                    else if (dot < m.minDot) m.minDot = dot;
                }
            }
        }
#endif
    }
}