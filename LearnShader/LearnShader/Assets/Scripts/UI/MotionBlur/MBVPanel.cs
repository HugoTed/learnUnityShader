using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MBVPanel : ViewBase
{
    public MotionBlurWithDepthTexture mbv;
    public Slider slide1;


    void Awake()
    {
        mbv.enabled = false;
        effect = mbv;
    }
    void Update()
    {
        if (mbv.enabled)
        {
            mbv.blurSzie = slide1.value;

        }
    }
}
