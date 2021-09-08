using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CBPanel : ViewBase
{
    public CB_Outline cb;
    public Slider slide1;
    public Slider slide2R;
    public Slider slide2G;
    public Slider slide2B;

    void Awake()
    {
        cb.enabled = false;
        effect = cb;
    }
    void Update()
    {
        if (cb.enabled)
        {
            cb.blurSzie = slide1.value;
            cb.color = new Color(slide2R.value, slide2G.value, slide2B.value);
        }


    }
}
