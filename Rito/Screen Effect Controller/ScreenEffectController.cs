using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

#if UNITY_EDITOR
using UnityEditor;
#endif

// 날짜 : 2021-08-16 PM 8:15:59
// 작성자 : Rito

namespace Rito
{
    /// <summary> 
    /// 스크린 이미지 이펙트 관리 및 적용 컴포넌트
    /// </summary>
    [DisallowMultipleComponent]
    [ExecuteInEditMode]
    public class ScreenEffectController : MonoBehaviour
    {
        private const int INITIAL_EFFECT_CAPACITY = 8;

        private readonly List<ScreenEffect> _screenEffectList = new List<ScreenEffect>(INITIAL_EFFECT_CAPACITY);
        private readonly List<ScreenEffect> _validEffectList = new List<ScreenEffect>(INITIAL_EFFECT_CAPACITY);

#if UNITY_EDITOR
        private event Action EffectListChanged;
        [HideInInspector, SerializeField] private bool autoUpdateInEditMode;
#endif

        private RenderTexture[] _rts = new RenderTexture[2];

        private void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            _validEffectList.Clear();

            // 1. Validation Check
            for (int i = 0; i < _screenEffectList.Count; i++)
            {
                if (_screenEffectList[i] != null && _screenEffectList[i].effectMaterial != null)
                    _validEffectList.Add(_screenEffectList[i]);
            }
            int validCount = _validEffectList.Count;

            // 2. Blit
            switch (validCount)
            {
                // 유효한 스크린 이펙트가 없을 경우 : 스크린 그대로 출력
                case 0:
                    Graphics.Blit(source, destination);
                    break;

                case 1:
                    Graphics.Blit(source, destination, _validEffectList[0].effectMaterial);
                    break;

                default:
                    {
                        _rts[0] = source;
                        if (_rts[1] == null)
                            _rts[1] = new RenderTexture(source);

                        // 우선순위 정렬
                        _validEffectList.Sort((a, b) => a.priority - b.priority);

                        // Blit
                        int i = 0;
                        for (; i < validCount - 1; i++)
                        {
                            Graphics.Blit(_rts[i % 2], _rts[(i + 1) % 2], _validEffectList[i].effectMaterial);
                        }

                        Graphics.Blit(_rts[i % 2], destination, _validEffectList[i].effectMaterial);
                    }
                    break;
            }
        }

        private void Awake()
        {
            CheckSingleton();
        }

        public void AddEffect(ScreenEffect effect)
        {
            if (_screenEffectList.Contains(effect) == false)
                _screenEffectList.Add(effect);

#if UNITY_EDITOR
            EffectListChanged?.Invoke();
#endif
        }

        public void RemoveEffect(ScreenEffect effect)
        {
            if (_screenEffectList.Contains(effect))
                _screenEffectList.Remove(effect);

#if UNITY_EDITOR
            EffectListChanged?.Invoke();
#endif
        }

#if UNITY_EDITOR
        // 에디터 모드에서 게임뷰 자동 업데이트
        [InitializeOnLoadMethod]
        private static void AutoUpdateInEditMode()
        {
            EditorApplication.update += () =>
            {
                var target = FindObjectOfType<ScreenEffectController>();
                if (target != null && target.enabled && target.autoUpdateInEditMode)
                {
                    EditorUtility.SetDirty(target);
                }
            };
        }
#endif

        /***********************************************************************
        *                               Custom Editor
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        [CustomEditor(typeof(ScreenEffectController))]
        private class CE : UnityEditor.Editor
        {
            private ScreenEffectController m;
            private bool enabledState;
            private GUIStyle boldLabelStyle;

            private void OnEnable()
            {
                m = target as ScreenEffectController;

                m.EffectListChanged -= Repaint;
                m.EffectListChanged += Repaint;
            }

            public override void OnInspectorGUI()
            {
                base.OnInspectorGUI();

                if (Application.isPlaying == false)
                {
                    EditorGUI.BeginChangeCheck();
                    m.autoUpdateInEditMode = EditorGUILayout.ToggleLeft("Auto Update Game View", m.autoUpdateInEditMode);
                    if (EditorGUI.EndChangeCheck())
                        UnityEditor.SceneManagement.EditorSceneManager.SaveOpenScenes();
                }

                var leftLabelWidth = GUILayout.Width(EditorGUIUtility.currentViewWidth * 0.365f);
                if (boldLabelStyle == null)
                    boldLabelStyle = new GUIStyle(EditorStyles.boldLabel);

                Color oldCol = GUI.color;

                EditorGUILayout.Space();

                // Header Labels
                EditorGUILayout.BeginHorizontal();

                EditorGUILayout.LabelField("Material", boldLabelStyle, leftLabelWidth);
                EditorGUILayout.LabelField("Priority", boldLabelStyle);

                EditorGUILayout.EndHorizontal();

                // Effect Labels (List)
                if (m._validEffectList != null && m._validEffectList.Count > 0)
                {
                    for (int i = 0; i < m._validEffectList.Count; i++)
                    {
                        EditorGUILayout.BeginHorizontal();

                        GUI.color = Color.magenta * 1.5f;
                        EditorGUILayout.LabelField(m._validEffectList[i].effectMaterial.name, leftLabelWidth);

                        GUI.color = Color.cyan;
                        EditorGUILayout.LabelField(m._validEffectList[i].priority.ToString());

                        EditorGUILayout.EndHorizontal();
                    }
                }

                GUI.color = oldCol;

                // Repaint Hierarchy UI
                if (enabledState != m.enabled)
                {
                    EditorApplication.RepaintHierarchyWindow();
                }
                enabledState = m.enabled;
            }
        }
#endif
        #endregion
        /***********************************************************************
        *                               Singleton
        ***********************************************************************/
        #region .
        /// <summary> 싱글톤 인스턴스 Getter </summary>
        public static ScreenEffectController I
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType<ScreenEffectController>();

                    if (_instance == null && Camera.main != null)
                    {
                        _instance = Camera.main.GetComponent<ScreenEffectController>();

                        if (_instance == null)
                            _instance = Camera.main.gameObject.AddComponent<ScreenEffectController>();
                    }
                }
                return _instance;
            }
        }

        /// <summary> 싱글톤 인스턴스 Getter </summary>
        public static ScreenEffectController Instance => I;
        private static ScreenEffectController _instance;

        // Awake()에서 호출
        private void CheckSingleton()
        {
            // 싱글톤 인스턴스가 미리 존재하지 않았을 경우, 본인으로 초기화
            if (_instance == null)
            {
                _instance = this;
            }

            // 싱글톤 인스턴스가 존재하는데, 본인이 아닐 경우, 스스로(컴포넌트)를 파괴
            if (_instance != null && _instance != this)
            {
                var components = gameObject.GetComponents<Component>();
                if (components.Length <= 2) Destroy(gameObject);
                else Destroy(this);
            }
        }
        #endregion
        /***********************************************************************
        *                               Hierarchy Icon
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        public static string CurrentFolderPath { get; private set; } // "Assets\......\이 스크립트가 있는 폴더 경로"

        private static Texture2D iconTexture;
        private static string iconTextureFilePath = @"Include\Controller.png";

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

            if (go != null && go.activeSelf)
            {
                var target = go.GetComponent<ScreenEffectController>();
                if (target != null)
                {
                    DrawHierarchyGUI(selectionRect, target);
                }
            }
        }

        private static GUIStyle labelStyle;
        private static void DrawHierarchyGUI(in Rect fullRect, ScreenEffectController target)
        {
            bool active = target.isActiveAndEnabled;

            // 1. Left Icon
            Rect iconRect = new Rect(fullRect);
            iconRect.width = 16f;

#if UNITY_2019_3_OR_NEWER
            iconRect.x = 32f;
#else
            iconRect.x = 0f;
#endif
            if (iconTexture != null && active)
                GUI.DrawTexture(iconRect, iconTexture);

            // 2. Right Buttons
            float xEnd = fullRect.xMax + 10f;

            Rect rightButtonRect = new Rect(fullRect);
            rightButtonRect.xMax = xEnd;
            rightButtonRect.xMin = xEnd - 36f;

            Rect leftButtonRect = new Rect(rightButtonRect);
            leftButtonRect.xMax = rightButtonRect.xMin - 4f;
            leftButtonRect.xMin = leftButtonRect.xMax - 32f;

            Rect labelRect = new Rect(leftButtonRect);
            labelRect.xMax = leftButtonRect.xMin - 4f;
            labelRect.xMin = labelRect.xMax - 80f;



            // Label : "Screen Effect"
            if (labelStyle == null)
                labelStyle = new GUIStyle(EditorStyles.label);
            labelStyle.normal.textColor = active ? Color.yellow : Color.gray;

            EditorGUI.BeginDisabledGroup(!active);
            {
                GUI.Label(labelRect, "Screen Effect", labelStyle);
            }
            EditorGUI.EndDisabledGroup();



            EditorGUI.BeginDisabledGroup(target.enabled);
            if (GUI.Button(leftButtonRect, "ON"))
            {
                target.enabled = true;
            }
            EditorGUI.EndDisabledGroup();

            EditorGUI.BeginDisabledGroup(!target.enabled);
            if (GUI.Button(rightButtonRect, "OFF"))
            {
                target.enabled = false;
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
        private const string HierarchyMenuItemTitle = "GameObject/Effects/Screen Effect Controller";

        [MenuItem(HierarchyMenuItemTitle, false, 500)]
        private static void MenuItem()
        {
            var selected = Selection.activeGameObject;
            if (selected.GetComponent<ScreenEffectController>() == null)
                selected.AddComponent<ScreenEffectController>();
        }

        [MenuItem(HierarchyMenuItemTitle, true)] // Validation
        private static bool MenuItem_Validate()
        {
            var selected = Selection.activeGameObject;
            if (selected == null)
                return false;

            if (selected.GetComponent<Camera>() == null)
                return false;

            return selected.GetComponent<ScreenEffectController>() == null;
        }


        private const string ContextMenuItemTitle = "CONTEXT/Camera/Add Screen Effect Controller";

        [MenuItem(ContextMenuItemTitle, priority = 200)]
        private static void RandomRotation(MenuCommand command)
        {
            var target = command.context as Camera;
            if (target == null)
                return;

            if (target.GetComponent<ScreenEffectController>() == null)
                target.gameObject.AddComponent<ScreenEffectController>();
        }

        // 활성화 / 비활성화 여부 결정
        [MenuItem(ContextMenuItemTitle, true)]
        private static bool RandomRotation_Validate(MenuCommand command)
        {
            var target = command.context as Camera;
            if (target == null)
                return false;

            return target.GetComponent<ScreenEffectController>() == null;
        }
#endif
        #endregion
    }
}