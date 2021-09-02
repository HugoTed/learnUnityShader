using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial = null;
    public Material material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }
    //边缘线强度
    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;
    //描边颜色
    public Color edgeColor = Color.black;
    //背景颜色
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(source, destination, material) ;
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
