using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainMenu : MonoBehaviour
{
    private List<ViewBase> views = new List<ViewBase>();
    public Camera cam;
    public BSCPanel bSCPanel;
    public EdgeDetectPanel edgeDetectPanel;
    public GBPanel gbPanel;
    public BloomPanel bloomPanel;
    public MBPanel mBPanel;
    public MBVPanel mbvPanel;
    public HFPanel hfPanel;
    public EdgeDetectWithDepthPanel eddpPanel;
    public CBPanel cbPanel;

    public void ExitGame()
    {
        Application.Quit();
    }
    void Awake()
    {
        
        views.Add(bSCPanel);
        views.Add(edgeDetectPanel);
        views.Add(gbPanel);
        views.Add(bloomPanel);
        views.Add(mBPanel);
        views.Add(mbvPanel);
        views.Add(hfPanel);
        views.Add(eddpPanel);
        views.Add(cbPanel);
    }

    private void TurnOffAllEffect()
    {
        cam.GetComponent<Translating>().enabled = false;
        //cam.transform.position = new Vector3(-0.270036f, -0.3728507f, -7.031876f);
        foreach (var item in views)
        {
            item.Hide();
            item.SetEffectFalse();
        }
        cam.transform.position = new Vector3(-0.270036f, -0.3728507f, -7.031876f);
        cam.transform.rotation = Quaternion.Euler(Vector3.zero);
    }
    public void OnClickBSCPanel()
    {
        TurnOffAllEffect();
        bSCPanel.Show();
        bSCPanel.SetEffectTrue();

    }
    public void OnClickedgeDetectPanel()
    {
        TurnOffAllEffect();
        edgeDetectPanel.Show();
        edgeDetectPanel.SetEffectTrue();
       
    }
    public void OnClickGBPanel()
    {
        TurnOffAllEffect();
        gbPanel.Show();
        gbPanel.SetEffectTrue();

    }
    public void OnClickBloomPanel()
    {
        TurnOffAllEffect();
        bloomPanel.Show();
        bloomPanel.SetEffectTrue();

    }
    public void OnClickMotionBlur()
    {
        TurnOffAllEffect();
        mBPanel.Show();
        mBPanel.SetEffectTrue();
        cam.GetComponent<Translating>().enabled = true;

    }
    public void OnClickMotionBlurVelocity()
    {
        TurnOffAllEffect();
        mbvPanel.Show();
        mbvPanel.SetEffectTrue();
        cam.GetComponent<Translating>().enabled = true;

    }
    public void OnClickHighFog()
    {
        TurnOffAllEffect();
        hfPanel.Show();
        hfPanel.SetEffectTrue();
    }
    public void OnClickEdgeDetectWithDepthAndNormal()
    {
        TurnOffAllEffect();
        eddpPanel.Show();
        eddpPanel.SetEffectTrue();
    }
    public void OnClickCommandBufferEffect()
    {
        TurnOffAllEffect();
        cbPanel.Show();
        cbPanel.SetEffectTrue();
    }
}
