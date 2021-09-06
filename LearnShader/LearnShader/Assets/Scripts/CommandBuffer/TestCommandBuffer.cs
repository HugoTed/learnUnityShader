using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class TestCommandBuffer : MonoBehaviour
{
    public Shader shader;
    private CommandBuffer cb;
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

        //第一条order:渲染正方形前清空画面,背景为黑色
        cm.ClearRenderTarget(true, true, Color.white);

        //第二条order:用自定义材质渲染正方形
        cm.DrawRenderer(GetComponent<Renderer>(), new Material(shader));

        Camera.main.AddCommandBuffer(CameraEvent.AfterEverything, cm);

    }
}
