using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
public class CB_Outline : MonoBehaviour
{
    private CommandBuffer cb = null;
    private RenderTexture rt = null;
    private Renderer tr = null;
    public GameObject target = null;
    [Range(0f,10f)]
    public float blurSzie = 1.0f;

    public Color color;
    public Shader pureShader;
    public Shader GBShader;
    public Shader MinusShader;

    private Material GBMaterial;
    private Material MinusMat;
    private Material ColorMat;
    public Material GBmat
    {
        get
        {
            if (GBMaterial == null)
            {
                GBMaterial = new Material(GBShader);
                return GBmat;
            }
            return GBMaterial;
        }
    }
    public Material MinMat
    {
        get
        {
            if (MinusMat == null)
            {
                MinusMat = new Material(MinusShader);
                return MinusMat;
            }
            return MinusMat;
        }
    }
    public Material ColMat
    {
        get
        {
            if (ColorMat == null)
            {
                ColorMat = new Material(pureShader);
                return ColorMat;
            }
            return ColorMat;
        }
    }
    private void OnEnable()
    {
        Camera.main.RemoveAllCommandBuffers();

        rt = RenderTexture.GetTemporary(1024, 1024, 16, RenderTextureFormat.ARGB32,
            RenderTextureReadWrite.Default, 4);

        tr = target.GetComponent<Renderer>();
        cb = new CommandBuffer();

        cb.SetRenderTarget(rt);

        cb.ClearRenderTarget(true, true, Color.black);

        cb.DrawRenderer(tr, ColMat);
        RenderTexture rt2 = RenderTexture.GetTemporary(1024, 1024, 16, RenderTextureFormat.ARGB32,
            RenderTextureReadWrite.Default, 4);

        RenderTexture rt3 = RenderTexture.GetTemporary(1024, 1024, 16, RenderTextureFormat.ARGB32,
           RenderTextureReadWrite.Default, 4);
        cb.Blit(rt, rt2, GBmat,0);
        cb.Blit(rt2, rt3, GBmat, 1);

        MinMat.SetTexture("_OtherTex", rt);
        cb.Blit(rt3, rt2, MinMat);
       
        this.GetComponent<Renderer>().sharedMaterial.mainTexture = rt2;

        Camera.main.AddCommandBuffer(CameraEvent.AfterForwardOpaque, cb);
    }

    private void Update()
    {
        ColMat.SetColor("_Color", color);
        GBmat.SetFloat("_BlurSzie", blurSzie);
        
    }
}
