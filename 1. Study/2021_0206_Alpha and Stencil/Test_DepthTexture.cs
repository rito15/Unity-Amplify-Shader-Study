using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using System;
//using Rito;
//using Rito.Attributes;
//using Rito.Extensions;

// 날짜 : #DATE#
// 작성자 : Rito

[ExecuteInEditMode]
public class Test_DepthTexture : MonoBehaviour
{
    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
}