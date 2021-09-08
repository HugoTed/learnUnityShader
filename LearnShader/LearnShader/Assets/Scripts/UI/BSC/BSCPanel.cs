using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BSCPanel : ViewBase
{
    public BrightnessSaturationAndContrast bsc;
    public Slider bslide;
    public Slider sslide;
    public Slider cslide;

    void Awake()
    {
        bsc.enabled = false;
        effect = bsc;

    }
   void Update()
    {
        if (bsc.enabled)
        {
            bsc.brightness = bslide.value;
            bsc.saturation = sslide.value;
            bsc.contrast = cslide.value;
        }
       

    }
}
