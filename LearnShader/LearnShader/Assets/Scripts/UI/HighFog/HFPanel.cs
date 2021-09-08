using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HFPanel : ViewBase
{
    public FogWithDepthTexture fog;
    public Slider slide1;

    public Slider slide2R;
    public Slider slide2G;
    public Slider slide2B;

    public Slider slide3;
    public Slider slide4;

    void Awake()
    {
        fog.enabled = false;
        effect = fog;
    }
    void Update()
    {
        if (fog.enabled)
        {
            fog.fogDensity = slide1.value;
            fog.fogColor = new Color(slide2R.value, slide2G.value, slide2B.value);
            fog.fogStart = slide3.value;
            fog.fogEnd = slide4.value;
        }
    }
}
