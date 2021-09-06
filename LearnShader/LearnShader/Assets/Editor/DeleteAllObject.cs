using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class DeleteAllObject : MonoBehaviour
{
    //[MenuItem("My Tool/DeleteAllObj",true)]
    //第一个参数表示菜单路径
    //第二个参数表示是否为有效函数,是否需要显示
    //第三个参数表示优先级,默认为1000
    [MenuItem("My Tool/DeleteAllObj",true)]
   private static bool DeleteValidate()
    {
        //是否选择了对象
        if (Selection.objects.Length > 0)
            return true;
        return false;
    }

    [MenuItem("My Tool/DeleteAllObj", false)]
    private static void MyToolDelete()
    {
        //Selection.objects 返回场景或者Project中选择的多个对象
        foreach (Object item in Selection.objects)
        {
            //记录删除操作,允许撤销
            Undo.DestroyObjectImmediate(item);
        }
    }
    //DeleteValidate是MyToolDelete的有效函数,所以第二个参数为true,用来判断当前是否选择了对象
}
