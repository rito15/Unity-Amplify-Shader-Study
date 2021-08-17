using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// 날짜 : 2021-08-16 PM 8:15:59
// 작성자 : Rito

namespace Rito
{
    /// <summary> 
    /// 
    /// </summary>
    [ExecuteInEditMode]
    public class ScreenEffectController : MonoBehaviour
    {
        public Material _mat;

        private void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (_mat == null) return;

            Graphics.Blit(source, destination, _mat);
        }
    }
}