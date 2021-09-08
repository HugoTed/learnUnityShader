﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class GBPanel : ViewBase
{
    public GaussianBlur gb;
    public Slider slide1;
    public Slider slide2;
    public Slider slide3;

    void Awake()
    {
        gb.enabled = false;
        effect = gb;
    }
    void Update()
    {
        if (gb.enabled)
        {
            gb.iterations = (int)slide1.value;
            gb.blurSpread = slide2.value;
            gb.downSample = (int)slide3.value;
        }


    }
}
