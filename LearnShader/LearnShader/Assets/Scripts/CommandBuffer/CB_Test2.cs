using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CB_Test2 : PostEffectsBase
{
    private CommandBuffer cb = null;
    private static RenderTexture rt = null;
    private Renderer tr = null;
    public GameObject target = null;
    public Material repalceMat = null;
    public Shader shader;

    private Material mat;
    public Material material
    {
        get
        {
            mat = CheckShaderAndCreateMaterial(shader, mat);
            return mat;
        }
    }


    // Update is called once per frame
    void Update()
    {
        
    }
}
