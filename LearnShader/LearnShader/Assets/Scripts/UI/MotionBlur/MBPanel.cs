using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MBPanel : ViewBase
{
    public MotionBlur mb;
    public Slider slide1;
   

    void Awake()
    {
        mb.enabled = false;
        effect = mb;
    }
    void Update()
    {
        if (mb.enabled)
        {
            mb.blurAmount = slide1.value;
           
        }


    }
}
