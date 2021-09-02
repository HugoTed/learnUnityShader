using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase
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

    [Range(0.0f, 1.0f)]
    public float blurSzie = 0.5f;

    private Camera myCamera;
    public Camera camera
    {
        get
        {
            if (myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }
    //前一帧的视角*投影矩阵
    private Matrix4x4 previousViewProjectionMatrix;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
        previousViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_BlurSize", blurSzie);

            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            //当前帧的视角*投影矩阵
            Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
