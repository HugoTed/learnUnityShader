using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial = null;
    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }
    //模糊参数,值越大,拖尾效果越明显
    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;

    private RenderTexture accumulationTexture;

    private void OnDisable()
    {
        //不运行时立即销毁accumulationTexture
        DestroyImmediate(accumulationTexture);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            if(accumulationTexture == null || accumulationTexture.width != source.width ||
                accumulationTexture.height != source.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(source.width, source.height, 0);
                //不会显示在Hierarchy中也不会保存在场景中
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(source, accumulationTexture);
            }
            //渲染纹理的恢复操作
            accumulationTexture.MarkRestoreExpected();
            material.SetFloat("_BlurAmount", 1.0f - blurAmount);
            //将当前图像src叠加到accumulationTexture
            Graphics.Blit(source, accumulationTexture, material);
            Graphics.Blit(accumulationTexture, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
