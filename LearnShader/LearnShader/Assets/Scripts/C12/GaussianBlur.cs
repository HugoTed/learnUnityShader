using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial = null;
    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }
    //迭代次数
    [Range(0, 4)]
    public int iterations = 3;
    //模糊范围
    [Range(0.2f,3.0f)]
    public float blurSpread = 0.6f;
    //缩放系数
    //downSample越大性能越好,过大可能会造成图像像素化
    [Range(1,8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        if (material != null)
        {
            //缩小图像减少需要处理的像素个数
            int rtW = source.width/downSample;
            int rtH = source.height/downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            //滤波模式设置成双线性
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, buffer0);

            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSzie", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //竖直方向
                Graphics.Blit(buffer0, buffer1, material, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //水平方向
                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, destination);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
