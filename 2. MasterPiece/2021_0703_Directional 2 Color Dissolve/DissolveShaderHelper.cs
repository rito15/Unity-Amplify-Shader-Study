using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Threading;
using System.Threading.Tasks;

#if UNITY_EDITOR
using UnityEditor;
#endif

// 날짜 : 2021-07-03 PM 9:31:52
// 작성자 : Rito

namespace Rito
{
    /// <summary> 
    /// Directional 2 Color Dissolve 쉐이더 Min, Max Offset 계산 도우미
    /// </summary>
    [DisallowMultipleComponent]
    public class DissolveShaderHelper : MonoBehaviour
    {
        public MeshFilter mf;
        public MeshRenderer mr;
        public Mesh mesh;
        public Material mat; // shared material

        public Vector3 direction = Vector3.up;
        public float minDot;
        public float maxDot;

#if !UNITY_EDITOR
        private void Awake()
        {
            Destroy(this);
        }
#endif

#if UNITY_EDITOR
        [CustomEditor(typeof(DissolveShaderHelper))]
        private class CE : UnityEditor.Editor
        {
            private DissolveShaderHelper m;
            private readonly object _lock = new object();

            private void OnEnable()
            {
                if (m == null) m = target as DissolveShaderHelper;
                if (m != null) InitReferences();
            }

            private void InitReferences()
            {
                m.mf = m.GetComponent<MeshFilter>();
                m.mr = m.GetComponent<MeshRenderer>();
                if (m.mf != null) m.mesh = m.mf.sharedMesh;
                if (m.mr != null) m.mat = m.mr.sharedMaterial;
            }

            public override void OnInspectorGUI()
            {
                if (m.mesh == null) return;
                if (m.mat == null) return;

                Undo.RecordObject(m, "");
                Undo.RecordObject(m.mat, "");

                m.direction = EditorGUILayout.Vector3Field("Dissolve Direction", m.direction);

                EditorGUILayout.LabelField($"Min : {m.minDot:F2}");
                EditorGUILayout.LabelField($"Max : {m.maxDot:F2}");

                if (GUILayout.Button("Calculate Min/Max Offsets"))
                {
                    CalculateMinMaxDots();
                    ApplyMaterialProperties();
                }
            }

            private void ApplyMaterialProperties()
            {
                if (m.mat == null) return;

                m.mat.SetVector("_DissolveDirection", m.direction);
                m.mat.SetFloat("_MinOffset", m.minDot);
                m.mat.SetFloat("_MaxOffset", m.maxDot);
            }

            private class MinMax
            {
                public float min;
                public float max;

                public MinMax Clone()
                {
                    return new MinMax() { min = min, max = max };
                }
            }

            /// <summary> 모든 정점을 순회하여 정밀 계산 </summary>
            private void CalculateMinMaxDots()
            {
                if (m.mesh == null) return;

                int vertCount = m.mesh.vertexCount;

                MinMax minMax = new MinMax();
                minMax.min = float.MaxValue;
                minMax.max = float.MinValue;

                Vector3[] vertices = m.mesh.vertices;
                Vector3 dissolveDir = m.direction.normalized;

                Parallel.For<MinMax>(0, vertCount,
                    () => minMax.Clone(),
                    (i, state, local) =>
                    {
                        float dot = Vector3.Dot(vertices[i], dissolveDir);

                        if (local.min > dot)
                            local.min = dot;
                        if (local.max < dot)
                            local.max = dot;

                        return local;
                    },
                    local =>
                    {
                        lock (_lock)
                        {
                            if (minMax.min > local.min)
                                minMax.min = local.min;
                            if (minMax.max < local.max)
                                minMax.max = local.max;
                        }
                    });

                m.minDot = minMax.min * 1.01f;
                m.maxDot = minMax.max * 1.01f;
            }
            /*
            // 최대 3천개의 정점만 순회하도록 최적화
            private void CalculateMinMaxDots2()
            {
                if (m.mesh == null) return;

                const int MaxVertCount = 3000;
                int vertCount = m.mesh.vertexCount;
                int tick = vertCount > MaxVertCount ? vertCount / MaxVertCount : 1;

                m.minDot = 99999f;
                m.maxDot = -99999f;
                Vector3 nDir = m.direction.normalized;

                Vector3[] vertices = m.mesh.vertices;

                for (int i = 0; i < vertCount; i += tick)
                {
                    float dot = Vector3.Dot(vertices[i], nDir);
                    if (dot > m.maxDot) m.maxDot = dot;
                    else if (dot < m.minDot) m.minDot = dot;
                }
            }
            */
        }
#endif
    }
}