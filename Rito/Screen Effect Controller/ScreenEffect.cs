
//#define SHOW_MATERIAL_NAME

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
using System.Runtime.InteropServices;
using System.Reflection;

#if UNITY_EDITOR
using UnityEditor;
#endif

#if UNITY_2019_3_OR_NEWER
using ShaderPropertyType = UnityEngine.Rendering.ShaderPropertyType;
#else
public enum ShaderPropertyType
{
    Color = 0,
    Vector = 1,
    Float = 2,
    Range = 3,
    Texture = 4
}
#endif

#pragma warning disable CS0649 // Never Assigned

// 날짜 : 2021-08-18 PM 10:48:56
// 작성자 : Rito

/*
 * [에디터 테스트]
 *  - 2018.3.14f1 테스트 완료
 *  - 2019.4.9f1  테스트 완료
 *  - 2020.3.14f1 테스트 완료
 *  - 2021.1.16f1 테스트 완료
 * 
 * [빌드 테스트]
 *  - 2018.3.14f1 테스트 완료
 *  - 2019.4.9f1  테스트 완료
 *  - 2020.3.14f1 테스트 완료(Mono, IL2CPP)
 *  - 2021.1.16f1 테스트 완료
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
        public enum StopAction
        {
            KeepLastState, Disable, Destroy, Repeat
        }

        public Material effectMaterial;
        public int priority = 0;

        [SerializeField] private StopAction stopAction;

        private static ScreenEffectController controller;

        /// <summary> 기준 FPS를 설정할지 여부 </summary>
        [SerializeField] private bool useTargetFPS = true;
        [SerializeField] private float targetFPS = 60;

        /// <summary> 시간 계산 방식이 초인지 프레임인지 여부 </summary>
        [SerializeField] private bool isTimeModeSeconds = true;
        private bool IsTimeModeFrame => !isTimeModeSeconds;

        // 지속시간 : 초
        [SerializeField] private float durationSeconds = 0f;
        private float currentSeconds = 0f;

        // 지속시간 : 프레임
        [SerializeField] private float durationFrame = 0;
        private float currentFrame = 0;

        // 재생 속도 : 0 ~ 2x
        [SerializeField] private float animPlaySpeed = 1f;

        // 타임스케일 영향 받을지 여부
        [SerializeField] private bool affectedByTimescale = true;

        private float DeltaTime
        {
            get
            {
                return affectedByTimescale ?
                    Time.deltaTime : Time.unscaledDeltaTime;
            }
        }

        /// <summary> 현재 시간/프레임, 애니메이션 진행사항 유지 </summary>
        private bool keepCurrentState = false;

#if UNITY_EDITOR
        /// <summary> 플레이 모드 중 Current Time 직접 수정 가능 모드 </summary>
        private bool __editMode = false;

#if SHOW_MATERIAL_NAME
        [SerializeField] private bool showMaterialNameInHierarchy = false; // Deprecated
#endif

        [SerializeField] private bool __optionFoldout1 = true;
        [SerializeField] private bool __optionFoldout2 = true;
        [SerializeField] private bool __matPropListFoldout = true;

        [SerializeField] private int __propCount; // 마테리얼 프로퍼티 개수 기억(변화 감지용)

        [SerializeField] private int __durationChangeActionPopupIndex = 0;

        /// <summary> 마테리얼의 초깃값 기억 </summary>
        [SerializeField]
        private MaterialPropertyAnimKey[] __materialDefaultValues;

        /// <summary> 복제된 마테리얼 현재 값 기억 (Undo 용도)</summary>
        [SerializeField]
        private MaterialPropertyAnimKey[] __materialCurrentValues;

        private Action __OnEditorUpdate;
#endif

        private void OnEnable()
        {
            if (controller == null)
                controller = ScreenEffectController.I;

            if (controller != null)
                controller.AddEffect(this);

            currentSeconds = 0f;
            currentFrame = 0;
            keepCurrentState = false;
        }
        private void OnDisable()
        {
            if (controller == null)
                controller = ScreenEffectController.I;

            if (controller != null)
                controller.RemoveEffect(this);
        }

        private void Update()
        {
            if (Application.isPlaying == false) return;
            if (keepCurrentState) return; // 현재 시간, 진행 사항 유지

            UpdateMaterialPropertyAnimations();

#if UNITY_EDITOR
            if (__editMode) return;
            else __OnEditorUpdate?.Invoke();
#endif
            UpdateTime();
        }

        private void UpdateMaterialPropertyAnimations()
        {
            if (isTimeModeSeconds)
            {
                if (durationSeconds <= 0f)
                    return;
            }
            else
            {
                if (durationFrame == 0)
                    return;
            }

            for (int i = 0; i < matPropertyList.Count; i++)
            {
                var mp = matPropertyList[i];
                if (mp == null || mp.animKeyList == null || mp.animKeyList.Count == 0)
                    continue;

                if (mp.enabled == false)
                    continue;

                var animKeyList = mp.animKeyList;
                int animKeyCount = animKeyList.Count - 1;

                // 최적화를 위해 추가 : 처리 완료 확인
                bool handled = false;

                // 1. 시간 계산 방식 : 초
                if (isTimeModeSeconds)
                {
#if UNITY_EDITOR
                    // 현재 재생 중인 인덱스 초기화
                    for (int j = 0; j < animKeyCount; j++)
                    {
                        if (animKeyList[j].time <= currentSeconds && currentSeconds < animKeyList[j + 1].time)
                        {
                            mp.__playingIndex = j;
                            break;
                        }
                    }
#endif
                    switch (mp.propType)
                    {
                        case ShaderPropertyType.Float:
                        case ShaderPropertyType.Range:
                            for (int j = 0; j < animKeyCount; j++)
                            {
                                if (handled) break;

                                var prevKey = animKeyList[j];
                                var nextKey = animKeyList[j + 1];

                                // 해당하는 시간 구간이 아닐 경우, 판정하지 않음
                                if (currentSeconds < prevKey.time || nextKey.time <= currentSeconds) continue;
                                float t = (currentSeconds - prevKey.time) / (nextKey.time - prevKey.time);

                                // REMAP
                                float curValue = Mathf.Lerp(prevKey.floatValue, nextKey.floatValue, t);

                                effectMaterial.SetFloat(mp.propName, curValue);
                                handled = true;
                            }
                            break;

                        case ShaderPropertyType.Color:
                            for (int j = 0; j < animKeyCount; j++)
                            {
                                if (handled) break;

                                var prevKey = animKeyList[j];
                                var nextKey = animKeyList[j + 1];

                                if (currentSeconds < prevKey.time || nextKey.time <= currentSeconds) continue;
                                float t = (currentSeconds - prevKey.time) / (nextKey.time - prevKey.time);
                                Color curValue = Color.Lerp(prevKey.color, nextKey.color, t);

                                effectMaterial.SetColor(mp.propName, curValue);
                                handled = true;
                            }
                            break;

                        case ShaderPropertyType.Vector:
                            for (int j = 0; j < animKeyCount; j++)
                            {
                                if (handled) break;

                                var prevKey = animKeyList[j];
                                var nextKey = animKeyList[j + 1];

                                if (currentSeconds < prevKey.time || nextKey.time <= currentSeconds) continue;
                                float t = (currentSeconds - prevKey.time) / (nextKey.time - prevKey.time);
                                Vector4 curValue = Vector4.Lerp(prevKey.vector4, nextKey.vector4, t);

                                effectMaterial.SetVector(mp.propName, curValue);
                                handled = true;
                            }
                            break;
                    }
                }
                // 2. 시간 계산 방식 : 프레임
                else
                {
#if UNITY_EDITOR
                    // 현재 재생 중인 인덱스 초기화
                    for (int j = 0; j < animKeyCount; j++)
                    {
                        if (animKeyList[j].frame <= currentFrame && currentFrame < animKeyList[j + 1].frame)
                        {
                            mp.__playingIndex = j;
                            break;
                        }
                    }
#endif
                    switch (mp.propType)
                    {
                        case ShaderPropertyType.Float:
                        case ShaderPropertyType.Range:
                            for (int j = 0; j < animKeyCount; j++)
                            {
                                if (handled) break;

                                var prevKey = animKeyList[j];
                                var nextKey = animKeyList[j + 1];

                                if (currentFrame < prevKey.frame || nextKey.frame <= currentFrame) continue;
                                float t = (float)(currentFrame - prevKey.frame) / (nextKey.frame - prevKey.frame);
                                float curValue = Mathf.Lerp(prevKey.floatValue, nextKey.floatValue, t);

                                effectMaterial.SetFloat(mp.propName, curValue);
                                handled = true;
                            }
                            break;

                        case ShaderPropertyType.Color:
                            for (int j = 0; j < animKeyCount; j++)
                            {
                                if (handled) break;

                                var prevKey = animKeyList[j];
                                var nextKey = animKeyList[j + 1];

                                if (currentFrame < prevKey.frame || nextKey.frame <= currentFrame) continue;
                                float t = (float)(currentFrame - prevKey.frame) / (nextKey.frame - prevKey.frame);
                                Color curValue = Color.Lerp(prevKey.color, nextKey.color, t);

                                effectMaterial.SetColor(mp.propName, curValue);
                                handled = true;
                            }
                            break;

                        case ShaderPropertyType.Vector:
                            for (int j = 0; j < animKeyCount; j++)
                            {
                                if (handled) break;

                                var prevKey = animKeyList[j];
                                var nextKey = animKeyList[j + 1];

                                if (currentFrame < prevKey.frame || nextKey.frame <= currentFrame) continue;
                                float t = (float)(currentFrame - prevKey.frame) / (nextKey.frame - prevKey.frame);
                                Vector4 curValue = Vector4.Lerp(prevKey.vector4, nextKey.vector4, t);

                                effectMaterial.SetVector(mp.propName, curValue);
                                handled = true;
                            }
                            break;
                    }
                }
            }
        }

        private void UpdateTime()
        {
            if (isTimeModeSeconds)
                UpdateSeconds();
            else
                UpdateFrames();
        }

        private void UpdateSeconds()
        {
            if (durationSeconds <= 0f) return;

            currentSeconds += DeltaTime * animPlaySpeed;
            if (currentSeconds >= durationSeconds)
            {
                currentSeconds = durationSeconds;
                DoStopActions();
            }
        }

        private void UpdateFrames()
        {
            if (durationFrame <= 0) return;

            // 1. 타겟 FPS를 지정한 경우 : 프레임 계산하여 증가
            if (useTargetFPS)
            {
                currentFrame += DeltaTime * targetFPS * animPlaySpeed;
            }
            // 2. 그냥 매 프레임 카운팅 하는 경우 : 매 프레임 1씩 증가
            else
            {
                currentFrame += animPlaySpeed;
            }

            if (currentFrame >= durationFrame)
            {
                currentFrame = durationFrame;
                DoStopActions();
            }
        }

        /// <summary> 종료 동작 수행 </summary>
        private void DoStopActions()
        {
            switch (stopAction)
            {
                case StopAction.KeepLastState:
                    keepCurrentState = true;
                    break;

                case StopAction.Disable:
                    gameObject.SetActive(false);
                    break;

                case StopAction.Destroy:
                    Destroy(gameObject);
                    break;

                case StopAction.Repeat:
                    currentSeconds = 0f;
                    currentFrame = 0f;
                    break;
            }
        }

        /***********************************************************************
        *                           Material Property Animation
        ***********************************************************************/
        #region .
        [System.Serializable]
        private class MaterialPropertyInfo
        {
            public Material material;
            public string propName;
            public ShaderPropertyType propType;
            public bool enabled;

            public List<MaterialPropertyAnimKey> animKeyList;

#if UNITY_EDITOR
            public bool __HasAnimation => animKeyList != null && animKeyList.Count > 0;

            public string __displayName;
            public int __propIndex;

            public bool __foldout = true;
            public int __playingIndex = 0; // 현재 재생 중인 애니메이션 키 인덱스

            // 그래프 보여주기
            public bool __showGraph = false;
            public bool[] __showVectorGraphs;

            // 애니메이션 보여주기
            public bool __showAnimation = false;

            // 컬러 : 그라디언트 or 그래프
            public bool __isGradientView = true;

            // 마커 : 인덱스 표시 or 시간/프레임 표시
            public bool __showIndexOrTime = true;

            // 키 목록이 더러워용
            // 그래프 - 마우스 이벤트 처리 중 리스트에 변경사항 발생
            public bool __isKeyListDirty = false;

            public MaterialPropertyInfo(Material material, string name, string displayName, ShaderPropertyType type, int propIndex)
            {
                this.material = material;
                this.propName = name;
                this.__displayName = displayName;
                this.propType = type;
                this.__propIndex = propIndex;
                this.enabled = false;

                this.animKeyList = new List<MaterialPropertyAnimKey>(10);

                this.__showVectorGraphs = new bool[4];
                for (int i = 0; i < this.__showVectorGraphs.Length; i++)
                    this.__showVectorGraphs[i] = true;
            }

            /// <summary> 애니메이션이 아예 없었던 경우, 초기 애니메이션 키 2개(시작, 끝) 추가 </summary>
            public void Edt_AddInitialAnimKeys(float duration, bool isTimeModeSeconds)
            {
                this.enabled = true;

                var begin = new MaterialPropertyAnimKey();
                var end = new MaterialPropertyAnimKey();

                begin.time = 0;

                if (isTimeModeSeconds)
                    end.time = duration;
                else
                    end.frame = duration;

                switch (propType)
                {
                    case ShaderPropertyType.Float:
                        begin.floatValue = end.floatValue = material.GetFloat(propName);
                        break;

                    case ShaderPropertyType.Range:
                        begin.floatValue = end.floatValue = material.GetFloat(propName);
                        begin.range = end.range = material.shader.GetPropertyRangeLimits(__propIndex);
                        break;
                    case ShaderPropertyType.Color:
                        begin.color = end.color = material.GetColor(propName);
                        break;

                    case ShaderPropertyType.Vector:
                        begin.vector4 = end.vector4 = material.GetVector(propName);
                        break;
                }

                animKeyList.Add(begin);
                animKeyList.Add(end);
            }

            /// <summary> 해당 인덱스의 바로 뒤에 새로운 애니메이션 키 추가 </summary>
            public void Edt_AddNewAnimKey(int index, bool isTimeModeSeconds, float interpolation = 0.5f)
            {
                MaterialPropertyAnimKey prevKey = animKeyList[index];
                MaterialPropertyAnimKey nextKey = animKeyList[index + 1];

                var newKey = new MaterialPropertyAnimKey();

                // 시간or프레임 - 보간하여 전달
                if (isTimeModeSeconds)
                    newKey.time = Mathf.Lerp(prevKey.time, nextKey.time, interpolation);
                else
                    newKey.frame = Mathf.Lerp(prevKey.frame, nextKey.frame, interpolation);

                // 값도 보간하여 초기화
                switch (propType)
                {
                    case ShaderPropertyType.Float:
                    FLOAT:
                        newKey.floatValue = Mathf.Lerp(prevKey.floatValue, nextKey.floatValue, interpolation);
                        break;

                    case ShaderPropertyType.Range:
                        newKey.range = material.shader.GetPropertyRangeLimits(__propIndex);
                        goto FLOAT;

                    case ShaderPropertyType.Color:
                        newKey.color = Color.Lerp(prevKey.color, nextKey.color, interpolation);
                        break;

                    case ShaderPropertyType.Vector:
                        newKey.vector4 = Vector4.Lerp(prevKey.vector4, nextKey.vector4, interpolation);
                        break;
                }

                animKeyList.Insert(index + 1, newKey);
            }

            /// <summary> 지정한 시간 또는 프레임 위치에 알맞게 새로운 애니메이션 키 추가 </summary>
            public void Edt_InsertNewAnimKey(float timeOrFrame, bool isTimeModeSeconds)
            {
                if (animKeyList.Count == 0)
                {
                    Debug.LogWarning("Animation Key List가 비어 있습니다.");
                    return;
                }

                if (isTimeModeSeconds)
                {
                    for (int i = 0; i < animKeyList.Count - 1; i++)
                    {
                        if (animKeyList[i].time < timeOrFrame && timeOrFrame < animKeyList[i + 1].time)
                        {
                            float invLerp = Mathf.InverseLerp(animKeyList[i].time, animKeyList[i + 1].time, timeOrFrame);
                            Edt_AddNewAnimKey(i, isTimeModeSeconds, invLerp);
                            return;
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < animKeyList.Count - 1; i++)
                    {
                        if (animKeyList[i].frame < timeOrFrame && timeOrFrame < animKeyList[i + 1].frame)
                        {
                            float invLerp = Mathf.InverseLerp(animKeyList[i].frame, animKeyList[i + 1].frame, timeOrFrame);
                            Edt_AddNewAnimKey(i, isTimeModeSeconds, invLerp);
                            return;
                        }
                    }
                }
            }

            /// <summary> 프로퍼티 내의 모든 애니메이션 키 제거 </summary>
            public void Edt_RemoveAllAnimKeys()
            {
                this.animKeyList.Clear();
                this.enabled = false;
            }
#endif
        }

        [System.Serializable]
        [StructLayout(LayoutKind.Explicit)]
        private class MaterialPropertyAnimKey
        {
            [FieldOffset(0)] public float time;
            [FieldOffset(4)] public float frame;

            [FieldOffset(8)] public float floatValue;

            [FieldOffset(12)] public Vector2 range;
            [FieldOffset(12)] public float min;
            [FieldOffset(16)] public float max;

            [FieldOffset(8)] public Color color;
            [FieldOffset(8)] public Vector4 vector4;
        }

        [SerializeField]
        private List<MaterialPropertyInfo> matPropertyList = new List<MaterialPropertyInfo>(20);

        #endregion
        /***********************************************************************
        *                           Custom Editor
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        [CustomEditor(typeof(ScreenEffect))]
        private class CE : UnityEditor.Editor
        {
            private ScreenEffect m;

            private Material material;
            private Shader shader;

            private bool isMaterialChanged;

            /// <summary> Duration Time 또는 Frame 값이 0 </summary>
            private bool isDurationZero;

            private bool isPlayMode;

            /// <summary> 현재 시간 진행도(0.0 ~ 1.0) </summary>
            private float currentTimeOrFrameRatio;

            /// <summary> 값 복사, 붙여넣기를 위한 값 </summary>
            private MaterialPropertyAnimKey clipboardValue;
            private ShaderPropertyType clipboardValueType;

            private static readonly Color MinusButtonColor = Color.red * 1.5f;
            private static readonly Color TimeColor = new Color(1.5f, 1.5f, 0.2f, 1f);  // Yellow
            private static readonly Color EnabledColor = new Color(0f, 1.5f, 1.5f, 1f); // Cyan

            private static GUIStyle bigMinusButtonStyle;
            private static GUIStyle whiteTextButtonStyle; // 글씨가 하얀색인 버튼
            private static GUIStyle blackTextButtonStyle; // 글씨가 하얀색인 버튼
            private static GUIStyle graphToggleButtonStyle;
            private static GUIStyle boldFoldoutStyle;
            private static GUIStyle propertyAnimKeyTimeLabelStyle;
            private static GUIStyle whiteBoldLabelStyle;
            private static GUIStyle yellowBoldLabelStyle;
            private static GUIStyle whiteAnimKeyIndexLabelStyle;

            private static Texture2D playTexture;
            private static Texture2D pauseTexture;

            private void OnEnable()
            {
                m = target as ScreenEffect;

                isHangle = EditorPrefs.GetBool(EngHanPrefKey, false);

                m.__OnEditorUpdate -= Repaint;
                m.__OnEditorUpdate += Repaint;

                Undo.undoRedoPerformed -= OnUndoRedoPerformed;
                Undo.undoRedoPerformed += OnUndoRedoPerformed;

                InitReflectionData();
                LoadEditorInternalTextures();
            }
            private void OnDisable()
            {
                Undo.undoRedoPerformed -= OnUndoRedoPerformed;
            }

            /// <summary> 마테리얼 프로퍼티 값 수정 후 Undo/Redo 동작 시 정상적으로 적용 </summary>
            private void OnUndoRedoPerformed()
            {
                SetGameObjectName();

                if (material == null) return;
                if (m.__materialCurrentValues == null) return;
                if (m.matPropertyList == null) return;
                if (m.matPropertyList.Count == 0) return;

                for (int i = 0; i < m.__materialCurrentValues.Length; i++)
                {
                    if (m.__materialCurrentValues[i] == null) continue;
                    if (m.matPropertyList[i] == null) continue;

                    var curValue = m.__materialCurrentValues[i];
                    var propType = m.matPropertyList[i].propType;
                    var propName = m.matPropertyList[i].propName;

                    switch (propType)
                    {
                        case ShaderPropertyType.Float:
                        case ShaderPropertyType.Range:
                            material.SetFloat(propName, curValue.floatValue);
                            break;

                        case ShaderPropertyType.Vector:
                            material.SetVector(propName, curValue.vector4);
                            break;

                        case ShaderPropertyType.Color:
                            material.SetColor(propName, curValue.color);
                            break;
                    }
                }
            }

            public override void OnInspectorGUI()
            {
                DrawTopMostButtons();

                isMaterialChanged = CheckMaterialChanged();
                InitVariables();
                InitStyles();

                Undo.RecordObject(m, "Screen Effect Component");

                EditorGUI.BeginChangeCheck();
                {
                    EditorGUILayout.Space();
                    DrawOptionFields();

                    if (m.effectMaterial == null)
                    {
                        m.matPropertyList.Clear();
                    }
                    else
                    {
                        // 마테리얼 정보가 변한 경우, 전체 마테리얼 프로퍼티 및 애니메이션 초기화
                        if (isMaterialChanged)
                        {
                            InitMaterial();
                        }

                        if (isPlayMode && isDurationZero == false)
                        {
                            EditorGUILayout.Space();
                            EditorGUILayout.Space();
                            DrawEditorOptions();
                        }

                        EditorGUILayout.Space();
                        EditorGUILayout.Space();
                        DrawCopiedMaterialProperties();

                        EditorGUILayout.Space();
                        EditorGUILayout.Space();
                        DrawMaterialPropertyAnimKeyList();
                    }
                }
                if (EditorGUI.EndChangeCheck())
                    EditorApplication.RepaintHierarchyWindow();

                EditorGUILayout.Space();
                EditorGUILayout.Space();
            }

            /***********************************************************************
            *                               Eng / Han
            ***********************************************************************/
            #region .
            private bool isHangle = false;
            private static readonly string EngHanPrefKey = "Rito_ScreenEffect_Hangle";

            private static readonly string[] StopActionsHangle = new string[]
            {
                "마지막 상태 유지", "비활성화", "파괴", "반복(재시작)"
            };
            private static readonly string[] TimeModesEng = new string[]
            {
                "Time(Seconds)", "Frame"
            };
            private static readonly string[] TimeModesHan = new string[]
            {
                "시간(초)", "프레임"
            };
            private static readonly string[] DurationChangeActionEng = new string[]
            {
                "Keep Animation Time Ratio", "Keep Animation Time Value"
            };
            private static readonly string[] DurationChangeActionHan = new string[]
            {
                "애니메이션 시간 비율 유지", "애니메이션 시간 값 유지"
            };

            bool onOffMoving = false;
            float onOffPos = 0f;
            string onOffStr = "On";
            Rect onOffRect = default;
            private void DrawTopMostButtons()
            {
#if !UNITY_2019_3_OR_NEWER
                EditorGUILayout.Space();
#endif
                Rect rect = GUILayoutUtility.GetRect(1f, 20f);

#if UNITY_2019_3_OR_NEWER
                const float LEFT = 15f;
#else
                const float LEFT = 12f;
#endif
                const float RIGHT = 52f;
                const float WIDTH = 40f;

                Rect bgRect = new Rect(rect);
                bgRect.x = LEFT + 1f;
                bgRect.xMax = RIGHT + WIDTH - 2f;
                EditorGUI.DrawRect(bgRect, new Color(0.15f, 0.15f, 0.15f));

                onOffRect = new Rect(rect);
                onOffRect.width = WIDTH;
                onOffRect.x = onOffPos;

                const float buttonWidth = 44f;
                rect.xMin = rect.width - buttonWidth - 4f;

                Color col = GUI.backgroundColor;
                GUI.backgroundColor = Color.black;

                // 1. 움직이는 On/Off 버튼
                if (GUI.Button(onOffRect, onOffStr, whiteTextButtonStyle))
                {
                    onOffMoving = true;
                }

                if (!onOffMoving)
                {
                    if (m.gameObject.activeSelf)
                    {
                        onOffPos = LEFT;
                        onOffStr = "On";
                    }
                    else
                    {
                        onOffPos = RIGHT;
                        onOffStr = "Off";
                    }
                }
                else
                {
                    if (m.gameObject.activeSelf)
                    {
                        if (onOffPos < RIGHT)
                        {
                            onOffPos += 1f;
                            Repaint();

                            if (onOffPos >= RIGHT)
                            {
                                onOffMoving = false;
                                m.gameObject.SetActive(false);
                            }
                        }
                    }
                    else
                    {
                        if (onOffPos > LEFT)
                        {
                            onOffPos -= 1f;
                            Repaint();

                            if (onOffPos <= LEFT)
                            {
                                onOffMoving = false;
                                m.gameObject.SetActive(true);
                            }
                        }
                    }
                }

                // 2. EngHan 버튼
                if (GUI.Button(rect, "Eng/한글", whiteTextButtonStyle))
                {
                    isHangle = !isHangle;
                    EditorPrefs.SetBool(EngHanPrefKey, isHangle);
                }

                GUI.backgroundColor = col;
            }

            private string EngHan(string eng, string han)
            {
                return !isHangle ? eng : han;
            }

            #endregion
            /************************************************************************
             *                              Tiny Methods, Init Methods
             ************************************************************************/
            #region .
            private bool CheckMaterialChanged()
            {
                // 쉐이더 프로퍼티 개수 변경 감지
                if (m.effectMaterial != null)
                {
                    int propCount = m.effectMaterial.shader.GetPropertyCount();
                    if (propCount != m.__propCount)
                    {
                        m.__propCount = propCount;
                        return true;
                    }
                }

                return false;
            }
            private void InitReflectionData()
            {
                BindingFlags privateStatic = BindingFlags.Static | BindingFlags.NonPublic;

                // 커브 필드의 배경 색상
                if (fiCurveBGColor == null)
                {
                    fiCurveBGColor = typeof(EditorGUI).GetField("kCurveBGColor", privateStatic);
                    defaultCurveBGColor = (Color)fiCurveBGColor.GetValue(null);
                }

                // Vector4 필드의 XYZW 레이블
                if (fiVector4FieldLables == null)
                {
                    fiVector4FieldLables = typeof(EditorGUI).GetField("s_XYZWLabels", privateStatic);
                    vector4FieldLables = fiVector4FieldLables.GetValue(null) as GUIContent[];
                }
            }
            private void LoadEditorInternalTextures()
            {
                if (playTexture == null)
                    playTexture = EditorGUIUtility.FindTexture("PlayButton@2x");

                if (pauseTexture == null)
                    pauseTexture = EditorGUIUtility.FindTexture("PauseButton@2x");
            }
            private void InitVariables()
            {
                isPlayMode = Application.isPlaying;
                LoadMaterialShaderData();

                if (m.isTimeModeSeconds)
                {
                    if (m.durationSeconds <= 0f)
                        currentTimeOrFrameRatio = 0f;
                    else
                    {
                        currentTimeOrFrameRatio = m.currentSeconds / m.durationSeconds;
                    }
                }
                else
                {
                    if (m.durationFrame <= 0)
                        currentTimeOrFrameRatio = 0f;
                    else
                    {
                        currentTimeOrFrameRatio = (float)m.currentFrame / m.durationFrame;
                    }
                }
            }
            private void InitMaterial()
            {
                LoadMaterialShaderData();
                LoadMaterialProperties();
            }
            private void LoadMaterialShaderData()
            {
                material = m.effectMaterial;
                shader = material != null ? material.shader : null;
            }
            private void InitStyles()
            {
                if (bigMinusButtonStyle == null)
                {
                    bigMinusButtonStyle = new GUIStyle("button")
                    {
                        fontSize = 20,
                        fontStyle = FontStyle.Bold
                    };
                }
                if (whiteTextButtonStyle == null)
                {
                    whiteTextButtonStyle = new GUIStyle("button")
                    {
#if UNITY_2019_3_OR_NEWER
                        fontStyle = FontStyle.Bold
#endif
                    };
                    whiteTextButtonStyle.normal.textColor = Color.white;
                    whiteTextButtonStyle.hover.textColor = Color.white;
                }
                if (blackTextButtonStyle == null)
                {
                    blackTextButtonStyle = new GUIStyle("button")
                    {
#if UNITY_2019_3_OR_NEWER
                        fontStyle = FontStyle.Bold
#endif
                    };
                    blackTextButtonStyle.normal.textColor = Color.black;
                    blackTextButtonStyle.hover.textColor = Color.black;
                }
                if (graphToggleButtonStyle == null)
                {
                    graphToggleButtonStyle = new GUIStyle("button")
                    {
#if UNITY_2019_3_OR_NEWER
                        fontStyle = FontStyle.Bold
#endif
                    };

                    // 실제 사용하는 곳에서 초기화
                }
                if (boldFoldoutStyle == null)
                {
                    boldFoldoutStyle = new GUIStyle(EditorStyles.foldout)
                    {
                        fontStyle = FontStyle.Bold
                    };
                }
                if (propertyAnimKeyTimeLabelStyle == null)
                {
                    propertyAnimKeyTimeLabelStyle = new GUIStyle(EditorStyles.label);
                    propertyAnimKeyTimeLabelStyle.normal.textColor = TimeColor;
                }
                if (whiteBoldLabelStyle == null)
                {
                    whiteBoldLabelStyle = new GUIStyle(EditorStyles.boldLabel);
                    whiteBoldLabelStyle.normal.textColor = Color.white;
                }
                if (yellowBoldLabelStyle == null)
                {
                    yellowBoldLabelStyle = new GUIStyle(EditorStyles.boldLabel);
                    yellowBoldLabelStyle.normal.textColor = Color.yellow;
                }
                if (whiteAnimKeyIndexLabelStyle == null)
                {
                    whiteAnimKeyIndexLabelStyle = new GUIStyle(EditorStyles.label);
                    whiteAnimKeyIndexLabelStyle.normal.textColor = Color.white;
                    whiteAnimKeyIndexLabelStyle.fontSize = 10;
                }
            }
            private void LoadMaterialProperties()
            {
                // NOTE : 새로 할당된 마테리얼이 null일 경우 여기로 진입 못함. 따라서 null 처리 불필요

                // 기존 애니메이션 정보 백업
                var backup = m.matPropertyList;

                int propertyCount = shader.GetPropertyCount();
                m.matPropertyList = new List<MaterialPropertyInfo>(propertyCount);

                // 새로운 쉐이더의 프로퍼티 목록 순회하면서 데이터 가져오기
                for (int i = 0; i < propertyCount; i++)
                {
                    ShaderPropertyType propType = shader.GetPropertyType(i);
                    if ((int)propType != 4) // 4 : Texture
                    {
                        string propName = shader.GetPropertyName(i);
#if UNITY_2019_3_OR_NEWER
                        int propIndex = shader.FindPropertyIndex(propName);
#else
                        int propIndex = i;
#endif
                        string dispName = shader.GetPropertyDescription(propIndex);

                        m.matPropertyList.Add(new MaterialPropertyInfo(material, propName, dispName, propType, propIndex));
                    }
                }

                int validPropCount = m.matPropertyList.Count;

                // 동일 쉐이더일 경우, 백업된 애니메이션에서 동일하게 존재하는 프로퍼티에 애니메이션 복제
                // 동일 쉐이더 여부는 이름으로 확인
                if (backup != null && backup.Count > 0 && backup[0].material.shader.name == shader.name)
                {
                    for (int i = 0; i < validPropCount; i++)
                    {
                        MaterialPropertyInfo cur = m.matPropertyList[i];
                        MaterialPropertyInfo found = backup.Find(x =>
                            x.__HasAnimation &&
                            x.propName == cur.propName &&
                            x.propType == cur.propType
                        );

                        // 각 마테리얼 프로퍼티의 현재 상태 복제
                        if (found != null)
                        {
                            cur.animKeyList = found.animKeyList; // 애니메이션 키들 복제
                            cur.enabled = found.enabled;
                            cur.__foldout = found.__foldout;
                            cur.__showAnimation = found.__showAnimation;
                            cur.__showGraph = found.__showGraph;
                            cur.__showIndexOrTime = found.__showIndexOrTime;

                            try
                            {
                                for (int j = 0; j < 4; j++)
                                    cur.__showVectorGraphs[j] = found.__showVectorGraphs[j];
                            }
                            catch { }
                        }
                    }
                }

                // 마테리얼 기본 값들 기억, 현재 값들 저장
                m.__materialDefaultValues = new MaterialPropertyAnimKey[validPropCount];
                m.__materialCurrentValues = new MaterialPropertyAnimKey[validPropCount];
                for (int i = 0; i < validPropCount; i++)
                {
                    var currentInfo = m.matPropertyList[i];
                    var defaultValue = m.__materialDefaultValues[i] = new MaterialPropertyAnimKey();
                    var currentValue = m.__materialCurrentValues[i] = new MaterialPropertyAnimKey();

                    switch (currentInfo.propType)
                    {
                        case ShaderPropertyType.Float:
                            defaultValue.floatValue = currentValue.floatValue =
                                material.GetFloat(currentInfo.propName);
                            break;

                        case ShaderPropertyType.Range:
                            defaultValue.floatValue = currentValue.floatValue =
                                material.GetFloat(currentInfo.propName);

                            currentValue.range = shader.GetPropertyRangeLimits(m.matPropertyList[i].__propIndex);

                            // Range 타입일 경우, MinMax 바뀌었을 수 있으니 모든 애니메이션 키마다 다시 적용
                            for (int j = 0; j < currentInfo.animKeyList.Count; j++)
                            {
                                currentInfo.animKeyList[j].range = currentValue.range;
                            }
                            break;

                        case ShaderPropertyType.Vector:
                            defaultValue.vector4 = currentValue.vector4 =
                                material.GetVector(currentInfo.propName);
                            break;

                        case ShaderPropertyType.Color:
                            defaultValue.color = currentValue.color =
                                material.GetColor(currentInfo.propName);
                            break;
                    }
                }
            }

            /// <summary> 현재 쉐이더의 이름에 따라 게임오브젝트 이름 변경 </summary>
            void SetGameObjectName()
            {
                if (m.effectMaterial != null)
                {
                    string name = m.effectMaterial.shader.name;
                    int slashIndex = name.LastIndexOf('/') + 1;
                    if (slashIndex > 0 && slashIndex < name.Length)
                        name = name.Substring(slashIndex);

                    m.gameObject.name = $"Screen Effect [{name}]";
                }
                else
                {
                    m.gameObject.name = "Screen Effect";
                }
            }
            #endregion
            /***********************************************************************
            *                               Mouse Events
            ***********************************************************************/
            #region .
            private static bool IsLeftMouseDown =>
                Event.current.type == EventType.MouseDown && Event.current.button == 0;
            private static bool IsLeftMouseDrag =>
                Event.current.type == EventType.MouseDrag && Event.current.button == 0;
            private static bool IsLeftMouseUp =>
                Event.current.type == EventType.MouseUp && Event.current.button == 0;

            private static bool IsRightMouseDown =>
                Event.current.type == EventType.MouseDown && Event.current.button == 1;
            private static bool IsRightMouseDrag =>
                Event.current.type == EventType.MouseDrag && Event.current.button == 1;
            private static bool IsRightMouseUp =>
                Event.current.type == EventType.MouseUp && Event.current.button == 1;

            private static bool IsMouseExitEditor =>
                Event.current.type == EventType.MouseLeaveWindow;

            private static Vector2 MousePosition => Event.current.mousePosition;
            #endregion
            /************************************************************************
             *                               Drawing Methods
             ************************************************************************/
            #region .
            /// <summary> 상단 옵션 그리기 </summary>
            private void DrawOptionFields()
            {
                int fieldCount;

                if (m.effectMaterial == null) fieldCount = 1;
                else
                {
                    fieldCount = 8;
#if SHOW_MATERIAL_NAME
                    fieldCount++;
#endif
                    if (isDurationZero) fieldCount--; // 설정 시간 또는 프레임이 0이면 종료 동작 표시하지 않음
                    else
                    {
                        if (m.IsTimeModeFrame)
                        {
                            fieldCount++; // 프레임 방식이면 기준 FPS 사용 여부 표시

                            if (m.useTargetFPS)
                                fieldCount++; // 타겟 FPS 필드(int)
                        }
                    }
                }
#if UNITY_2019_3_OR_NEWER
                const float FieldHeight = 20f;
#else
                const float FieldHeight = 18;
#endif

                RitoEditorGUI.FoldoutHeaderBox(ref m.__optionFoldout1, EngHan("Options", "설정"), fieldCount, FieldHeight);
                if (!m.__optionFoldout1) return;

                // 이펙트 마테리얼
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Effect Material", "이펙트 마테리얼"));

                    EditorGUI.BeginChangeCheck();
                    m.effectMaterial = EditorGUILayout.ObjectField(m.effectMaterial, typeof(Material), false) as Material;
                    if (EditorGUI.EndChangeCheck())
                    {
                        isMaterialChanged = true;

                        // 복제
                        if (m.effectMaterial != null)
                        {
                            m.effectMaterial = new Material(m.effectMaterial);
                        }

                        // 이름도 변경
                        SetGameObjectName();
                    }

                    if (m.effectMaterial != null)
                    {
                        // 마테리얼 재할당
                        if (RitoEditorGUI.DrawButtonLayout("Reload", Color.white, Color.black, 60f))
                        {
                            InitMaterial();
                            SetGameObjectName();
                        }
                    }
                }

                if (m.effectMaterial == null) return;
                //==============================================================

                // 마테리얼 이름 표시(Checkbox) - 게임오브젝트에 직접 이름 지정되도록 변경
#if SHOW_MATERIAL_NAME
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Show Material Name", "마테리얼 이름 표시"));
                    m.showMaterialNameInHierarchy = EditorGUILayout.Toggle(m.showMaterialNameInHierarchy);
                }
#endif

                // 우선순위(Int Slider)
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Priority", "우선순위"));
                    m.priority = EditorGUILayout.IntSlider(m.priority, -10, 10);
                }

                // 시간 계산 방식(Dropdown)
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Time Mode", "시간 계산 방식"));

                    EditorGUI.BeginChangeCheck();

                    int selected = EditorGUILayout.Popup(m.isTimeModeSeconds ? 0 : 1, isHangle ? TimeModesHan : TimeModesEng);
                    m.isTimeModeSeconds = selected == 0 ? true : false;

                    // 시간 계산 방식 변경 시, 초 <-> 프레임 간 변환 적용
                    if (EditorGUI.EndChangeCheck())
                    {
                        // 프레임 -> 초로 바꾼 경우
                        if (m.isTimeModeSeconds)
                        {
                            m.durationSeconds = m.durationFrame / m.targetFPS;

                            for (int i = 0; i < m.matPropertyList.Count; i++)
                            {
                                if (m.matPropertyList[i] == null || m.matPropertyList[i].__HasAnimation == false)
                                    continue;

                                var animKeyList = m.matPropertyList[i].animKeyList;
                                for (int j = 0; j < animKeyList.Count; j++)
                                {
                                    animKeyList[j].time = animKeyList[j].frame / m.targetFPS;
                                }
                            }

                            // 현재 시간 초기화
                            m.currentSeconds = 0;
                        }
                        // 초 -> 프레임으로 바꾼 경우
                        else
                        {
                            m.durationFrame = (m.durationSeconds * m.targetFPS);

                            for (int i = 0; i < m.matPropertyList.Count; i++)
                            {
                                if (m.matPropertyList[i] == null || m.matPropertyList[i].__HasAnimation == false)
                                    continue;

                                var animKeyList = m.matPropertyList[i].animKeyList;
                                for (int j = 0; j < animKeyList.Count; j++)
                                {
                                    animKeyList[j].frame = (animKeyList[j].time * m.targetFPS);
                                }
                            }

                            // 현재 프레임 초기화
                            m.currentFrame = 0;
                        }
                    }
                }

                isDurationZero = false;

                // 지속시간 : 초/프레임
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(m.isTimeModeSeconds ?
                        EngHan("Duration Time", "지속 시간(초)") : EngHan("Duration Frame", "지속 시간(프레임)"));

                    // 1. 시간 계산 방식이 초 일경우
                    if (m.isTimeModeSeconds)
                    {
                        m.durationSeconds.RefClamp_000();
                        float prevDurationSec = m.durationSeconds;

                        Color col = GUI.color;
                        if (m.durationSeconds <= 0f)
                        {
                            GUI.color = Color.cyan;
                            isDurationZero = true;
                        }

                        // 지속시간 필드에 이름 부여
                        GUI.SetNextControlName("DurationField");

                        m.durationSeconds = EditorGUILayout.DelayedFloatField(m.durationSeconds); // DelayedField : 엔터 치면 적용
                        if (m.durationSeconds < 0f) m.durationSeconds = 0f;

                        GUI.color = col;

                        // Duration 변경 시 동작
                        if (prevDurationSec != m.durationSeconds && m.durationSeconds > 0f)
                        {
                            // [1] 비율을 유지하면서 애니메이션 키들의 Time 변경
                            if (m.__durationChangeActionPopupIndex == 0)
                            {
                                float changeRatio = m.durationSeconds / prevDurationSec;

                                for (int i = 0; i < m.matPropertyList.Count; i++)
                                {
                                    if (m.matPropertyList[i].__HasAnimation == false)
                                        continue;

                                    var animKeyList = m.matPropertyList[i].animKeyList;
                                    for (int j = 0; j < animKeyList.Count; j++)
                                    {
                                        // 시작 키 : 0프레임
                                        if (j == 0)
                                            continue;
                                        // 종료 키 : 마지막 프레임
                                        else if (j == animKeyList.Count - 1)
                                            animKeyList[j].time = m.durationSeconds;
                                        // 나머지 키 : 계산
                                        else
                                            animKeyList[j].time *= changeRatio;
                                    }
                                }
                            }
                            // [2] 자르기
                            else
                            {
                                // 공통 : 각 애니메이션들의 마지막 키 시간만 Duration으로 바꿔주기
                                for (int i = 0; i < m.matPropertyList.Count; i++)
                                {
                                    if (m.matPropertyList[i].__HasAnimation == false)
                                        continue;

                                    var animKeyList = m.matPropertyList[i].animKeyList;
                                    animKeyList.Last().time = m.durationSeconds;
                                }

                                // [2-2] 지속 시간이 짧아진 경우
                                if (prevDurationSec > m.durationSeconds)
                                {
                                    // 바뀐 지속 시간보다 긴 키들은 제거
                                    for (int i = 0; i < m.matPropertyList.Count; i++)
                                    {
                                        if (m.matPropertyList[i].__HasAnimation == false)
                                            continue;

                                        var animKeyList = m.matPropertyList[i].animKeyList;
                                        animKeyList.RemoveAll(key => key.time > m.durationSeconds);
                                    }
                                }

                            }
                        }
                    }
                    // 2. 시간 계산 방식이 프레임일 경우
                    else
                    {
                        float prevDurationFrame = m.durationFrame;

                        Color col = GUI.color;
                        if (m.durationFrame == 0)
                        {
                            GUI.color = Color.cyan;
                            isDurationZero = true;
                        }

                        // 지속시간 필드에 이름 부여
                        GUI.SetNextControlName("DurationField");

                        m.durationFrame = EditorGUILayout.DelayedIntField((int)m.durationFrame); // DelayedField
                        if (m.durationFrame < 0) m.durationFrame = 0;

                        GUI.color = col;

                        // Duration 변경 시 동작
                        if (prevDurationFrame != m.durationFrame && m.durationSeconds > 0f)
                        {
                            // [1] 비율을 유지하면서 애니메이션 키들의 Frame 변경
                            if (m.__durationChangeActionPopupIndex == 0)
                            {
                                float changeRatio = (float)m.durationFrame / prevDurationFrame;

                                for (int i = 0; i < m.matPropertyList.Count; i++)
                                {
                                    if (m.matPropertyList[i].__HasAnimation == false)
                                        continue;

                                    var animKeyList = m.matPropertyList[i].animKeyList;
                                    for (int j = 0; j < animKeyList.Count; j++)
                                    {
                                        // 시작 키 : 0프레임
                                        if (j == 0)
                                            continue;
                                        // 종료 키 : 마지막 프레임
                                        else if (j == animKeyList.Count - 1)
                                            animKeyList[j].frame = m.durationFrame;
                                        // 나머지 키 : 계산
                                        else
                                            animKeyList[j].frame = (int)(animKeyList[j].frame * changeRatio);
                                    }
                                }
                            }
                            // [2] 자르기
                            else
                            {
                                // 공통 : 각 애니메이션들의 마지막 키 프레임만 Duration으로 바꿔주기
                                for (int i = 0; i < m.matPropertyList.Count; i++)
                                {
                                    if (m.matPropertyList[i].__HasAnimation == false)
                                        continue;

                                    var animKeyList = m.matPropertyList[i].animKeyList;
                                    animKeyList.Last().frame = m.durationFrame;
                                }

                                // [2-2] 지속 시간이 짧아진 경우
                                if (prevDurationFrame > m.durationFrame)
                                {
                                    // 바뀐 지속 시간보다 긴 키들은 제거
                                    for (int i = 0; i < m.matPropertyList.Count; i++)
                                    {
                                        if (m.matPropertyList[i].__HasAnimation == false)
                                            continue;

                                        var animKeyList = m.matPropertyList[i].animKeyList;
                                        animKeyList.RemoveAll(key => key.frame > m.durationFrame);
                                    }
                                }

                            }
                        }
                    }
                }

                if (isDurationZero/* && GUI.GetNameOfFocusedControl() != "DurationField"*/)
                {
                    Rect durationRect = GUILayoutUtility.GetLastRect();
                    durationRect.xMin += durationRect.width * 0.65f;
                    EditorGUI.LabelField(durationRect, EngHan("Looping", "상시 지속"), whiteBoldLabelStyle);
                }

                // 지속시간 변경 시 동작
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(
                            EngHan("Duration Change Action", "지속 시간 변경 시 동작"));

                    m.__durationChangeActionPopupIndex =
                        EditorGUILayout.Popup(m.__durationChangeActionPopupIndex,
                            isHangle ? DurationChangeActionHan : DurationChangeActionEng);
                }

                // 프레임 전용 설정
                if (m.IsTimeModeFrame && !isDurationZero)
                {
                    // 타겟 프레임 설정 여부 (Checkbox)
                    using (new RitoEditorGUI.HorizontalMarginScope())
                    {
                        RitoEditorGUI.DrawPrefixLabelLayout(
                            EngHan("Use Target FPS", "기준 FPS 설정"));

                        m.useTargetFPS = EditorGUILayout.Toggle(m.useTargetFPS);
                    }

                    // 타겟 FPS 설정 (Int Field)
                    if (m.useTargetFPS)
                    {
                        using (new RitoEditorGUI.HorizontalMarginScope())
                        {
                            RitoEditorGUI.DrawPrefixLabelLayout(
                                EngHan("Target FPS", "기준 FPS"));

                            m.targetFPS = EditorGUILayout.IntField((int)m.targetFPS);

                            // 최솟값 설정
                            if (m.targetFPS < 15)
                                m.targetFPS = 15;
                        }
                    }
                }

                if (!isDurationZero)
                {
                    using (new RitoEditorGUI.HorizontalMarginScope())
                    {
                        RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Stop Action", "종료 동작"));
                        if (isHangle)
                        {
                            m.stopAction = (StopAction)EditorGUILayout.Popup((int)m.stopAction, StopActionsHangle);
                        }
                        else
                        {
                            m.stopAction = (StopAction)EditorGUILayout.EnumPopup(m.stopAction);
                        }
                    }
                }


                // 타임스케일 영향 받을지 여부
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Affected by Timescale", "타임스케일 영향 받기"));
                    m.affectedByTimescale = EditorGUILayout.Toggle(m.affectedByTimescale);
                }

                // 재생 속도(float slider)
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Animation Play Speed", "애니메이션 재생 속도"));

                    Color col = GUI.color;
                    if (m.animPlaySpeed != 1f)
                    {
                        GUI.color = Color.cyan * 1.5f;
                    }
                    m.animPlaySpeed = EditorGUILayout.Slider(m.animPlaySpeed, 0f, 2f);

                    GUI.color = col;
                }

#if !UNITY_2019_3_OR_NEWER
                EditorGUILayout.Space();
#endif
            }

            private void DrawEditorOptions()
            {
                RitoEditorGUI.FoldoutHeaderBox(ref m.__optionFoldout2, EngHan("Editor Options", "에디터 기능"), 2);
                if (m.__optionFoldout2 == false)
                    return;

                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Edit Mode", "편집 모드"));
                    m.__editMode = EditorGUILayout.Toggle(m.__editMode);
                }

                EditorGUI.BeginDisabledGroup(!m.__editMode);
                using (new RitoEditorGUI.HorizontalMarginScope())
                {
                    if (m.isTimeModeSeconds)
                        RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Current Time", "경과 시간"), m.__editMode ? TimeColor : Color.white);
                    else
                        RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Current Frane", "경과 프레임"), m.__editMode ? TimeColor : Color.white);

                    Color col = GUI.color;
                    if (m.__editMode)
                        GUI.color = TimeColor;

                    if (m.isTimeModeSeconds)
                        m.currentSeconds = EditorGUILayout.Slider(m.currentSeconds, 0f, m.durationSeconds);
                    else
                    {
                        if (m.__editMode)
                            m.currentFrame = EditorGUILayout.IntSlider((int)m.currentFrame, 0, (int)m.durationFrame);
                        else
                            // 편집모드가 아닐 경우, 현재 프레임이 정수 캐스팅의 영향 받지 않도록
                            EditorGUILayout.IntSlider((int)m.currentFrame, 0, (int)m.durationFrame);
                    }

                    GUI.color = col;
                }
                EditorGUI.EndDisabledGroup();
            }

            /// <summary> 현재 복제된 마테리얼의 수정 가능한 프로퍼티 목록 표시하기 </summary>
            private void DrawCopiedMaterialProperties()
            {
                RitoEditorGUI.FoldoutHeaderBox(ref m.__matPropListFoldout, EngHan("Material Properties", "마테리얼 프로퍼티 목록"),
                    m.matPropertyList.Count);

                if (!m.__matPropListFoldout)
                    return;

                EditorGUI.BeginDisabledGroup(isPlayMode && !isDurationZero && m.gameObject.activeSelf && !m.__editMode);

                for (int i = 0; i < m.matPropertyList.Count; i++)
                {
                    var mp = m.matPropertyList[i];
                    if ((int)mp.propType == 4) // 4 : Texture
                        continue;

                    MaterialPropertyAnimKey currentMatValue = m.__materialCurrentValues[i];

                    Color currentColor = mp.enabled ? EnabledColor : Color.gray;
                    bool hasAnimation = mp.__HasAnimation;

                    EditorGUILayout.BeginHorizontal();

                    RitoEditorGUI.DrawHorizontalSpace(4f);

                    RitoEditorGUI.DrawPrefixLabelLayout(mp.__displayName,
                        hasAnimation ? currentColor : Color.white, 0.25f);

                    Color guiColor = GUI.color;
                    if (hasAnimation)
                        GUI.color = currentColor;

                    // 레이블 하얗게 만들기
                    Color colLN = EditorStyles.label.normal.textColor;
                    EditorStyles.label.normal.textColor = Color.white;

                    switch (mp.propType)
                    {
                        case ShaderPropertyType.Float:
                            {
                                // 지속 시간이 무제한인 경우, 플레이모드 변경사항 저장
                                if (isDurationZero)
                                {
                                    currentMatValue.floatValue = EditorGUILayout.FloatField(currentMatValue.floatValue);
                                }
                                // 지속 시간이 유한한 경우, 플레이모드 변경사항 저장하지 않음
                                else
                                {
                                    currentMatValue.floatValue = EditorGUILayout.FloatField(material.GetFloat(mp.propName));
                                }

                                material.SetFloat(mp.propName, currentMatValue.floatValue);
                            }
                            break;
                        case ShaderPropertyType.Range:
                            {
                                if (isDurationZero)
                                {
                                    currentMatValue.floatValue =
                                        EditorGUILayout.Slider(currentMatValue.floatValue, currentMatValue.min, currentMatValue.max);
                                }
                                else
                                {
                                    currentMatValue.floatValue =
                                        EditorGUILayout.Slider(material.GetFloat(mp.propName), currentMatValue.min, currentMatValue.max);
                                }

                                material.SetFloat(mp.propName, currentMatValue.floatValue);
                            }
                            break;
                        case ShaderPropertyType.Vector:
                            {
                                if (isDurationZero)
                                {
                                    currentMatValue.vector4 = EditorGUILayout.Vector4Field("", currentMatValue.vector4);
                                }
                                else
                                {
                                    currentMatValue.vector4 = EditorGUILayout.Vector4Field("", material.GetVector(mp.propName));
                                }

                                material.SetVector(mp.propName, currentMatValue.vector4);
                            }
                            break;
                        case ShaderPropertyType.Color:
                            {
                                if (isDurationZero)
                                {
                                    currentMatValue.color = EditorGUILayout.ColorField(currentMatValue.color);
                                }
                                else
                                {
                                    currentMatValue.color = EditorGUILayout.ColorField(material.GetColor(mp.propName));
                                }

                                material.SetColor(mp.propName, currentMatValue.color);
                            }
                            break;
                    }

                    EditorStyles.label.normal.textColor = colLN;

                    GUI.color = guiColor;

                    RitoEditorGUI.DrawHorizontalSpace(4f);

                    // 각 프로퍼티마다 리셋 버튼 - 클릭 시 백업된 기본값으로 마테리얼 프로퍼티 값 변경
                    if (RitoEditorGUI.DrawButtonLayout("R", Color.magenta, 20f, 18f))
                    {
                        switch (mp.propType)
                        {
                            case ShaderPropertyType.Float:
                            case ShaderPropertyType.Range:
                                m.__materialCurrentValues[i].floatValue = m.__materialDefaultValues[i].floatValue;
                                material.SetFloat(mp.propName, m.__materialDefaultValues[i].floatValue);
                                break;

                            case ShaderPropertyType.Vector:
                                m.__materialCurrentValues[i].vector4 = m.__materialDefaultValues[i].vector4;
                                material.SetVector(mp.propName, m.__materialDefaultValues[i].vector4);
                                break;

                            case ShaderPropertyType.Color:
                                m.__materialCurrentValues[i].color = m.__materialDefaultValues[i].color;
                                material.SetColor(mp.propName, m.__materialDefaultValues[i].color);
                                break;
                        }
                    }

                    RitoEditorGUI.DrawHorizontalSpace(4f);

                    // 프로퍼티에 애니메이션 존재할 경우 : 활성화, 제거 버튼
                    if (hasAnimation)
                    {
                        string enableButtonString = mp.enabled ? "E" : "D";

                        if (RitoEditorGUI.DrawButtonLayout(enableButtonString, currentColor, 22f, 18f))
                            mp.enabled = !mp.enabled;

                        if (RitoEditorGUI.DrawButtonLayout("-", Color.red * 1.5f, 20f, 18f))
                            mp.Edt_RemoveAllAnimKeys();
                    }
                    // 애니메이션 없을 경우 : 추가 버튼
                    else
                    {
#if UNITY_2017_9_OR_NEWER
                        const float PlusButtonWidth = 42f;
#else
                        const float PlusButtonWidth = 46f;
#endif
                        bool addButton = RitoEditorGUI.DrawButtonLayout("+", Color.green * 1.5f, PlusButtonWidth, 18f);
                        if (addButton)
                        {
                            mp.Edt_AddInitialAnimKeys(m.isTimeModeSeconds ? m.durationSeconds : m.durationFrame, m.isTimeModeSeconds);
                        }
                    }

                    RitoEditorGUI.DrawHorizontalSpace(4f);

                    EditorGUILayout.EndHorizontal();
                }

                EditorGUI.EndDisabledGroup();
            }

            /// <summary> 프로퍼티 애니메이션 모두 그리기 </summary>
            private void DrawMaterialPropertyAnimKeyList()
            {
                if (isDurationZero)
                {
                    int fs = EditorStyles.helpBox.fontSize;
                    EditorStyles.helpBox.fontSize = 12;

                    EditorGUILayout.HelpBox(
                        EngHan("Cannot create animations if duration is 0.", "애니메이션을 적용하려면 지속 시간을 설정해야 합니다."),
                        MessageType.Info);

                    EditorStyles.helpBox.fontSize = fs;

                    return;
                }

                for (int i = 0; i < m.matPropertyList.Count; i++)
                {
                    if (m.matPropertyList[i].__HasAnimation)
                    {
                        DrawPropertyAnimation(m.matPropertyList[i], () =>
                        {
                            // [-] 버튼 클릭하면 해당 프로퍼티에서 애니메이션 키들 싹 제거
                            m.matPropertyList[i].Edt_RemoveAllAnimKeys();
                        }
                        );

                        EditorGUILayout.Space();

                        if (m.matPropertyList[i].__foldout)
                        {
                            EditorGUILayout.Space();
                            EditorGUILayout.Space();
                        }
                    }
                }
            }


            GUIStyle animationFoldoutHeaderStyle;

            // 그래프 너비 옵션
            const float GraphToggleButtonWidth = 120f;
            const float GraphMarginLeft = 4f;
            const float GraphMarginRight = 4f;

            // 그래프 높이 옵션
            const float GraphToggleButtonMarginTop = 2f;    // 최상단 ~ 토글 버튼 사이 간격
            const float GraphToggleButtonHeight = 20f;      // 토글 버튼 높이
            const float GraphToggleButtonMarginBottom = 2f; // 토글 버튼 ~ 그래프 사이 간격

            const float GraphTimestampHeightOnTop = 20f; // 그래프 상단 현재 시간 표시
            const float GraphHeight = 80f;               // 그래프 높이
            const float GraphMarginBottom = 20f;         // 그래프 하단 여백

            const float RGBAButtonHeight = 20f;          // 벡터, 색상 XYZW 또는 RGBA 버튼 높이
            const float RGBAButtonBottomMargin = 2f;

            // 애니메이션 표시 버튼 옵션
            const float AnimationToggleButtonWidth = 120f;      // 애니메이션 표시 토글 버튼 너비

            const float AnimationToggleButtonMarginTop = 4f;    // 애니메이션 표시 토글 버튼 상단 여백
            const float AnimationToggleButtonHeight = 20f;      // 애니메이션 표시 토글 버튼 높이
            const float AnimationToggleButtonMarginBottom = 4f; // 애니메이션 표시 토글 버튼 ~ 애니메이션 사이 간격

            /// <summary> 프로퍼티 하나의 애니메이션 키 모두 그리기 </summary>
            private void DrawPropertyAnimation(MaterialPropertyInfo mp, Action removeAction)
            {
                ref bool enabled = ref mp.enabled;
                bool isFloatOrRangeType = mp.propType == ShaderPropertyType.Float || mp.propType == ShaderPropertyType.Range;
                bool isVectorOrColorType = !isFloatOrRangeType;
                bool isColorType = mp.propType == ShaderPropertyType.Color;
                bool isVectorType = mp.propType == ShaderPropertyType.Vector;

                // NOTE : GraphToggleButton, AnimationToggleButton은 항상 그림

                // NOTE : showGraph가 true이면
                //  - Float/Range : 그래프를 그림
                //  - Vector/Color : RGBA 토글 버튼을 그림
                //    - showVectorGraphs가 true여야 그래프를 그림

                // 그래프 그릴지 여부 확인
                bool showGraph = mp.__showGraph;
                bool showVectorGraphs = false; // 벡터 또는 컬러일 경우, RGBA 토글이 하나라도 활성화 되어 있는지 여부
                bool showTimeStamp = false;

                if (showGraph)
                {
                    // 벡터 또는 색상 - 그래프 표시 여부
                    if (isVectorOrColorType)
                    {
                        for (int i = 0; i < mp.__showVectorGraphs.Length; i++)
                            showVectorGraphs |= mp.__showVectorGraphs[i];
                    }

                    // 타임스탬프 표시 여부 결정
                    // float
                    if (isFloatOrRangeType)
                    {
                        showTimeStamp = isPlayMode;
                    }
                    // 벡터, 색상
                    else
                    {
                        showTimeStamp = isPlayMode && showVectorGraphs;
                    }
                }

                // 그래프 표시 토글 버튼 최종 높이
                float graphToggleButtonTotalHeight =
                    GraphToggleButtonMarginTop + GraphToggleButtonHeight + GraphToggleButtonMarginBottom;

                // 그래프 최종 높이
                float graphTotalHeight = 0f;

                // 그래프 표시 허용하는 경우
                if (showGraph)
                {
                    // 벡터 또는 색상 타입인 경우, RGBA 버튼 높이 확보
                    // => 인덱스/시간 표시 버튼 추가로 항상 여백 확보하도록 변경
                    //if (isVectorOrColorType)
                    {
                        graphTotalHeight += RGBAButtonHeight + RGBAButtonBottomMargin;
                    }

                    // 그래프 상단 타임스탬프
                    if (showTimeStamp)
                        graphTotalHeight += GraphTimestampHeightOnTop;

                    // 그래프 기본 높이
                    if (isFloatOrRangeType)
                    {
                        graphTotalHeight += GraphHeight + GraphMarginBottom;
                    }
                    else
                    {
                        if (showVectorGraphs)
                            graphTotalHeight += GraphHeight + GraphMarginBottom;
                    }
                }

                // 애니메이션 표시 토글 버튼 최종 높이
                float animToggleButtonTotalHeight = AnimationToggleButtonMarginTop + AnimationToggleButtonHeight + AnimationToggleButtonMarginBottom;

                // 애니메이션 최종 높이 합
                float animContentsTotalHeight = 0f;

                if (mp.__showAnimation)
                {
                    // 애니메이션 키 하나당 요소 개수
                    int countPerAnimKey = isColorType ? 3 : 2;

                    // 애니메이션의 요소 개수
                    int contentCount = countPerAnimKey * mp.animKeyList.Count;

                    // 애니메이션의 + 버튼 개수
                    int plusButtonCount = mp.animKeyList.Count - 1;

#if UNITY_2019_3_OR_NEWER
                    float heightPerElement = isVectorType ? 22f : 21f;
                    float heightPerButton = isColorType ? 23f : 22f;
#else
                    float heightPerElement = isVectorType ? 21f : 21f;
                    float heightPerButton = isColorType ? 17f : 20f;
#endif
                    animContentsTotalHeight = contentCount * heightPerElement + plusButtonCount * heightPerButton;
                }

                // 최종 Foldout 높이 결정
                float foldoutContHeight =
                    graphToggleButtonTotalHeight + // 그래프 토글 버튼
                    graphTotalHeight +             // 그래프
                    animToggleButtonTotalHeight +  // 애니메이션 토글 버튼
                    animContentsTotalHeight;       // 애니메이션 전체 높이

                // Foldout 스타일 설정
                if (animationFoldoutHeaderStyle == null)
                    animationFoldoutHeaderStyle = new GUIStyle(EditorStyles.label);
                animationFoldoutHeaderStyle.normal.textColor =
                animationFoldoutHeaderStyle.onNormal.textColor = enabled ? Color.black : Color.gray;
                animationFoldoutHeaderStyle.fontStyle = FontStyle.Bold;

                string headerText = $"{mp.__displayName} [{mp.propType}]";

                Color headerBgColor = enabled ? new Color(0f, 0.8f, 0.8f) : new Color(0.1f, 0.1f, 0.1f);
                Color enableButtonTextColor = Color.white;
                Color enableButtonBgColor = enabled ? Color.black : Color.gray;
                Color removeButtonColor = Color.red * 1.8f;

                // Draw Foldout
                RitoEditorGUI.AnimationFoldoutHeaderBox(ref mp.__foldout, headerText, foldoutContHeight, animationFoldoutHeaderStyle,
                    headerBgColor, enableButtonBgColor, enableButtonTextColor, removeButtonColor,
                    ref mp.enabled, out bool removePressed);

                if (removePressed)
                {
                    removeAction();
                }

                if (!mp.__foldout) return;
                // ======================= Foldout 펼쳐져 있을 때 ======================= //

                // ================== 그래프 토글 버튼 : 항상 그림 =============== //
                // [1] 버튼 상단 여백
                GUILayoutUtility.GetRect(1f, GraphToggleButtonMarginTop);

                // [2] 그래프 토글 버튼 영역
                Rect graphBtnRect = GUILayoutUtility.GetRect(1f, GraphToggleButtonHeight);

                // 토글 버튼 그리기
                DrawGraphToggleButton(mp, graphBtnRect);

                // [3] 버튼 하단 여백
                GUILayoutUtility.GetRect(1f, GraphToggleButtonMarginBottom);

                // ================== 그래프 그리기 =============== //
                Rect graphRect = default;

                // == 그래프 표시 허용 상태 ==
                if (showGraph)
                {
                    // 그래프 토글 버튼 영역 좌측 : 재생/정지 버튼
                    if (isPlayMode)
                    {
                        DrawPlayAndStopButtons(graphBtnRect);
                    }

                    // [4] 그래프 상단 토글 버튼들 그리기

                    // [4-1] RGBA 버튼 영역
                    Rect rgbaButtonRect = GUILayoutUtility.GetRect(1f, RGBAButtonHeight);

                    // [4-2] RGBA 버튼 하단 여백
                    GUILayoutUtility.GetRect(1f, RGBAButtonBottomMargin);

                    // 좌측 : 인덱스 or 시간/프레임 토글
                    DrawIndexOrTimeToggleButton(mp, rgbaButtonRect);

                    // 중앙 : RGBA 토글 버튼 + 우측 그라디언트/그래프 토글 버튼
                    if (isVectorOrColorType)
                        DrawRGBAToggleButtons(mp, rgbaButtonRect);


                    // 그래프 그리기
                    if (isFloatOrRangeType || (isVectorOrColorType && showVectorGraphs))
                    {
                        // [5] 그래프 상단 시간 표시
                        if (showTimeStamp)
                        {
                            Rect graphTimeRect = GUILayoutUtility.GetRect(1f, GraphTimestampHeightOnTop);
                            DrawTimestampOverGraph(graphTimeRect);
                        }

                        // [6] 그래프 영역 확보
                        graphRect = GUILayoutUtility.GetRect(1f, GraphHeight);
                        graphRect.xMin += GraphMarginLeft;
                        graphRect.xMax -= GraphMarginRight;

                        // [7] 하단 여백
                        GUILayoutUtility.GetRect(1f, GraphMarginBottom);

                        // [8] 그래프 영역 마우스 이벤트 처리
                        //  - 그래프 클릭 방지
                        //  - 플레이 & 편집 모드 => 진행도 설정
                        HandleMouseEventInGraphRect(graphRect);

                        bool needToDrawGradient = isColorType && mp.__isGradientView;

                        // [9] 그래프 그리기
                        if (isFloatOrRangeType)
                            DrawFloatGraph(mp, graphRect);
                        else
                        {
                            // 컬러 타입 && 그라디언트 뷰
                            if (needToDrawGradient)
                                DrawColorGradientView(mp, graphRect);
                            else
                                DrawVector4OrColorGraph(mp, graphRect);
                        }

                        // [10] 그래프에 X 좌표마다 강조 표시
                        //  - 현재 등록된 애니메이션 키들 위치
                        //  - 현재 재생 중인 위치
                        DrawMarkersOnGraphRect(mp, graphRect);
                    }
                }


                // ==================== 애니메이션 토글 버튼 그리기 ====================== //
                // [1] 버튼 상단 여백 확보
                GUILayoutUtility.GetRect(1f, AnimationToggleButtonMarginTop);

                // [2] 버튼 영역 확보
                Rect animToggleButtonRect = GUILayoutUtility.GetRect(1f, AnimationToggleButtonHeight);

                // 버튼 그리기
                DrawAnimationToggleButton(mp, animToggleButtonRect);

                // [3] 버튼 하단 여백 확보
                GUILayoutUtility.GetRect(1f, AnimationToggleButtonMarginBottom);


                if (mp.__showAnimation == false) return;
                if (mp.__isKeyListDirty)
                {
                    mp.__isKeyListDirty = false;
                    return;
                }
                // ======================== 애니메이션 키들 그리기 ========================== //
                int addNewAnimKey = -1;
                var animKeyList = mp.animKeyList;

                for (int i = 0; i < animKeyList.Count; i++)
                {
                    // 애니메이션 키 한개 그리기
                    DrawEachAnimKey(mp, animKeyList[i], i);

                    // 애니메이션 키 사이사이 [+] 버튼 : 새로운 키 추가
                    if (i < animKeyList.Count - 1)
                    {
                        EditorGUILayout.BeginHorizontal();

                        const float ButtonWidth = 24f;

                        // 버튼 중앙 정렬
                        RitoEditorGUI.DrawHorizontalSpace((EditorGUIUtility.currentViewWidth) * 0.5f - ButtonWidth);
                        if (RitoEditorGUI.DrawPlusButtonLayout(ButtonWidth)) addNewAnimKey = i;

                        EditorGUILayout.EndHorizontal();
                    }
                }

                // 새로운 애니메이션 키 추가
                if (addNewAnimKey > -1)
                {
                    mp.Edt_AddNewAnimKey(addNewAnimKey, m.isTimeModeSeconds);
                }
            }

            /// <summary> 그래프 내 마우스 이벤트 처리 </summary>
            private void HandleMouseEventInGraphRect(in Rect graphRect)
            {
                Event current = Event.current;
                Vector2 mPos = current.mousePosition;

                // 그래프 영역을 클릭할 경우, 재생 멈추고 진행도 변경
                if (graphRect.Contains(mPos) && (current.type == EventType.MouseDown || current.type == EventType.MouseDrag))
                {
                    if (isPlayMode)
                    {
                        // 편집 모드가 아닐 경우, 마우스 클릭 시 편집 모드 진입
                        m.__editMode = true;

                        // 상태 고정 해제
                        m.keepCurrentState = false;

                        // 마우스 클릭 좌표에 따라 진행도 변경
                        // X : 0. ~ 1.
                        float ratio = (mPos.x - graphRect.x) / graphRect.width;

                        // 진행도 변경
                        if (m.isTimeModeSeconds)
                            m.currentSeconds = m.durationSeconds * ratio;
                        else
                            m.currentFrame = (m.durationFrame * ratio);
                    }

                    // 그래프 마우스 클릭 방지
                    current.Use(); // Set Handled
                }
            }

            /// <summary> 그래프 상단에 현재 시간 또는 프레임 표시 </summary>
            private void DrawTimestampOverGraph(Rect graphTimeRect)
            {
                graphTimeRect.xMin += GraphMarginLeft;
                graphTimeRect.xMax -= GraphMarginRight;

                float totalWidth = graphTimeRect.width;
                float xBegin = graphTimeRect.x;

                const float XPosAdjustment = 11f;
#if UNITY_2019_3_OR_NEWER
                const float XPosClampRight = 28f;
#else
                const float XPosClampRight = 32f;
#endif

                float xMin = xBegin + (currentTimeOrFrameRatio * totalWidth) - XPosAdjustment;
                xMin = Mathf.Max(xBegin, xMin);                              // Clamp Left : xBegin
                xMin = Mathf.Min(xMin, graphTimeRect.xMax - XPosClampRight); // Clamp Right

                graphTimeRect.xMin = xMin;

                if (m.isTimeModeSeconds)
                    EditorGUI.LabelField(graphTimeRect, $"{m.currentSeconds:F2}", yellowBoldLabelStyle);
                else
                    EditorGUI.LabelField(graphTimeRect, $"{m.currentFrame:F0}", yellowBoldLabelStyle);
            }

            MaterialPropertyAnimKey selectedAnimKey; // 이동 대상 키
            float mouseClickPosX;
            float selectedKeyTimeOrFrame; // 선택된 순간의 대상 time 또는 frame 값
            float leftKeyTimeOrFrame;  // 선택 대상 왼쪽의 time/frame
            float rightKeyTimeOrFrame; // 선택 대상 오른쪽의 time/frame

            MaterialPropertyAnimKey animKeyToRemove; // 제거 대상 키

            /// <summary> 그래프 내의 특정 위치들을 강조 표시하기 </summary>
            private void DrawMarkersOnGraphRect(MaterialPropertyInfo mp, in Rect graphRect)
            {
                bool shouldDrawGradient = mp.propType == ShaderPropertyType.Color && mp.__isGradientView;

                Rect markerRect = new Rect(graphRect);
                float baseXPos = graphRect.x;
                float totalWidth = graphRect.width - 2f;
                markerRect.width = 2f;

                // 마우스 인식 영역 높이
                const float MouseRectHeight = 18f;

                // 마우스로 키 움직이는 이벤트가 허용되는 경우
                bool animKeyMoveEventAllowed = m.gameObject.activeSelf == false || m.__editMode || isPlayMode == false;

                // 키 영역 중 한군데라도 마우스가 올라갔는지 여부
                bool isOverAnyMouseRects = false;

                // 1. 애니메이션 키 위치들 표시
                var animKeyList = mp.animKeyList;
                for (int i = 0; i < animKeyList.Count; i++)
                {
                    var cur = animKeyList[i];
                    float t = m.isTimeModeSeconds ?
                        cur.time / m.durationSeconds :
                        (float)cur.frame / m.durationFrame;

                    // 1-1. 그래프 위에 마커 그리기
                    if (i > 0 && i < animKeyList.Count - 1)
                    {
                        Rect r = new Rect(markerRect);
                        r.x = baseXPos + (t * totalWidth);

                        if (!shouldDrawGradient)
                            EditorGUI.DrawRect(r, new Color(1, 1, 1, 0.2f));
                    }

                    // 1-2. 그래프 하단에 키프레임 표시
                    {
                        // 1-2-1. 작은 네모네모
                        Rect keyRect = new Rect(graphRect);
                        keyRect.width = 2f;
                        keyRect.height = 6f;
                        keyRect.y = graphRect.yMax;
                        keyRect.x += graphRect.width * t - 1f;

                        EditorGUI.DrawRect(keyRect, Color.white);

                        // 마우스 이벤트
                        if (animKeyMoveEventAllowed && i > 0 && i < animKeyList.Count - 1)
                        {
                            // 마우스 인식 영역
                            Rect mouseRect = new Rect(keyRect);
                            mouseRect.height = MouseRectHeight;
                            mouseRect.x -= 3f;
                            mouseRect.width += 6f;

                            bool mouseEntered = mouseRect.Contains(MousePosition);

                            // 키 영역 중 하나라도 마우스가 올라감
                            if (mouseEntered)
                                isOverAnyMouseRects = true;

                            EditorGUIUtility.AddCursorRect(mouseRect, MouseCursor.Link);

                            // 우클릭 시 제거 대상으로 등록
                            if (selectedAnimKey == null && animKeyToRemove == null && IsRightMouseDown && mouseEntered)
                            {
                                animKeyToRemove = cur;
                            }

                            // 작은 키 네모네모에 마우스 좌클릭 : 이동 타겟으로 설정
                            if (animKeyToRemove == null && selectedAnimKey == null && IsLeftMouseDown && mouseEntered)
                            {
                                selectedAnimKey = cur;

                                mouseClickPosX = MousePosition.x;
                                selectedKeyTimeOrFrame = m.isTimeModeSeconds ? cur.time : cur.frame;
                                leftKeyTimeOrFrame = m.isTimeModeSeconds ? animKeyList[i - 1].time : animKeyList[i - 1].frame;
                                rightKeyTimeOrFrame = m.isTimeModeSeconds ? animKeyList[i + 1].time : animKeyList[i + 1].frame;

                                //Debug.Log($"이동 대상 : {i}");
                            }
                        }

                        // 1-2-2. 인덱스 레이블
                        Rect indexLabelRect = new Rect(keyRect);
                        indexLabelRect.y += 8f;
                        indexLabelRect.height = 15f;

                        string label;

                        if (mp.__showIndexOrTime)
                        {
                            label = $"{i}";
                        }
                        else
                        {
                            label = m.isTimeModeSeconds ? $"{cur.time:F2}" : $"{cur.frame}";
                        }

                        float len = label.Length * 3f;
#if UNITY_2019_3_OR_NEWER
                        indexLabelRect.width = Mathf.Max(8f, len * 2.5f);
#else
                        indexLabelRect.width = Mathf.Max(12f, len * 3f);
#endif
                        indexLabelRect.x -= len;

                        // 레이블 좌측 위치 제한
                        indexLabelRect.x = Mathf.Max(indexLabelRect.x, graphRect.x - 4f);

                        // 레이블 우측 위치 제한
                        float rightExceed = indexLabelRect.xMax - graphRect.xMax;
                        if (rightExceed > 0f)
                            indexLabelRect.x -= rightExceed - len;

                        //EditorGUI.DrawRect(indexLabelRect, Color.white);
                        EditorGUI.LabelField(indexLabelRect, label, whiteAnimKeyIndexLabelStyle);
                    }
                }

                // 마우스 이벤트가 불가능한 상황
                if (animKeyMoveEventAllowed == false)
                {
                    selectedAnimKey = null;
                    animKeyToRemove = null;
                }
                // 마우스 이벤트 가능
                else
                {
                    // [1] 제거할 키가 등록된 경우 : 제거 처리
                    if (animKeyToRemove != null)
                    {
                        mp.animKeyList.Remove(animKeyToRemove);
                        animKeyToRemove = null;
                    }
                    // [2] 현재 선택된 키 존재
                    else if (selectedAnimKey != null)
                    {
                        // 왼쪽 CTRL 누름
                        bool lCtrlPressed = (Event.current.modifiers == EventModifiers.Control);
                        // 왼쪽 Shift 누름
                        bool lShiftPressed = (Event.current.modifiers == EventModifiers.Shift);

                        // 드래그 시 이동
                        if (IsLeftMouseDrag)
                        {
                            float xOffset = MousePosition.x - mouseClickPosX;
                            float ratioOffset = xOffset / graphRect.width;
                            float timeGoal =
                                selectedKeyTimeOrFrame + (ratioOffset * (m.isTimeModeSeconds ? m.durationSeconds : m.durationFrame));

                            if (m.isTimeModeSeconds)
                            {
                                // LCTRL 누르면 0.1초 단위로 스냅
                                if (lCtrlPressed)
                                {
                                    timeGoal *= 10f;
                                    timeGoal = Mathf.Round(timeGoal) * 0.1f;
                                }
                                // LSHIFT 누르면 0.05초 단위로 스냅
                                else if (lShiftPressed)
                                {
                                    timeGoal *= 20f;
                                    timeGoal = Mathf.Round(timeGoal) * 0.05f;
                                }
                            }
                            else
                            {
                                // LCTRL 누르면 10프레임 단위로 스냅
                                if (lCtrlPressed)
                                {
                                    timeGoal *= 0.1f;
                                    timeGoal = Mathf.Round(timeGoal) * 10f;
                                }
                                // LSHIFT 누르면 5프레임 단위로 스냅
                                else if (lShiftPressed)
                                {
                                    timeGoal *= 0.2f;
                                    timeGoal = Mathf.Round(timeGoal) * 5f;
                                }
                            }

                            // 좌우 이동 허용 범위 내에서 키 이동
                            if (leftKeyTimeOrFrame < timeGoal && timeGoal < rightKeyTimeOrFrame)
                            {
                                if (m.isTimeModeSeconds)
                                {
                                    selectedAnimKey.time = timeGoal;
                                }
                                else
                                {
                                    selectedAnimKey.frame = (int)timeGoal;
                                }
                            }

                            Repaint();
                        }
                        // 마우스 떼거나 에디터 영역 밖으로 나가면 선택 종료
                        else if (IsLeftMouseUp || IsMouseExitEditor || MousePosition.x < 0f)
                        {
                            selectedAnimKey = null;
                            Repaint();
                            //Debug.Log($"이동 대상 해제");
                        }
                    }
                    // [3] 새로운 키 추가
                    else if (isOverAnyMouseRects == false)
                    {
                        // 그래프 하단의 넓은 영역 : 새로운 키 추가용
                        Rect wideMouseRect = new Rect(graphRect);
                        wideMouseRect.y = graphRect.yMax;
                        wideMouseRect.height = MouseRectHeight;

                        EditorGUIUtility.AddCursorRect(wideMouseRect, MouseCursor.ArrowPlus);

                        if (IsRightMouseDown && wideMouseRect.Contains(MousePosition))
                        {
                            float ratio = (MousePosition.x - wideMouseRect.x) / wideMouseRect.width;
                            float timeOrFrame = m.isTimeModeSeconds ? (m.durationSeconds * ratio) : (int)(m.durationFrame * ratio);
                            timeOrFrame.RefClamp_00();

                            mp.Edt_InsertNewAnimKey(timeOrFrame, m.isTimeModeSeconds);
                            mp.__isKeyListDirty = true; // 더티 플래그 세워주기(예외 핸들링)
                        }
                    }

                }

                if (isPlayMode)
                {
                    // 2. 그래프에 현재 재생 중인 위치 표시하기
                    if (m.isTimeModeSeconds && m.durationSeconds > 0f ||
                        m.IsTimeModeFrame && m.durationFrame > 0)
                    {
                        Rect currentPlayingRect = new Rect(markerRect);

                        currentPlayingRect.x = baseXPos + (currentTimeOrFrameRatio * totalWidth);

                        EditorGUI.DrawRect(currentPlayingRect, Color.yellow);
                    }
                }
            }

            /// <summary> 그래프 토글 버튼 그리기 </summary>
            private void DrawGraphToggleButton(MaterialPropertyInfo mp, Rect buttonRect)
            {
                // 버튼 중앙 정렬
                float viewWidth = buttonRect.width;
                buttonRect.width = GraphToggleButtonWidth;
                buttonRect.x = (viewWidth - GraphToggleButtonWidth * 0.5f) * 0.5f;

                string buttonLabel = mp.__showGraph ?
                    EngHan("Hide Graph", "그래프 숨기기") :
                    EngHan("Show Graph", "그래프 표시");

                // 버튼 스타일 결정
                Color buttonColor = mp.__showGraph ? Color.white * 2f : Color.black;
                graphToggleButtonStyle.normal.textColor = mp.__showGraph ? Color.black : Color.white;
                graphToggleButtonStyle.hover.textColor = Color.gray;

                // 그래프 표시 토글 버튼
                if (RitoEditorGUI.DrawButton(buttonRect, buttonLabel, buttonColor, graphToggleButtonStyle))
                {
                    mp.__showGraph = !mp.__showGraph;
                }
            }

            /// <summary> 애니메이션 토글 버튼 그리기 </summary>
            private void DrawAnimationToggleButton(MaterialPropertyInfo mp, Rect buttonRect)
            {
                // 버튼 중앙 정렬
                float viewWidth = buttonRect.width;
                buttonRect.width = AnimationToggleButtonWidth;
                buttonRect.x = (viewWidth - AnimationToggleButtonWidth * 0.5f) * 0.5f;

                string buttonLabel = mp.__showAnimation ?
                    EngHan("Hide Animation", "애니메이션 숨기기") :
                    EngHan("Show Animation", "애니메이션 표시");

                Color buttonColor = mp.__showAnimation ? Color.white * 2f : Color.black;
                graphToggleButtonStyle.normal.textColor = mp.__showAnimation ? Color.black : Color.white;
                graphToggleButtonStyle.hover.textColor = Color.gray;

                // 애니메이션 표시 토글 버튼
                if (RitoEditorGUI.DrawButton(buttonRect, buttonLabel, buttonColor, graphToggleButtonStyle))
                {
                    mp.__showAnimation = !mp.__showAnimation;
                }
            }

            /// <summary> Float, Range 그래프를 그림미당 </summary>
            private void DrawFloatGraph(MaterialPropertyInfo mp, in Rect graphRect)
            {
                AnimationCurve graph = new AnimationCurve();
                for (int i = 0; i < mp.animKeyList.Count; i++)
                {
                    var curValue = mp.animKeyList[i];

                    float t = m.isTimeModeSeconds ? curValue.time : (float)curValue.frame;

                    // 인접한 두 키의 시간이 동일한 경우, 시간을 미세하게 더해주기
                    if (0 < i && i < mp.animKeyList.Count)
                    {
                        if (curValue.time == mp.animKeyList[i - 1].time)
                            t += 0.001f;
                    }

                    graph.AddKey(t, curValue.floatValue);
                }
                for (int i = 0; i < graph.length; i++)
                {
                    if (i > 0)
                        AnimationUtility.SetKeyLeftTangentMode(graph, i, AnimationUtility.TangentMode.Linear);

                    if (i < graph.length - 1)
                        AnimationUtility.SetKeyRightTangentMode(graph, i, AnimationUtility.TangentMode.Linear);
                }

                // 그래프 배경 색상 설정
                fiCurveBGColor.SetValue(null, new Color(0.15f, 0.15f, 0.15f));

                // 그래프 그리기
                EditorGUI.CurveField(graphRect, graph);

                // 그래프 배경 색상 복원
                fiCurveBGColor.SetValue(null, defaultCurveBGColor);
            }

            private static string[] rgbaButtonLabels;
            private static string[] xyzwButtonLabels;
            private static Color[] rgbaSignatureColors;
            private static readonly Color rgbaButtonDisabledColor = Color.black;

            private static FieldInfo fiCurveBGColor;
            private static Color defaultCurveBGColor;

            private static FieldInfo fiVector4FieldLables;
            private static GUIContent[] vector4FieldLables;

            /// <summary> 그래프 토글 좌측 : 재생, 정지 버튼 </summary>
            private void DrawPlayAndStopButtons(in Rect buttonRect)
            {
                const float LeftMargin = 4f;
                const float ButtonWidth = 28f;
                const float ButtonGap = 4f;

                // 좌측 : 재생 버튼
                Rect playRect = new Rect(buttonRect);
                playRect.width = ButtonWidth;
                playRect.x += LeftMargin;

                // 우측 : 정지 버튼
                Rect stopRect = new Rect(playRect);
                stopRect.x = playRect.xMax + ButtonGap;

                bool playable = !m.gameObject.activeSelf || m.__editMode;
                bool playPressed, pausePressed;

#if UNITY_2019_3_OR_NEWER
                Color playColor = Color.cyan * 2f;
#else
                Color playColor = Color.cyan * 1.2f;
#endif

                var old = whiteTextButtonStyle.normal.background;

                // 1. 재생 버튼
                EditorGUI.BeginDisabledGroup(!playable);
                {
                    string label = playTexture != null ? " " : "▶";
                    if (playTexture != null)
                    {
                        whiteTextButtonStyle.normal.background = playTexture;
                    }
                    playPressed = RitoEditorGUI.DrawButton(playRect, label, playable ? Color.black : playColor, whiteTextButtonStyle);
                }
                EditorGUI.EndDisabledGroup();

                // 2. 정지 버튼
                EditorGUI.BeginDisabledGroup(playable);
                {
                    string label = pauseTexture != null ? " " : "■";
                    if (pauseTexture != null)
                    {
                        whiteTextButtonStyle.normal.background = pauseTexture;
                    }
                    pausePressed = RitoEditorGUI.DrawButton(stopRect, label, !playable ? Color.black : playColor, whiteTextButtonStyle);
                }

                EditorGUI.EndDisabledGroup();

                whiteTextButtonStyle.normal.background = old;

                if (playPressed)
                {
                    m.gameObject.SetActive(true);
                    m.__editMode = false;
                    m.keepCurrentState = false;
                }
                if (pausePressed)
                {
                    m.__editMode = true;
                }
            }

            /// <summary> 좌측의 인덱스 or 시간/프레임 토글 버튼 그리기 </summary>
            private void DrawIndexOrTimeToggleButton(MaterialPropertyInfo mp, Rect buttonRect)
            {
                buttonRect.x += 4f;
                buttonRect.width = 60f;

                string strGrad = mp.__showIndexOrTime ?
                    EngHan("Index", "인덱스") :
                    EngHan(m.isTimeModeSeconds ? "Time" : "Frame", m.isTimeModeSeconds ? "시간(초)" : "프레임");

                if (RitoEditorGUI.DrawButton(buttonRect, strGrad, Color.black, whiteTextButtonStyle))
                {
                    mp.__showIndexOrTime = !mp.__showIndexOrTime;
                }
            }

            /// <summary> 벡터, 컬러 타입인 경우 4가지 토글 버튼 그리기 </summary>
            private void DrawRGBAToggleButtons(MaterialPropertyInfo mp, in Rect buttonRect)
            {
                const int ButtonCount = 4;

                // true : Vector4, false : Color
                bool isVectorType = mp.propType == ShaderPropertyType.Vector;

                // Init(최초 한 번씩 실행)
                {
                    if (rgbaButtonLabels == null)
                    {
                        rgbaButtonLabels = new string[ButtonCount] { "R", "G", "B", "A" };
                    }
                    if (xyzwButtonLabels == null)
                    {
                        xyzwButtonLabels = new string[ButtonCount] { "X", "Y", "Z", "W" };
                    }
                    if (rgbaSignatureColors == null)
                    {
                        rgbaSignatureColors = new Color[ButtonCount]
                        {
                            Color.red,
                            Color.green,
                            Color.blue,
                            Color.white,
                        };
                    }
                }

                string[] buttonLabels4 = isVectorType ? xyzwButtonLabels : rgbaButtonLabels;

                // 1. 토글 버튼
                const float ButtonWidth = 26f;
                const float Margin = 5f;
                float centerX = buttonRect.width * 0.5f;

                Rect[] buttonRects = new Rect[ButtonCount];
                buttonRects[0] = new Rect(buttonRect);
                buttonRects[0].width = ButtonWidth;
                buttonRects[0].x = centerX - (ButtonWidth) - 3f;

                // 모든 버튼 Rect 초기화
                for (int i = 1; i < ButtonCount; i++)
                {
                    buttonRects[i] = new Rect(buttonRects[0]);
                    buttonRects[i].x += i * (ButtonWidth + Margin);
                }

                // 토글 버튼 그리기
                for (int i = 0; i < ButtonCount; i++)
                {
                    Color buttonColor = mp.__showVectorGraphs[i] ? rgbaSignatureColors[i] * 2f : rgbaButtonDisabledColor;

                    graphToggleButtonStyle.normal.textColor = mp.__showVectorGraphs[i] ? Color.black : Color.white;
                    graphToggleButtonStyle.hover.textColor = Color.gray;
                    if (RitoEditorGUI.DrawButton(buttonRects[i], buttonLabels4[i], buttonColor, graphToggleButtonStyle))
                    {
                        mp.__showVectorGraphs[i] = !mp.__showVectorGraphs[i];
                    }
                }

                // =========== 컬러 타입 : 그라디언트 뷰 토글 ==========
                if (isVectorType) return;

                Rect gradToggleRect = new Rect(buttonRect);
                gradToggleRect.width -= 4f;
                gradToggleRect.xMin = gradToggleRect.xMax - 80f; // 우측에서부터 너비 결정

                string strGrad = mp.__isGradientView ?
                    EngHan("Gradient", "그라디언트") :
                    EngHan("Graph", "그래프");

                if (RitoEditorGUI.DrawButton(gradToggleRect, strGrad, Color.black, whiteTextButtonStyle))
                {
                    mp.__isGradientView = !mp.__isGradientView;
                }
            }

            /// <summary> Vector4, Color 그래프를 그림미당 </summary>
            private void DrawVector4OrColorGraph(MaterialPropertyInfo mp, in Rect graphRect)
            {
                const int ButtonCount = 4;

                // true : Vector4, false : Color
                bool isVectorType = mp.propType == ShaderPropertyType.Vector;

                AnimationCurve[] graphs = new AnimationCurve[ButtonCount];

                // ====== Multiple Curves =======
                // 다중 커브를 그리기 위해 커브 배경 색상 투명화
                fiCurveBGColor.SetValue(null, Color.clear);

                // 그래프 배경 색상
                EditorGUI.DrawRect(graphRect, new Color(0.15f, 0.15f, 0.15f));

                // 그래프 마우스 클릭 방지
                if (graphRect.Contains(Event.current.mousePosition))
                {
                    if (Event.current.type == EventType.MouseDown)
                        Event.current.Use();
                }

                // 그래프의 Y축 최솟값 구하기
                float graphMinY = float.MaxValue;
                float graphMaxY = float.MinValue;

                // 벡터
                if (isVectorType)
                {
                    for (int i = 0; i < ButtonCount; i++)
                    {
                        if (mp.__showVectorGraphs[i] == false)
                            continue;

                        for (int j = 0; j < mp.animKeyList.Count; j++)
                        {
                            if (graphMinY > mp.animKeyList[j].vector4[i])
                                graphMinY = mp.animKeyList[j].vector4[i];
                            if (graphMaxY < mp.animKeyList[j].vector4[i])
                                graphMaxY = mp.animKeyList[j].vector4[i];
                        }
                    }
                }
                // 컬러
                else
                {
                    graphMinY = 0f;
                    for (int i = 0; i < ButtonCount; i++)
                    {
                        if (mp.__showVectorGraphs[i] == false)
                            continue;

                        for (int j = 0; j < mp.animKeyList.Count; j++)
                        {
                            if (graphMaxY < mp.animKeyList[j].vector4[i])
                                graphMaxY = mp.animKeyList[j].vector4[i];
                        }
                    }

                    if (graphMaxY < 1f)
                        graphMaxY = 1f;
                }

                // a : 0 ~ 3 (X Y Z W 또는 R G B A)
                for (int a = 0; a < ButtonCount; a++)
                {
                    AnimationCurve graph = graphs[a] = new AnimationCurve();

                    // 토글 ON인 경우만 그래프 그리기
                    if (mp.__showVectorGraphs[a] == false)
                        continue;

                    // i : 애니메이션 키 개수
                    for (int i = 0; i < mp.animKeyList.Count; i++)
                    {
                        var current = mp.animKeyList[i];

                        float t = m.isTimeModeSeconds ? current.time : (float)current.frame;

                        // 인접한 두 키의 시간이 동일한 경우, 시간을 미세하게 더해주기
                        if (0 < i && i < mp.animKeyList.Count)
                        {
                            if (current.time == mp.animKeyList[i - 1].time)
                                t += 0.001f;
                        }

                        graph.AddKey(t, current.vector4[a]);
                    }
                    for (int i = 0; i < graph.length; i++)
                    {
                        AnimationUtility.SetKeyLeftTangentMode(graph, i, AnimationUtility.TangentMode.Linear);
                        AnimationUtility.SetKeyRightTangentMode(graph, i, AnimationUtility.TangentMode.Linear);
                    }

                    // 겹친 그래프들의 상하 잘림 방지
                    Rect gr = new Rect(graphRect);
                    gr.height += a;

                    float curveWidth = m.isTimeModeSeconds ? m.durationSeconds : m.durationFrame;
                    float curveHeight = graphMaxY - graphMinY;
                    if (curveHeight == 0f)
                        curveHeight = 1f;

                    EditorGUI.CurveField(gr, graph, rgbaSignatureColors[a], new Rect(0, graphMinY, curveWidth, curveHeight));
                }

                // 그래프 배경 색상 돌려놓기
                fiCurveBGColor.SetValue(null, defaultCurveBGColor);
            }

            /// <summary> Color - 그래프 위치에 그라디언트 필드 그리기 </summary>
            private void DrawColorGradientView(MaterialPropertyInfo mp, in Rect gradientRect)
            {
                // 그라디언트 내 색상 최대 개수 제한
                if (mp.animKeyList.Count > 8)
                {
                    var oldAlign = EditorStyles.helpBox.alignment;
                    var oldFS = EditorStyles.helpBox.fontSize;

                    EditorStyles.helpBox.alignment = TextAnchor.MiddleCenter;
                    EditorStyles.helpBox.fontSize = 12;

                    EditorGUI.HelpBox(gradientRect,
                        EngHan("Only up to 8 colors can be displayed as a gradient.",
                               "최대 8개의 색상만 그라디언트로 나타낼수 있습니다."),
                        MessageType.Warning);

                    EditorStyles.helpBox.alignment = oldAlign;
                    EditorStyles.helpBox.fontSize = oldFS;

                    return;
                }

                Gradient grad = new Gradient();

                var animKeyList = mp.animKeyList;
                bool showR = mp.__showVectorGraphs[0];
                bool showG = mp.__showVectorGraphs[1];
                bool showB = mp.__showVectorGraphs[2];
                bool showA = mp.__showVectorGraphs[3];

                GradientColorKey[] colorKeys = new GradientColorKey[animKeyList.Count];
                GradientAlphaKey[] alphaKeys = null;

                if (showA)
                {
                    alphaKeys = new GradientAlphaKey[animKeyList.Count];
                }

                // 그라디언트에 컬러키, 알파키 추가
                for (int i = 0; i < animKeyList.Count; i++)
                {
                    MaterialPropertyAnimKey key = animKeyList[i];
                    float t = m.isTimeModeSeconds ? (key.time / m.durationSeconds) : ((float)key.frame / m.durationFrame);
                    float r = showR ? key.color.r : 0f;
                    float g = showG ? key.color.g : 0f;
                    float b = showB ? key.color.b : 0f;

                    colorKeys[i] = new GradientColorKey(new Color(r, g, b), t);

                    if (showA)
                        alphaKeys[i] = new GradientAlphaKey(key.color.a, t);
                }

                grad.colorKeys = colorKeys;

                if (showA)
                    grad.alphaKeys = alphaKeys;

                EditorGUI.GradientField(gradientRect, grad);
            }

            private static readonly Color HighlightBasic = new Color(0.1f, 0.1f, 0.1f);
            private static readonly Color HighlightFirstOrLast = new Color(0.3f, 0.3f, 0.3f);
            private static readonly Color HighlightPlaying = new Color(0.0f, 0.4f, 0.5f);

            /// <summary> 프로퍼티의 애니메이션 키 하나 그리기 (시간, 값) </summary>
            private void DrawEachAnimKey(MaterialPropertyInfo mp, MaterialPropertyAnimKey mpKey, int index)
            {
                bool isFirst = index == 0;
                bool isLast = index == mp.animKeyList.Count - 1;
                bool isFirstOrLast = isFirst || isLast;
                bool isColorType = mp.propType == ShaderPropertyType.Color;

                // Clamp Time Value (First, Last)
                if (isFirst) mpKey.time = 0f;
                else if (isLast) mpKey.time = m.durationSeconds;

                // 현재 재생, 보간되는 두 애니메이션 키 배경 하이라이트
                bool currentPlaying =
                    isPlayMode &&
                    m.isActiveAndEnabled &&
                    mp.enabled &&
                    (index == mp.__playingIndex || index - 1 == mp.__playingIndex);

                // 추가된 애니메이션 키마다 배경 하이라이트
                Rect highlightRight = GUILayoutUtility.GetRect(1f, 0f);
#if UNITY_2019_3_OR_NEWER
                highlightRight.height = isColorType ? 62f : 42f;
#else
                highlightRight.height = isColorType ? 58f : 40f;
#endif
                highlightRight.xMin += 4f;
                highlightRight.xMax -= 4f;

                Rect highlightLeft = new Rect(highlightRight);
                highlightLeft.xMax = 40f;
                highlightRight.xMin += 24f;

                if (currentPlaying)
                {
                    EditorGUI.DrawRect(highlightLeft, currentPlaying ? HighlightPlaying : HighlightBasic);
                    EditorGUI.DrawRect(highlightRight, currentPlaying ? HighlightPlaying : HighlightBasic);
                }
                else
                {
                    if (isFirstOrLast)
                    {
                        EditorGUI.DrawRect(highlightLeft, HighlightFirstOrLast);
                        EditorGUI.DrawRect(highlightRight, HighlightFirstOrLast);
                    }
                    else
                    {
                        EditorGUI.DrawRect(highlightLeft, HighlightBasic);
                        EditorGUI.DrawRect(highlightRight, HighlightBasic);
                    }
                }


                const float LeftMargin = 6f;
                const float IndexLabelWidth = 20f;
                const float LabelWidth = 80f;
                const float MinusButtonWidth = 48f;
                const float RightButtonMargin = 6f;

                // 1. Time 슬라이더
                if (isFirstOrLast) EditorGUI.BeginDisabledGroup(true);

                EditorGUILayout.BeginHorizontal();
                {
#if UNITY_2019_3_OR_NEWER
                    float LM = index > 9 ? 4f : 0f;
#else
                    float LM = index > 9 ? 6f : 0f;
#endif
                    RitoEditorGUI.DrawHorizontalSpace(LeftMargin - LM);

                    Rect indexRect = GUILayoutUtility.GetRect(IndexLabelWidth + LM, 18f, whiteBoldLabelStyle);

                    // 좌측 인덱스 레이블의 높이 조정
#if UNITY_2019_3_OR_NEWER
                    indexRect.y += isColorType ? 18f : 10f;
#else
                    indexRect.y += isColorType ? 14f : 6f;
#endif

                    // 좌측 인덱스(숫자) 레이블
                    EditorGUI.LabelField(indexRect, index.ToString(), whiteBoldLabelStyle);

                    // 시간 레이블
                    string timeLabel;
                    if (m.isTimeModeSeconds)
                    {
                        timeLabel =
                            isFirst ? EngHan("Begin", "시작 시간") :
                            isLast ? EngHan("End", "종료 시간") :
                            EngHan("Time", "시간");
                    }
                    else
                    {
                        timeLabel =
                            isFirst ? EngHan("Begin", "시작 프레임") :
                            isLast ? EngHan("End", "종료 프레임") :
                            EngHan("Time", "프레임");
                    }
                    RitoEditorGUI.DrawPrefixLabelLayout(timeLabel, isFirstOrLast ? Color.white : TimeColor, LabelWidth, true);

                    // 시간 슬라이더
                    Color guiColor = GUI.color;
                    if (isFirstOrLast == false)
                        GUI.color = TimeColor;

                    // [1] 시간 계산 방식 : 초
                    if (m.isTimeModeSeconds)
                    {
                        mpKey.time.RefClamp_000();

                        EditorGUI.BeginChangeCheck();
                        mpKey.time = EditorGUILayout.Slider(mpKey.time, 0f, m.durationSeconds);

                        if (isLast)
                            mpKey.time = m.durationSeconds;

                        if (EditorGUI.EndChangeCheck())
                        {
                            MaterialPropertyAnimKey prevKey = mp.animKeyList[index - 1];
                            MaterialPropertyAnimKey nextKey = mp.animKeyList[index + 1];

                            if (mpKey.time < prevKey.time)
                                mpKey.time = prevKey.time;
                            if (mpKey.time > nextKey.time)
                                mpKey.time = nextKey.time;
                        }
                    }
                    // [2] 시간 계산 방식 : 프레임
                    else
                    {
                        EditorGUI.BeginChangeCheck();
                        mpKey.frame = EditorGUILayout.IntSlider((int)mpKey.frame, 0, (int)m.durationFrame);

                        if (isLast)
                            mpKey.frame = m.durationFrame;

                        if (EditorGUI.EndChangeCheck())
                        {
                            MaterialPropertyAnimKey prevKey = mp.animKeyList[index - 1];
                            MaterialPropertyAnimKey nextKey = mp.animKeyList[index + 1];

                            if (mpKey.frame < prevKey.frame)
                                mpKey.frame = prevKey.frame;
                            if (mpKey.frame > nextKey.frame)
                                mpKey.frame = nextKey.frame;
                        }
                    }

                    GUI.color = guiColor;

                    // 값 변경 시, 전후값의 경계에서 전후값 변경
                    // *ISSUE : 키보드로 직접 값 수정할 때, 도중에 전후값이 수정되는 문제 발생
#if false
                    if (isFirstOrLast == false)
                    {
                        MaterialPropertyValue prevKey = mp.animKeyList[index - 1];
                        MaterialPropertyValue nextKey = mp.animKeyList[index + 1];

                        if (m.isTimeModeSeconds)
                        {
                            if (prevKey.time > mpKey.time)
                                prevKey.time = mpKey.time;
                            if (nextKey.time < mpKey.time)
                                nextKey.time = mpKey.time;
                        }
                        else
                        {
                            if (prevKey.frame > mpKey.frame)
                                prevKey.frame = mpKey.frame;
                            if (nextKey.frame < mpKey.frame)
                                nextKey.frame = mpKey.frame;
                        }
                    }
#endif

                    // 여백 생성
                    RitoEditorGUI.DrawHorizontalSpace(MinusButtonWidth);
                    Rect minusButtonRect = GUILayoutUtility.GetLastRect();
                    minusButtonRect.xMax -= RightButtonMargin;

                    // 이 애니메이션 키 제거 버튼
                    if (isFirstOrLast == false)
                    {
                        if (RitoEditorGUI.DrawButton(minusButtonRect, "-", MinusButtonColor, bigMinusButtonStyle))
                            mp.animKeyList.RemoveAt(index);
                    }
                }
                EditorGUILayout.EndHorizontal();

                if (isFirstOrLast) EditorGUI.EndDisabledGroup();


                // 2. 값 그리기
                EditorGUILayout.BeginHorizontal();

                RitoEditorGUI.DrawHorizontalSpace(LeftMargin);
                RitoEditorGUI.DrawHorizontalSpace(IndexLabelWidth); // 0, 1, 2, ... -> 인덱스 레이블 영역

                RitoEditorGUI.DrawPrefixLabelLayout(EngHan("Value", "값"), Color.white, LabelWidth, true);

                Color col = GUI.color;
                GUI.color = Color.white * 2f;

                switch (mp.propType)
                {
                    case ShaderPropertyType.Float:
                        mpKey.floatValue = EditorGUILayout.FloatField(mpKey.floatValue);
                        break;

                    case ShaderPropertyType.Range:
                        mpKey.floatValue = EditorGUILayout.Slider(mpKey.floatValue, mpKey.min, mpKey.max);
                        break;

                    case ShaderPropertyType.Vector:
                        // Vector4의 레이블 X Y Z W를 하얗게
                        Color colLN = EditorStyles.label.normal.textColor;
                        EditorStyles.label.normal.textColor = Color.white;
                        {
                            mpKey.vector4 = EditorGUILayout.Vector4Field("", mpKey.vector4); // Vec4 Field
                        }
                        EditorStyles.label.normal.textColor = colLN;
                        break;

                    case ShaderPropertyType.Color:
                        EditorGUILayout.BeginVertical();

                        mpKey.vector4.RefClamp_000();

                        mpKey.color = EditorGUILayout.ColorField(mpKey.color); // Color Field

                        // XYZW 레이블 -> RGBA로 변경
                        vector4FieldLables[0].text = "R";
                        vector4FieldLables[1].text = "G";
                        vector4FieldLables[2].text = "B";
                        vector4FieldLables[3].text = "A";

                        Color colLN2 = EditorStyles.label.normal.textColor;
                        EditorStyles.label.normal.textColor = Color.white;
                        {
                            mpKey.vector4 = EditorGUILayout.Vector4Field("", mpKey.vector4); // Vec4 Field
                        }
                        EditorStyles.label.normal.textColor = colLN2;

                        // XYZW 레이블 복원
                        vector4FieldLables[0].text = "X";
                        vector4FieldLables[1].text = "Y";
                        vector4FieldLables[2].text = "Z";
                        vector4FieldLables[3].text = "W";

                        EditorGUILayout.EndVertical();
                        break;
                }

                GUI.color = col;

                RitoEditorGUI.DrawHorizontalSpace(MinusButtonWidth);
                Rect cpButtonRect = GUILayoutUtility.GetLastRect();
                cpButtonRect.xMax -= RightButtonMargin;

                Rect copyButtonRect = new Rect(cpButtonRect);
                copyButtonRect.width *= 0.5f;

                Rect pasteButtonRect = new Rect(copyButtonRect);
                pasteButtonRect.x += pasteButtonRect.width;

                // Copy 버튼 : 값 복사하기
                if (RitoEditorGUI.DrawButton(copyButtonRect, "C", Color.magenta * 1.5f))
                {
                    clipboardValueType = mp.propType;
                    if (clipboardValue == null)
                        clipboardValue = new MaterialPropertyAnimKey();

                    switch (mp.propType)
                    {
                        case ShaderPropertyType.Float:
                        case ShaderPropertyType.Range:
                            clipboardValue.floatValue = mpKey.floatValue;
                            break;

                        case ShaderPropertyType.Vector:
                        case ShaderPropertyType.Color:
                            clipboardValue.vector4 = mpKey.vector4;
                            break;
                    }
                }
                // Paste 버튼 : 복사한 값 붙여넣기(타입 일치하는 경우에만)
                if (RitoEditorGUI.DrawButton(pasteButtonRect, "P", Color.magenta * 1.5f))
                {
                    if (clipboardValue != null && clipboardValueType == mp.propType)
                    {
                        switch (mp.propType)
                        {
                            case ShaderPropertyType.Float:
                            case ShaderPropertyType.Range:
                                mpKey.floatValue = clipboardValue.floatValue;
                                break;

                            case ShaderPropertyType.Vector:
                            case ShaderPropertyType.Color:
                                mpKey.vector4 = clipboardValue.vector4;
                                break;
                        }
                    }
                }

                EditorGUILayout.EndHorizontal();
            }
            #endregion
        }
#endif
        #endregion
        /***********************************************************************
        *                           Custom EditorGUI
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        private static class RitoEditorGUI
        {
            public static readonly Color defaultHeaderBoxColor = new Color(0.1f, 0.1f, 0.1f);
            public static readonly Color defaultContentBoxColor = new Color(0.25f, 0.25f, 0.25f);
            public static readonly Color defaultHeaderTextColor = Color.white;
            public static readonly Color defaultOutlineColor = Color.black;

            public static Color PlusButtonColor { get; set; } = Color.green * 1.5f;
            public static Color MinusButtonColor { get; set; } = Color.red * 1.5f;
            public static Color HeaderBoxColor { get; set; } = defaultHeaderBoxColor;
            public static Color ContentBoxColor { get; set; } = defaultContentBoxColor;
            public static Color HeaderTextColor { get; set; } = defaultHeaderTextColor;
            public static Color OutlineColor { get; set; } = defaultOutlineColor;
            public static Color PrefixLabelColor { get; set; } = Color.white;

            private static GUIStyle prefixLabelStyle;

            // 컨트롤을 그리기 전에 호출
            /// <summary> 지정한 조건이 참인 경우에만 해당 영역 마우스 클릭 허용 </summary>
            public static void EnabledRectArea(in Rect rect, in bool enabledCondition)
            {
                if (!enabledCondition && rect.Contains(Event.current.mousePosition))
                {
                    if (Event.current.type == EventType.MouseDown)
                        Event.current.Use();
                }
            }

            /// <summary> 지정한 조건이 참인 경우에만 해당 영역 마우스 클릭 방지 </summary>
            public static void DisabledRectArea(in Rect rect, in bool disabledCondition)
            {
                if (disabledCondition && rect.Contains(Event.current.mousePosition))
                {
                    if (Event.current.type == EventType.MouseDown)
                        Event.current.Use();
                }
            }

            public static void DrawPrefixLabelLayout(string label, in Color color = default, float width = 0.36f, bool fixedWidth = false)
            {
                if (prefixLabelStyle == null)
                    prefixLabelStyle = new GUIStyle(EditorStyles.label);
                prefixLabelStyle.normal.textColor = color == default ? PrefixLabelColor : color;

                if (!fixedWidth)
                    width = EditorGUIUtility.currentViewWidth * width;

                EditorGUILayout.LabelField(label, prefixLabelStyle, GUILayout.Width(width));
            }
            public static bool DrawButtonLayout(string label, in Color buttonColor, in float width, in float height = 20f)
            {
                Color bCol = GUI.backgroundColor;
                GUI.backgroundColor = buttonColor;

                bool pressed = GUILayout.Button(label, GUILayout.Width(width), GUILayout.Height(height));

                GUI.backgroundColor = bCol;
                return pressed;
            }
            public static bool DrawButtonLayout(string label, in Color textColor, in Color buttonColor, in float width)
            {
                Color bCol = GUI.backgroundColor;
                GUI.backgroundColor = buttonColor;

                GUIStyle buttonStyle = new GUIStyle("button");
                buttonStyle.normal.textColor = textColor;
                buttonStyle.hover.textColor = textColor * 0.5f;

                bool pressed = GUILayout.Button(label, buttonStyle, GUILayout.Width(width));

                GUI.backgroundColor = bCol;
                return pressed;
            }
            public static bool DrawButton(in Rect rect, string label, in Color buttonColor, GUIStyle style = null)
            {
                Color bCol = GUI.backgroundColor;
                GUI.backgroundColor = buttonColor;

                bool pressed = style != null ? GUI.Button(rect, label, style) : GUI.Button(rect, label);

                GUI.backgroundColor = bCol;
                return pressed;
            }
            public static void DrawHorizontalSpace(float width)
            {
                EditorGUILayout.LabelField("", GUILayout.Width(width));
            }
            public static bool DrawPlusButtonLayout(in float width = 40f)
            {
                return DrawButtonLayout("+", PlusButtonColor, width);
            }
            public static bool DrawMinusButtonLayout(in float width = 40f)
            {
                return DrawButtonLayout("-", MinusButtonColor, width);
            }

            static GUIStyle foldoutHeaderTextStyle;
            public static void FoldoutHeaderBox(ref bool foldout, string headerText, int contentCount, float oneHeight = 20f, bool setDefaultColors = true)
            {
                if (setDefaultColors)
                {
                    HeaderBoxColor = defaultHeaderBoxColor;
                    ContentBoxColor = defaultContentBoxColor;
                    HeaderTextColor = defaultHeaderTextColor;
                    OutlineColor = defaultOutlineColor;
                }

                const float OutWidth = 2f;
                const float HeaderHeight = 20f;
                const float HeaderLeftPadding = 4f; // 헤더 박스 내 좌측 패딩(레이블 왼쪽 여백)
                const float ContentTopPadding = 4f; // 내용 박스 내 상단 패딩
                const float ContentBotPadding = 4f; // 내용 박스 내 하단 패딩
                float contentHeight = !foldout ? 0f : (ContentTopPadding + oneHeight * contentCount + ContentBotPadding);
                float totalHeight = !foldout ? (HeaderHeight) : (HeaderHeight + OutWidth + contentHeight);

                Rect H = GUILayoutUtility.GetRect(1, HeaderHeight); // Header
                GUILayoutUtility.GetRect(1f, ContentTopPadding); // Content Top Padding

                // Note : 가로 외곽선이 꼭짓점을 덮는다.

                Rect T = new Rect(); // Top
                T.y = H.y - OutWidth;
                T.height = OutWidth;
                T.xMin = H.xMin - OutWidth;
                T.xMax = H.xMax + OutWidth;

                Rect BH = new Rect(T); // Bottom of Header
                BH.y = H.yMax;

                Rect L = new Rect(); // Left
                L.x = H.x - OutWidth;
                L.y = H.y;
                L.width = OutWidth;
                L.height = totalHeight;

                Rect R = new Rect(L); // Right
                R.x = H.xMax;

                EditorGUI.DrawRect(T, OutlineColor);
                EditorGUI.DrawRect(BH, OutlineColor);
                EditorGUI.DrawRect(L, OutlineColor);
                EditorGUI.DrawRect(R, OutlineColor);

                var col = GUI.color;
                GUI.color = Color.clear;
                {
                    if (GUI.Button(H, " "))
                        foldout = !foldout;
                }
                GUI.color = col;

                EditorGUI.DrawRect(H, HeaderBoxColor);

                Rect HL = new Rect(H);
                HL.xMin = H.x + HeaderLeftPadding;

                if (foldoutHeaderTextStyle == null)
                {
#if UNITY_2019_3_OR_NEWER
                    foldoutHeaderTextStyle = new GUIStyle(EditorStyles.boldLabel);
#else
                    foldoutHeaderTextStyle = new GUIStyle(EditorStyles.label);
#endif
                    foldoutHeaderTextStyle.normal.textColor = Color.white;
                }
                EditorGUI.LabelField(HL, headerText, foldoutHeaderTextStyle);

                if (foldout)
                {
                    Rect C = new Rect(H); // Content
                    C.y = BH.yMax;
                    C.height = contentHeight;

                    Rect BC = new Rect(BH); // Bottom of Content
                    BC.y += contentHeight;

                    EditorGUI.DrawRect(C, ContentBoxColor);
                    EditorGUI.DrawRect(BC, OutlineColor);
                }
            }

            private static GUIStyle enableButtonStyle;
            public static void AnimationFoldoutHeaderBox(ref bool foldout, string headerText, float contentHeight, GUIStyle headerTextStyle,
                in Color enabledHeaderColor, in Color enabledButtonColor, in Color enabledButtonTextColor, in Color removeButtonColor,
                ref bool enabled, out bool removePressed)
            {
                const float OutWidth = 2f;
                const float HeaderHeight = 20f;
                const float HeaderLeftPadding = 4f; // 헤더 박스 내 좌측 패딩(레이블 왼쪽 여백)
                const float ContentTopPadding = 4f; // 내용 박스 내 상단 패딩
                const float ContentBotPadding = 4f; // 내용 박스 내 하단 패딩

                contentHeight = !foldout ? 0f : (ContentTopPadding + contentHeight + ContentBotPadding);

                float totalHeight = !foldout ? (HeaderHeight) : (HeaderHeight + OutWidth + contentHeight);

                Rect H = GUILayoutUtility.GetRect(1, HeaderHeight); // Header
                GUILayoutUtility.GetRect(1f, ContentTopPadding); // Content Top Padding

                // ============================ Outlines ======================================

                Rect T = new Rect(); // Top
                T.y = H.y - OutWidth;
                T.height = OutWidth;
                T.xMin = H.xMin - OutWidth;
                T.xMax = H.xMax + OutWidth;

                Rect BH = new Rect(T); // Bottom of Header
                BH.y = H.yMax;

                Rect L = new Rect(); // Left
                L.x = H.x - OutWidth;
                L.y = H.y;
                L.width = OutWidth;
                L.height = totalHeight;

                Rect R = new Rect(L); // Right
                R.x = H.xMax;

                EditorGUI.DrawRect(T, OutlineColor);
                EditorGUI.DrawRect(BH, OutlineColor);
                EditorGUI.DrawRect(L, OutlineColor);
                EditorGUI.DrawRect(R, OutlineColor);

                // ============================ Button Rects ======================================
                Rect BTN3 = new Rect(H);
                BTN3.width = 36f;
                BTN3.x = H.xMax - BTN3.width - 4f;
                BTN3.yMin += 1f;
                BTN3.yMax -= 1f;

                Rect BTN2 = new Rect(BTN3);
                BTN2.width = 64f;
                BTN2.x = BTN3.xMin - BTN2.width - 4f;

                Rect BTN1 = new Rect(H);
                BTN1.xMax = BTN2.xMin - 4f;

                // ============================ Draw Header ======================================
                // 1. 헤더 버튼
                var col = GUI.color;
                GUI.color = Color.clear;
                {
                    if (GUI.Button(BTN1, " "))
                        foldout = !foldout;
                }
                GUI.color = col;

                // 2. 헤더 배경
                EditorGUI.DrawRect(H, enabledHeaderColor);

                // 3. 헤더 텍스트
                Rect HL = new Rect(H);
                HL.xMin = H.x + HeaderLeftPadding;

                EditorGUI.LabelField(HL, headerText, headerTextStyle);

                // 4. Enabled, Remove 버튼
                col = GUI.backgroundColor;
                GUI.backgroundColor = enabledButtonColor;
                {
                    if (enableButtonStyle == null)
                        enableButtonStyle = new GUIStyle("button");

                    enableButtonStyle.normal.textColor = enabledButtonTextColor;
                    enableButtonStyle.onNormal.textColor = enabledButtonTextColor;
                    enableButtonStyle.hover.textColor = Color.cyan * 1.5f;

                    if (GUI.Button(BTN2, enabled ? "Enabled" : "Disabled", enableButtonStyle))
                        enabled = !enabled;
                }
                GUI.backgroundColor = removeButtonColor;
                {
                    removePressed = GUI.Button(BTN3, "-");
                }
                GUI.backgroundColor = col;

                if (foldout)
                {
                    Rect C = new Rect(H); // Content
                    C.y = BH.yMax;
                    C.height = contentHeight;

                    Rect BC = new Rect(BH); // Bottom of Content
                    BC.y += contentHeight;

                    EditorGUI.DrawRect(C, ContentBoxColor);
                    EditorGUI.DrawRect(BC, OutlineColor);
                }
            }

            public class HorizontalMarginScope : GUI.Scope
            {
                private readonly float rightMargin;
                public HorizontalMarginScope(float leftMargin = 4f, float rightMargin = 4f)
                {
                    this.rightMargin = rightMargin;

                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField(" ", GUILayout.Width(leftMargin));
                }
                protected override void CloseScope()
                {
                    EditorGUILayout.LabelField(" ", GUILayout.Width(rightMargin));
                    EditorGUILayout.EndHorizontal();
                }
            }
        }
#endif
        #endregion
        /***********************************************************************
        *                           Hierarchy Icon
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

        private static GUIStyle matNameLabelStyle;
        private static GUIStyle priorityLabelStyle;
        private static void DrawHierarchyGUI(in Rect fullRect, ScreenEffect effect)
        {
            GameObject go = effect.gameObject;
            bool goActive = go.activeInHierarchy;
            bool matIsNotNull = effect.effectMaterial != null;

            // 1. Left Icon
            Rect iconRect = new Rect(fullRect);
            iconRect.width = 16f;

#if UNITY_2019_3_OR_NEWER
            iconRect.x = 32f;
#else
            iconRect.x = 0f;
#endif
            if (goActive && matIsNotNull && iconTexture != null)
            {
                GUI.DrawTexture(iconRect, iconTexture);
            }


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

            // Priority
            Rect priorityLabelRect = new Rect(leftButtonRect);
            priorityLabelRect.xMax = leftButtonRect.xMin - 4f;
            priorityLabelRect.xMin = priorityLabelRect.xMax - labelPosX;

            if (priorityLabelStyle == null)
                priorityLabelStyle = new GUIStyle(EditorStyles.label);

            priorityLabelStyle.normal.textColor = goActive ? Color.cyan : Color.gray;

#if SHOW_MATERIAL_NAME
            // Material Name

            Rect matNameRect = new Rect(priorityLabelRect);
            matNameRect.xMax = priorityLabelRect.xMin - 4f;
            matNameRect.xMin = matNameRect.xMax - 160f;

            if (matNameLabelStyle == null)
                matNameLabelStyle = new GUIStyle(EditorStyles.label);

            matNameLabelStyle.normal.textColor = goActive ? Color.magenta * 1.5f : Color.gray;
#endif

            EditorGUI.BeginDisabledGroup(!goActive);
            {
                // Priority Label
                GUI.Label(priorityLabelRect, effect.priority.ToString(), priorityLabelStyle);

#if SHOW_MATERIAL_NAME
                // Material Name Label
                if (effect.showMaterialNameInHierarchy && matIsNotNull)
                    GUI.Label(matNameRect, effect.effectMaterial.shader.name, matNameLabelStyle);
#endif
            }
            EditorGUI.EndDisabledGroup();


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
        *                           Context Menu
        ***********************************************************************/
        #region .
#if UNITY_EDITOR
        private const string HierarchyMenuItemTitle = "GameObject/Effects/Screen Effect";

        [MenuItem(HierarchyMenuItemTitle, false, 501)]
        private static void MenuItem()
        {
            GameObject go = new GameObject("Screen Effect");
            go.AddComponent<ScreenEffect>();

            if (Selection.activeTransform != null)
            {
                go.transform.SetParent(Selection.activeTransform);
            }

            Selection.activeGameObject = go; // 선택
        }

        //[MenuItem(HierarchyMenuItemTitle, true)] // Validation
        //private static bool MenuItem_Validate()
        //{
        //    return Selection.activeGameObject == null;
        //}
#endif
        #endregion
        /***********************************************************************
        *                           Save Playmode Changes
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
                            //var targets = FindObjectsOfType(typeof(Inner_PlayModeSave).DeclaringType);
                            var targets = Resources.FindObjectsOfTypeAll(typeof(Inner_PlayModeSave).DeclaringType); // 비활성 오브젝트 포함
                            targetSoArr = new UnityEditor.SerializedObject[targets.Length];
                            for (int i = 0; i < targets.Length; i++)
                                targetSoArr[i] = new UnityEditor.SerializedObject(targets[i]);
                            break;

                        case UnityEditor.PlayModeStateChange.EnteredEditMode:
                            // NOTE : 플레이 도중/직후 컴파일 시 targetSoArr은 null로 초기화
                            if (targetSoArr == null) break;
                            foreach (var oldSO in targetSoArr)
                            {
                                if (oldSO.targetObject == null) continue;
                                var oldIter = oldSO.GetIterator();
                                var newSO = new UnityEditor.SerializedObject(oldSO.targetObject);
                                while (oldIter.NextVisible(true))
                                    newSO.CopyFromSerializedProperty(oldIter);
                                newSO.ApplyModifiedProperties();
                            }

                            // 씬 저장
                            UnityEditor.SceneManagement.EditorSceneManager.SaveOpenScenes();
                            break;
                    }
                };
            }
        }
#endif
        #endregion
    }
    /***********************************************************************
    *                               Editor Only Extensions
    ***********************************************************************/
    #region .
#if UNITY_EDITOR
    internal static class EditorOnlyExtensions
    {
        public static void RefClamp_00(ref this float @this)
        {
            @this *= 100f;
            @this = (int)@this * 0.01f;
        }
        public static void RefClamp_000(ref this float @this)
        {
            @this *= 1000f;
            @this = (int)@this * 0.001f;
        }
        public static void RefClamp_000(ref this Vector4 @this)
        {
            RefClamp_000(ref @this.x);
            RefClamp_000(ref @this.y);
            RefClamp_000(ref @this.z);
            RefClamp_000(ref @this.w);
        }
#if !UNITY_2019_3_OR_NEWER
        public static int GetPropertyCount(this Shader shader)
        {
            return ShaderUtil.GetPropertyCount(shader);
        }
        public static Vector2 GetPropertyRangeLimits(this Shader shader, int index)
        {
            Vector2 ret = new Vector2();
            ret.x = ShaderUtil.GetRangeLimits(shader, index, 1);
            ret.y = ShaderUtil.GetRangeLimits(shader, index, 2);
            return ret;
        }
        public static string GetPropertyName(this Shader shader, int index)
        {
            return ShaderUtil.GetPropertyName(shader, index);
        }
        public static string GetPropertyDescription(this Shader shader, int index)
        {
            return ShaderUtil.GetPropertyDescription(shader, index);
        }
        public static ShaderPropertyType GetPropertyType(this Shader shader, int index)
        {
            return (ShaderPropertyType)ShaderUtil.GetPropertyType(shader, index);
        }
#endif
    }
#endif
    #endregion
}