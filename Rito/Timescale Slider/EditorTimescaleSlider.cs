#if UNITY_EDITOR

using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEditor;

#if UNITY_2019_1_OR_NEWER
using UnityEngine.UIElements;
#else
using UnityEngine.Experimental.UIElements;
#endif

// 날짜 : 2021-09-01 PM 3:34:35
// 작성자 : Rito

namespace Rito
{
    /// <summary> 
    /// 유니티 에디터 재생 버튼 우측에 타임스케일 조정 슬라이더 생성
    /// </summary>
    public class EditorTimescaleSlider : MonoBehaviour
    {
        [InitializeOnLoadMethod]
        static void Init()
        {
            UnityToolbarExtenderTSS.ToolbarExtender.RightToolbarGUI.Add(OnToolbarGUI);
        }

        static void OnToolbarGUI()
        {
            EditorGUILayout.LabelField(" ", GUILayout.Width(10f));
            EditorGUILayout.LabelField("Timescale", GUILayout.MaxWidth(80f));
            Time.timeScale = EditorGUILayout.Slider(Time.timeScale, 0f, 1f, GUILayout.MaxWidth(120f));
        }
    }

    class BuildPreProcessor : UnityEditor.Build.IPreprocessBuildWithReport
    {
        public int callbackOrder => 0;

        public void OnPreprocessBuild(UnityEditor.Build.Reporting.BuildReport report)
        {
            Time.timeScale = 1f;
        }
    }
}

/*
    https://github.com/marijnz/unity-toolbar-extender
 */

namespace UnityToolbarExtenderTSS
{
    [InitializeOnLoad]
    public static class ToolbarExtender
    {
        static int m_toolCount;
        static GUIStyle m_commandStyle = null;

        public static readonly List<Action> LeftToolbarGUI = new List<Action>();
        public static readonly List<Action> RightToolbarGUI = new List<Action>();

        static ToolbarExtender()
        {
            Type toolbarType = typeof(Editor).Assembly.GetType("UnityEditor.Toolbar");

#if UNITY_2019_1_OR_NEWER
            string fieldName = "k_ToolCount";
#else
            string fieldName = "s_ShownToolIcons";
#endif

            FieldInfo toolIcons = toolbarType.GetField(fieldName,
                BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);

#if UNITY_2019_3_OR_NEWER
            m_toolCount = toolIcons != null ? ((int)toolIcons.GetValue(null)) : 8;
#elif UNITY_2019_1_OR_NEWER
            m_toolCount = toolIcons != null ? ((int) toolIcons.GetValue(null)) : 7;
#elif UNITY_2018_1_OR_NEWER
            m_toolCount = toolIcons != null ? ((Array) toolIcons.GetValue(null)).Length : 6;
#else
            m_toolCount = toolIcons != null ? ((Array) toolIcons.GetValue(null)).Length : 5;
#endif

            ToolbarCallback.OnToolbarGUI -= OnGUI;
            ToolbarCallback.OnToolbarGUI += OnGUI;
        }

#if UNITY_2019_3_OR_NEWER
        public const float space = 8;
#else
        public const float space = 10;
#endif
        public const float largeSpace = 20;
        public const float buttonWidth = 32;
        public const float dropdownWidth = 80;
#if UNITY_2019_1_OR_NEWER
        public const float playPauseStopWidth = 140;
#else
        public const float playPauseStopWidth = 100;
#endif

        static void OnGUI()
        {
            // Create two containers, left and right
            // Screen is whole toolbar

            if (m_commandStyle == null)
            {
                m_commandStyle = new GUIStyle("CommandLeft");
            }

            var screenWidth = EditorGUIUtility.currentViewWidth;

            // Following calculations match code reflected from Toolbar.OldOnGUI()
            float playButtonsPosition = Mathf.RoundToInt((screenWidth - playPauseStopWidth) / 2);

            Rect leftRect = new Rect(0, 0, screenWidth, Screen.height);
            leftRect.xMin += space; // Spacing left
            leftRect.xMin += buttonWidth * m_toolCount; // Tool buttons
#if UNITY_2019_3_OR_NEWER
            leftRect.xMin += space; // Spacing between tools and pivot
#else
            leftRect.xMin += largeSpace; // Spacing between tools and pivot
#endif
            leftRect.xMin += 64 * 2; // Pivot buttons
            leftRect.xMax = playButtonsPosition;

            Rect rightRect = new Rect(0, 0, screenWidth, Screen.height);
            rightRect.xMin = playButtonsPosition;
            rightRect.xMin += m_commandStyle.fixedWidth * 3; // Play buttons
            rightRect.xMax = screenWidth;
            rightRect.xMax -= space; // Spacing right
            rightRect.xMax -= dropdownWidth; // Layout
            rightRect.xMax -= space; // Spacing between layout and layers
            rightRect.xMax -= dropdownWidth; // Layers
#if UNITY_2019_3_OR_NEWER
            rightRect.xMax -= space; // Spacing between layers and account
#else
            rightRect.xMax -= largeSpace; // Spacing between layers and account
#endif
            rightRect.xMax -= dropdownWidth; // Account
            rightRect.xMax -= space; // Spacing between account and cloud
            rightRect.xMax -= buttonWidth; // Cloud
            rightRect.xMax -= space; // Spacing between cloud and collab
            rightRect.xMax -= 78; // Colab

            // Add spacing around existing controls
            leftRect.xMin += space;
            leftRect.xMax -= space;
            rightRect.xMin += space;
            rightRect.xMax -= space;

            // Add top and bottom margins
#if UNITY_2019_3_OR_NEWER
            leftRect.y = 4;
            leftRect.height = 22;
            rightRect.y = 4;
            rightRect.height = 22;
#else
            leftRect.y = 5;
            leftRect.height = 24;
            rightRect.y = 5;
            rightRect.height = 24;
#endif

            if (leftRect.width > 0)
            {
                GUILayout.BeginArea(leftRect);
                GUILayout.BeginHorizontal();
                foreach (var handler in LeftToolbarGUI)
                {
                    handler();
                }

                GUILayout.EndHorizontal();
                GUILayout.EndArea();
            }

            if (rightRect.width > 0)
            {
                GUILayout.BeginArea(rightRect);
                GUILayout.BeginHorizontal();
                foreach (var handler in RightToolbarGUI)
                {
                    handler();
                }

                GUILayout.EndHorizontal();
                GUILayout.EndArea();
            }
        }
    }

    public static class ToolbarCallback
    {
        static Type m_toolbarType = typeof(Editor).Assembly.GetType("UnityEditor.Toolbar");
        static Type m_guiViewType = typeof(Editor).Assembly.GetType("UnityEditor.GUIView");
#if UNITY_2020_1_OR_NEWER
        static Type m_iWindowBackendType = typeof(Editor).Assembly.GetType("UnityEditor.IWindowBackend");
        static PropertyInfo m_windowBackend = m_guiViewType.GetProperty("windowBackend",
            BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
        static PropertyInfo m_viewVisualTree = m_iWindowBackendType.GetProperty("visualTree",
            BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
#else
        static PropertyInfo m_viewVisualTree = m_guiViewType.GetProperty("visualTree",
            BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
#endif
        static FieldInfo m_imguiContainerOnGui = typeof(IMGUIContainer).GetField("m_OnGUIHandler",
            BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
        static ScriptableObject m_currentToolbar;

        /// <summary>
        /// Callback for toolbar OnGUI method.
        /// </summary>
        public static Action OnToolbarGUI;

        static ToolbarCallback()
        {
            EditorApplication.update -= OnUpdate;
            EditorApplication.update += OnUpdate;
        }

        static void OnUpdate()
        {
            // Relying on the fact that toolbar is ScriptableObject and gets deleted when layout changes
            if (m_currentToolbar == null)
            {
                // Find toolbar
                var toolbars = Resources.FindObjectsOfTypeAll(m_toolbarType);
                m_currentToolbar = toolbars.Length > 0 ? (ScriptableObject)toolbars[0] : null;
                if (m_currentToolbar != null)
                {
#if UNITY_2020_1_OR_NEWER
                    var windowBackend = m_windowBackend.GetValue(m_currentToolbar);

                    // Get it's visual tree
                    var visualTree = (VisualElement) m_viewVisualTree.GetValue(windowBackend, null);
#else
                    // Get it's visual tree
                    var visualTree = (VisualElement)m_viewVisualTree.GetValue(m_currentToolbar, null);
#endif

                    // Get first child which 'happens' to be toolbar IMGUIContainer
                    var container = (IMGUIContainer)visualTree[0];

                    // (Re)attach handler
                    var handler = (Action)m_imguiContainerOnGui.GetValue(container);
                    handler -= OnGUI;
                    handler += OnGUI;
                    m_imguiContainerOnGui.SetValue(container, handler);
                }
            }
        }

        static void OnGUI()
        {
            var handler = OnToolbarGUI;
            if (handler != null) handler();
        }
    }


}


#endif // UNITY_EDITOR