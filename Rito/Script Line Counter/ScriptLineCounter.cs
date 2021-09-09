#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.IO;

// 날짜 : 2021-09-04 PM 5:01:03
// 작성자 : Rito

namespace Rito
{
    /// <summary> 지정한 폴더 경로 내 모든 C# 스크립트 개수, 라인 수 집계 </summary>
    public class ScriptLineCounter : EditorWindow
    {
        /***********************************************************************
        *                               Init Menu Item
        ***********************************************************************/
        #region .
        [MenuItem("Window/Rito/C# Script Line Counter")] // 메뉴 등록
        private static void Init()
        {
            // 현재 활성화된 윈도우 가져오며, 없으면 새로 생성
            ScriptLineCounter window = (ScriptLineCounter)GetWindow(typeof(ScriptLineCounter));
            window.Show();

            // 윈도우 타이틀 지정
            window.titleContent.text = "C# Script Line Counter";

            // 최소, 최대 크기 지정
            window.minSize = new Vector2(340f, 150f);
            window.maxSize = new Vector2(600f, 1000f);
        }
        #endregion
        /***********************************************************************
        *                               Const Fields
        ***********************************************************************/
        #region .
        public const int TRUE = 1;
        public const int FALSE = 0;

        #endregion
        /***********************************************************************
        *                               Fields
        ***********************************************************************/
        #region .
        [SerializeField]
        private DefaultAsset folderAsset;
        private GUIContent folderLabel;

        [SerializeField]
        private DirTree treeRoot;

        [SerializeField]
        private Vector2 scrollPos = Vector2.zero;

        [SerializeField]
        private bool isCalculating = false;
        #endregion
        /***********************************************************************
        *                               GUI Methods
        ***********************************************************************/
        #region .
        private void InitGUI()
        {
            if (folderLabel == null)
                folderLabel = new GUIContent("Folder");
        }

        private void OnGUI()
        {
            InitGUI();

            // 스크롤바 생성
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

            folderAsset = EditorGUILayout.ObjectField(folderLabel, folderAsset, typeof(DefaultAsset), false) as DefaultAsset;

            if (GUILayout.Button("Calculate"))
            {
                DirectoryInfo di = (folderAsset == null) ?
                    new DirectoryInfo(Application.dataPath) :
                    folderAsset.GetDirectoryInfo();

                Task.Run(() => CreateTreeData(di));
            }

            if (isCalculating)
            {
                var oldAlign = EditorStyles.helpBox.alignment;
                var oldSize = EditorStyles.helpBox.fontSize;
                EditorStyles.helpBox.alignment = TextAnchor.MiddleCenter;
                EditorStyles.helpBox.fontSize = 14;

                EditorGUILayout.HelpBox("Calculating...", MessageType.Info);

                EditorStyles.helpBox.alignment = oldAlign;
                EditorStyles.helpBox.fontSize = oldSize;
            }
            else if (treeRoot != null)
            {
                DrawTree();
            }

            EditorGUILayout.EndScrollView();
        }

        private void CreateTreeData(DirectoryInfo rootFolder)
        {
            isCalculating = true;
            treeRoot = new DirTree(rootFolder, 0);
            isCalculating = false;
        }

        private void DrawTree()
        {
            Local_DrawTree(treeRoot);
            EditorGUI.indentLevel = 0;

            // 재귀적으로 트리 그리기
            void Local_DrawTree(DirTree tree)
            {
                if (tree.totalFileCount == 0) return;

                GUILayoutUtility.GetRect(0f, 4f); // Vertical Space
                EditorGUI.indentLevel = tree.depth;

                tree.foldout = EditorGUILayout.Foldout(tree.foldout, $"{tree.folderName} [C# Files : {tree.totalFileCount}, Total Lines : {tree.totalLineCount}]", true);
                if (tree.foldout)
                {
                    EditorGUI.indentLevel = tree.depth + 1;

                    // Draw Folders
                    for (int i = 0; i < tree.FolderCount; i++)
                    {
                        Local_DrawTree(tree.folders[i]);
                    }

                    // Draw File Labels
                    Color col = GUI.color;
                    GUI.color = Color.yellow * 2f;
                    for (int i = 0; i < tree.FileCount; i++)
                    {
                        EditorGUILayout.LabelField($"{tree.files[i].fileName} : {tree.files[i].lineCount}");
                    }
                    GUI.color = col;
                }
            }
        }
        #endregion
        /***********************************************************************
        *                               Class Definitions
        ***********************************************************************/
        #region .
        // 재귀 직렬 문제 발생 (원인 : DirTree[] folders 필드)
        //[System.Serializable]
        public class DirTree
        {
            //private DirectoryInfo folderInfo;
            public string absFolderPath;
            public string folderName;
            public int depth;
            public int totalFileCount; // 하위 파일 개수 합
            public int totalLineCount; // 하위 파일들의 라인 수 합

            public int FileCount => files?.Length ?? 0;
            public int FolderCount => folders?.Length ?? 0;

            public bool foldout = false;

            public DirTree[] folders;
            public FileLineData[] files;

            public DirTree(DirectoryInfo folderInfo, int depth, DirTree parent = null)
            {
                //this.folderInfo = folderInfo;
                this.folderName = folderInfo.Name;
                this.depth = depth;
                this.totalLineCount = 0;

                InitFolders(folderInfo);
                InitCsFiles(folderInfo);

                // 라인 수 집계를 부모에 가산
                if (parent != null)
                {
                    parent.totalFileCount += this.totalFileCount;
                    parent.totalLineCount += this.totalLineCount;
                }
            }

            /// <summary> 하위 폴더 트리 생성 </summary>
            private void InitFolders(DirectoryInfo folderInfo)
            {
                DirectoryInfo[] subFolders = folderInfo.GetDirectories();
                int subFolderCount = subFolders.Length;

                if (subFolderCount > 0)
                {
                    folders = new DirTree[subFolderCount];

                    for (int i = 0; i < subFolderCount; i++)
                    {
                        folders[i] = new DirTree(subFolders[i], this.depth + 1, this);
                    }
                }
            }

            /// <summary> 하위 C# 파일 목록 생성 </summary>
            private void InitCsFiles(DirectoryInfo folderInfo)
            {
                FileInfo[] csFiles = folderInfo.GetFiles("*.cs");
                int csFileCount = csFiles.Length;

                if (csFileCount > 0)
                {
                    files = new FileLineData[csFileCount];

                    for (int i = 0; i < csFileCount; i++)
                    {
                        int lineCount = File.ReadAllLines(csFiles[i].FullName).Length;
                        files[i] = new FileLineData(csFiles[i].Name, lineCount);
                        totalLineCount += lineCount;
                    }
                }

                totalFileCount += csFileCount;
            }
        }

        [System.Serializable]
        public struct FileLineData
        {
            public string fileName;
            public int lineCount;

            public FileLineData(string fileName, int lineCount)
            {
                this.fileName = fileName;
                this.lineCount = lineCount;
            }
        }
        #endregion
    }

    public static class UnityEditorAssetExtensions
    {
        /// <summary> 폴더 애셋으로부터 Assets로 시작하는 로컬 경로 얻기 </summary>
        public static string GetLocalPath(this UnityEditor.DefaultAsset @this)
        {
            bool success = 
                UnityEditor.AssetDatabase.TryGetGUIDAndLocalFileIdentifier(@this, out string guid, out long _);

            if (success)
                return UnityEditor.AssetDatabase.GUIDToAssetPath(guid);
            else
                return null;
        }

        /// <summary> 폴더 애셋으로부터 절대 경로 얻기 </summary>
        public static string GetAbsolutePath(this UnityEditor.DefaultAsset @this)
        {
            string path = GetLocalPath(@this);
            if (path == null) 
                return null;

            path = path.Substring(path.IndexOf('/') + 1);
            return Application.dataPath + "/" + path;
        }

        /// <summary> 폴더 애셋으로부터 DirectoryInfo 객체 얻기 </summary>
        public static System.IO.DirectoryInfo GetDirectoryInfo(this DefaultAsset @this)
        {
            string absPath = GetAbsolutePath(@this);
            return (absPath != null) ? new System.IO.DirectoryInfo(absPath) : null;
        }
    }
}

#endif