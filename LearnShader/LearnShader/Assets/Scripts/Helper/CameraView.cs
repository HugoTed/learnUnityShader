using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CameraView : MonoBehaviour
{
    private Camera mainCamera;
    //private void OnDrawGizmos()
    //{
    //    if (mainCamera == null)
    //        mainCamera = Camera.main;

    //    Debug.Log("OnDrawGizmos");
    //    Gizmos.DrawWireSphere(transform.position, .25f);//使用center和radius参数，绘制一个线框球体。
    //    Gizmos.color = Color.green;
    //    //设置Gizmos矩阵
    //    Gizmos.matrix = Matrix4x4.TRS(mainCamera.transform.position, mainCamera.transform.rotation, Vector3.one);
    //    Gizmos.DrawFrustum(Vector3.zero, mainCamera.fieldOfView, mainCamera.farClipPlane, mainCamera.nearClipPlane, mainCamera.aspect);
    //}

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        //Vector3 pos = new Vector3(transform.position.x + 2, transform.position.y + 2, transform.position.z);
        Gizmos.DrawWireCube(transform.position,Vector3.one * 2);
        Debug.Log("OnDrawGizmosSelected");
    }
}
