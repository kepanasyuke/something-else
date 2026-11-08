using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DestructionProgress : MonoBehaviour
{
    public static DestructionProgress Instance { get; private set; }

    public Text label;
    public int totalParts;
    public string format = "Вилла Оэннинга разрушена: {0:F0}%";

    private readonly HashSet<CollapsePart> destroyed = new HashSet<CollapsePart>();

    private void Awake()
    {
        Instance = this;
    }

    public void SetTotal(int value)
    {
        totalParts = value;
        Refresh();
    }

    public void ReportDestroyed(CollapsePart part)
    {
        if (part == null) return;
        destroyed.Add(part);
        Refresh();
    }

    public float Percent()
    {
        if (totalParts <= 0) return 0f;
        return Mathf.Clamp01((float)destroyed.Count / totalParts) * 100f;
    }

    private void Refresh()
    {
        if (label == null) return;
        label.text = string.Format(format, Percent());
    }
}
