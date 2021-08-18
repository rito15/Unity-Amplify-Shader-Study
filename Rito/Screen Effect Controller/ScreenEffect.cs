using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

#if UNITY_EDITOR
using UnityEditor;
#endif

// 날짜 : 2021-08-18 PM 10:48:56
// 작성자 : Rito

/*
 * [TODO]
 * 
 * - 수명 설정 시 하이라키에 타이머 아이콘과 함께 남은 수명 실시간 표시
 * - Update로 남은 수명 계산
 * 
 * - 마테리얼 값 변화 이벤트 추가
 * 
 */

namespace Rito
{
    /// <summary> 
    /// 스크린 포스트 이펙트
    /// </summary>
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class ScreenEffect : MonoBehaviour
    {
        public Material effectMaterial;
        public int priority = 0;
        public float lifespan = 0;
        public bool showMaterialNameInHierarchy = true;

        private static ScreenEffectController controller;

        private void OnEnable()
        {
            if (controller == null)
                controller = ScreenEffectController.I;

            if(controller != null)
                controller.AddEffect(this);

            if (Application.isPlaying && lifespan > 0f)
            {
                Invoke(nameof(DestroyThisGameObject), lifespan);
            }
        }
        private void OnDisable()
        {
            if (controller == null)
                controller = ScreenEffectController.I;

            if (controller != null)
                controller.RemoveEffect(this);

            CancelInvoke(nameof(DestroyThisGameObject));
        }

        private void DestroyThisGameObject()
        {
            Destroy(gameObject);
        }

        /***********************************************************************
        *                               Custom Editor
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        [CustomEditor(typeof(ScreenEffect))]
        private class CE : UnityEditor.Editor
        {
            private ScreenEffect m;

            private void OnEnable()
            {
                m = target as ScreenEffect;
            }

            public override void OnInspectorGUI()
            {
                Undo.RecordObject(m, "Screen Effect Component");

                if (m.lifespan < 0f)
                    m.lifespan = 0f;

                EditorGUI.BeginChangeCheck();

                m.effectMaterial = EditorGUILayout.ObjectField("Effect Material", m.effectMaterial, typeof(Material), false) as Material;
                m.priority = EditorGUILayout.IntSlider("Priority", m.priority, -10, 10);
                m.lifespan = EditorGUILayout.FloatField("Lifespan", m.lifespan);
                m.showMaterialNameInHierarchy = EditorGUILayout.Toggle("Show Material Name", m.showMaterialNameInHierarchy);

                bool changed = EditorGUI.EndChangeCheck();
                if (changed)
                    EditorApplication.RepaintHierarchyWindow();
            }
        }
#endif
        #endregion

        /***********************************************************************
        *                               Hierarchy Icon
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        public static string CurrentFolderPath { get; private set; }

        private static Texture2D iconTexture;
        private static string iconTextureFilePath = @"Include\Effect.png";

        [InitializeOnLoadMethod]
        private static void ApplyHierarchyIcon()
        {
            InitFolderPath();

            if (iconTexture == null)
            {
                // "Assets\...\Icon.png"
                string texturePath = System.IO.Path.Combine(CurrentFolderPath, iconTextureFilePath);
                iconTexture = AssetDatabase.LoadAssetAtPath(texturePath, typeof(Texture2D)) as Texture2D;
            }

            EditorApplication.hierarchyWindowItemOnGUI += HierarchyIconHandler;
        }

        private static void InitFolderPath([System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "")
        {
            CurrentFolderPath = System.IO.Path.GetDirectoryName(sourceFilePath);
            int rootIndex = CurrentFolderPath.IndexOf(@"Assets\");
            if (rootIndex > -1)
            {
                CurrentFolderPath = CurrentFolderPath.Substring(rootIndex, CurrentFolderPath.Length - rootIndex);
            }
        }

        static void HierarchyIconHandler(int instanceID, Rect selectionRect)
        {
            GameObject go = EditorUtility.InstanceIDToObject(instanceID) as GameObject;

            if (go != null)
            {
                var target = go.GetComponent<ScreenEffect>();
                if (target != null)
                {
                    DrawHierarchyGUI(selectionRect, target);
                }
            }
        }

        private static void DrawHierarchyGUI(in Rect fullRect, ScreenEffect effect)
        {
            GameObject go = effect.gameObject;
            bool goActive = go.activeInHierarchy;
            bool matIsNotNull = effect.effectMaterial != null;

            // 1. Left Icon
            const float Pos = 32f;

            Rect iconRect = new Rect(fullRect);
            iconRect.x = Pos;
            iconRect.width = 16f;

            if(goActive && matIsNotNull)
                GUI.DrawTexture(iconRect, iconTexture);

            // 2. Right Rects
            float xEnd = fullRect.xMax + 10f;

            Rect rightButtonRect = new Rect(fullRect);
            rightButtonRect.xMax = xEnd;
            rightButtonRect.xMin = xEnd - 36f;

            Rect leftButtonRect = new Rect(rightButtonRect);
            leftButtonRect.xMax = rightButtonRect.xMin - 4f;
            leftButtonRect.xMin = leftButtonRect.xMax - 32f;

            float labelPosX = 20f;
            if (effect.priority <= -10 || effect.priority >= 100)
                labelPosX += 4f;
            if (effect.priority <= -100)
                labelPosX += 8f;

            Rect priorityLabelRect = new Rect(leftButtonRect);
            priorityLabelRect.xMax = leftButtonRect.xMin - 4f;
            priorityLabelRect.xMin = priorityLabelRect.xMax - labelPosX;

            Rect matNameRect = new Rect(priorityLabelRect);
            matNameRect.xMax = priorityLabelRect.xMin - 4f;
            matNameRect.xMin = matNameRect.xMax - 160f;

            // Labels
            Color c = GUI.color;
            GUI.color = goActive ? Color.cyan : Color.gray;
            {
                GUI.Label(priorityLabelRect, effect.priority.ToString());
            }
            GUI.color = goActive ? Color.magenta * 1.5f : Color.gray;
            {
                if (effect.showMaterialNameInHierarchy && matIsNotNull)
                    GUI.Label(matNameRect, effect.effectMaterial.name);
            }
            GUI.color = c;

            // Buttons
            EditorGUI.BeginDisabledGroup(go.activeSelf);
            if (GUI.Button(leftButtonRect, "ON"))
            {
                go.SetActive(true);
            }
            EditorGUI.EndDisabledGroup();

            EditorGUI.BeginDisabledGroup(!go.activeSelf);
            if (GUI.Button(rightButtonRect, "OFF"))
            {
                go.SetActive(false);
            }
            EditorGUI.EndDisabledGroup();
        }
#endif
        #endregion
        /***********************************************************************
        *                               Context Menu
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        private const string HierarchyMenuItemTitle = "GameObject/Effects/Add Screen Effect";

        [MenuItem(HierarchyMenuItemTitle, false, 501)]
        private static void MenuItem()
        {
            if (Selection.activeGameObject == null)
            {
                GameObject go = new GameObject("Screen Effect");
                go.AddComponent<ScreenEffect>();
            }
        }

        [MenuItem(HierarchyMenuItemTitle, true)] // Validation
        private static bool MenuItem_Validate()
        {
            return Selection.activeGameObject == null;
        }
#endif
        #endregion
        /***********************************************************************
        *                               Save Playmode Changes
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        private class Inner_PlayModeSave
        {
            private static UnityEditor.SerializedObject[] targetSoArr;

            [UnityEditor.InitializeOnLoadMethod]
            private static void Run()
            {
                UnityEditor.EditorApplication.playModeStateChanged += state =>
                {
                    switch (state)
                    {
                        case UnityEditor.PlayModeStateChange.ExitingPlayMode:
                            var targets = FindObjectsOfType(typeof(Inner_PlayModeSave).DeclaringType);
                            targetSoArr = new UnityEditor.SerializedObject[targets.Length];
                            for (int i = 0; i < targets.Length; i++)
                                targetSoArr[i] = new UnityEditor.SerializedObject(targets[i]);
                            break;

                        case UnityEditor.PlayModeStateChange.EnteredEditMode:
                            foreach (var oldSO in targetSoArr)
                            {
                                if (oldSO.targetObject == null) continue;
                                var oldIter = oldSO.GetIterator();
                                var newSO = new UnityEditor.SerializedObject(oldSO.targetObject);
                                while (oldIter.NextVisible(true))
                                    newSO.CopyFromSerializedProperty(oldIter);
                                newSO.ApplyModifiedProperties();
                            }
                            break;
                    }
                };
            }
        }
#endif
        #endregion
    }
}