using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class EdgeDetectPanel : ViewBase
{
    public EdgeDetection ed;
    public Slider slide1;
    

    public Slider slide2R;
    public Slider slide2G;
    public Slider slide2B;

    public Slider slide3R;
    public Slider slide3G;
    public Slider slide3B;
    void Awake()
    {
        ed.enabled = false;
        effect = ed;
    }
    void Update()
    {
        if (ed.enabled)
        {
            ed.edgesOnly = slide1.value;
            ed.edgeColor = new Color(slide2R.value, slide2G.value, slide2B.value);
            ed.backgroundColor = new Color(slide3R.value, slide3G.value, slide3B.value);
        }


    }
}
