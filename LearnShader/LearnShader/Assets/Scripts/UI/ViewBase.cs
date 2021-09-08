using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ViewBase : MonoBehaviour
{
    protected Behaviour effect;
    public virtual void Show()
    {
        gameObject.SetActive(true);
    }

    public virtual void Hide()
    {
        gameObject.SetActive(false);
    }
    public virtual void SetEffectFalse()
    {
        if (effect != null)
        {
            effect.enabled = false;
        }
        
    }

    public virtual void SetEffectTrue()
    {
        if (effect != null)
        {
            effect.enabled = true;
        }

    }
}
