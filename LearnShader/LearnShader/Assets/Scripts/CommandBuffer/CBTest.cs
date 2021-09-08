using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CBTest : MonoBehaviour
{
    private CommandBuffer cb;
    private RenderTexture rt;
    public GameObject tarObj;
    private Renderer renderTarget1;

    public CommandBuffer cm
    {
        get
        {
            if (cb == null)
            {
                cb = new CommandBuffer();
            }
            return cb;
        }
    }

    private void OnEnable()
    {
        //CommandBuffer buf = new CommandBuffer();
        //buf.DrawRenderer(GetComponent<Renderer>(), new Material(shader));

        //Camera.main.AddCommandBuffer(CameraEvent.AfterForwardOpaque, buf);

        //每次进来清空commandbuffer
        Camera.main.RemoveAllCommandBuffers();

        cm.Clear();
        if(rt!=null)
        {
            rt.Release();
        }

        cm.name = "MyCB0";

        renderTarget1 = tarObj.GetComponent<Renderer>();

        rt = RenderTexture.GetTemporary(1024, 1024, 16, RenderTextureFormat.ARGB32,
            RenderTextureReadWrite.Default, 4);

        //设置command buffer渲染目标为rt;
        cm.SetRenderTarget(rt);
        //初始颜色为黑色
        cm.ClearRenderTarget(true, true, Color.black);

        //渲染目标物体到rt上,使用自己材质
        cm.DrawRenderer(renderTarget1,renderTarget1.material);

        //接受物体的材质使用这张rt作为主纹理
        this.GetComponent<Renderer>().sharedMaterial.mainTexture = rt;

        Camera.main.AddCommandBuffer(CameraEvent.AfterEverything, cm);

    }

}
