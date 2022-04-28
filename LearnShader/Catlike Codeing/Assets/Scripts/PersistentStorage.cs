using System.IO;
using UnityEngine;

public class PersistentStorage : MonoBehaviour
{
    string savePath;
    private void Awake()
    {
        savePath = Path.Combine(Application.persistentDataPath, "saveFile");
        Debug.Log(savePath);
    }

    public void Save(PersistableObject o, int version)
    {
        //创建文件流，写入二进制文件
        //使用var隐式声明变量类型
        //使用using语法糖可以将writer变为for循环中的i一样的局部变量，
        //避免读写文件流中出错导致文件破坏
        using (
            var writer = new BinaryWriter(File.Open(savePath, FileMode.Create))
        )
        {
            writer.Write(-version);
            o.Save(new GameDataWriter(writer));
        }

        //var writer = new BinaryWriter(File.Open(savePath, FileMode.Create));
        //try { //...}
        //finally
        //{
        //    if (writer != null)
        //    {
        //        ((System.IDisposable)writer).Dispose();
        //    }
        //}
    }

    public void Load(PersistableObject o)
    {
        using (var reader = new BinaryReader(File.Open(savePath, FileMode.Open)))
        {
            o.Load(new GameDataReader(reader, -reader.ReadInt32()));
        }
    }
}
