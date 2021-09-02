using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase
{
    #region 字段

    public Shader briSatConShader;
    private Material briSatConMaterial;
    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader,briSatConMaterial);
            
            return briSatConMaterial;
        }
    }
    //亮度
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;
    //饱和度
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;
    //对比度
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    #endregion

    #region Unity回调

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_Brightness",brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    #endregion

    #region 方法



    #endregion
}
