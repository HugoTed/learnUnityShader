using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    #region Unity回调
    // Start is called before the first frame update
    protected void Start()
    {
        CheckResources();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    #endregion

    #region 方法

    protected void CheckResources()
    {
        bool isSupported = CheckSupport();

        if(isSupported == false)
        {
            NotSupported();
        }
    }

    protected void NotSupported()
    {
        enabled = false;
    }

    protected bool CheckSupport()
    {
        if(SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            Debug.LogWarning("Not Support Image Effect");
            return false;
        }
        return true;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader,Material material)
    {
        //检查shader和material的可用性
        if(shader = null)
        {
            return null;
        }
        if (shader.isSupported && material && material.shader == shader)
            return material;

        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }
    }

    #endregion
}
