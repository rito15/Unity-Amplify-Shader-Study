using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test_CameraMain : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        UnityEngine.Profiling.Profiler.BeginSample("FIND MAIN CAMERA");
        _ = Camera.main;
        UnityEngine.Profiling.Profiler.EndSample();
    }

#if UNITY_EDITOR
    private class CE : UnityEditor.Editor
    {
        private void Reset()
        {
            Debug.Log("Hihi");
        }
    }
    private void Reset()
    {
        Debug.Log("Hihi2");
    }
#endif
}
