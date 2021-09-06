using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
public class EditorWindowExample : EditorWindow
{
    private static EditorWindowExample window;
    private Rect buttonRect;
    

    //显示窗体
    [MenuItem("MyWindow/EditorWindowExample")]
    private static void ShowWindow()
    {
        window = EditorWindow.GetWindow<EditorWindowExample>("Editor Window Example");
        window.Show();
    }

    //绘制窗体内容
    private void OnGUI()
    {
        GUILayout.Label("Popup example", EditorStyles.boldLabel);
    }

   
}
