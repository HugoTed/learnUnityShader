using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class WindowExample : ScriptableWizard
{
    public string msg = "";

    //显示窗体
    [MenuItem("MyWindow/First Window")]
    private static void ShowWindow()
    {
        ScriptableWizard.DisplayWizard<WindowExample>("WindowExample", "确定", "取消");

    }

    //显示时调用
    private void OnEnable()
    {
        Debug.Log("OnEnable");
    }

    //更新时调用
    private void OnWizardUpdate()
    {
        Debug.Log("OnWizardUpdate");
        if (string.IsNullOrEmpty(msg))
        {
            errorString = "请输入文字";//错误提示
            helpString = ""; //帮助提示
        }
        else
        {
            errorString = "";
            helpString = "请点击确认";
        }
    }

    private void OnWizardCreate()
    {
        Debug.Log("OnWizardCreate");
    }

    private void OnWizardOtherButton()
    {
        Debug.Log("OnWizardOtherButton");
    }

    //需要更新GUI时调用此方法,一般不重写按默认即可
    protected override bool DrawWizardGUI()
    {
        return base.DrawWizardGUI();
    }

    //隐藏时调用
    private void OnDisable()
    {
        Debug.Log("OnDisable");
    }

    private void OnDestroy()
    {
        Debug.Log("OnDestroy");
    }


}
