using UnityEngine;
using TMPro;
using System.Collections.Generic;

public class HouseDestructionManager : MonoBehaviour
{
    public static HouseDestructionManager Instance { get; private set; }

    [Header("Core References")]
    [SerializeField] private AdvancedRobotWrecker robotInstance;
    [SerializeField] private TextMeshProUGUI percentageUItext;
    
    [Header("Interactive Zones")]
    [SerializeField] private Transform zoneA_TargetPoint;
    [SerializeField] private Transform zoneB_TargetPoint;

    private int totalDestructibleBlocksCount;
    private HashSet<GameObject> destroyedBlocksList = new HashSet<GameObject>();
    private Transform selectedZonePoint;

    private void Awake() => Instance = this;

    private void Start()
    {
        var blocks = GameObject.FindGameObjectsWithTag("Destructible");
        totalDestructibleBlocksCount = blocks.Length;
        UpdateUIProgressDisplay();
    }

    public void SelectTargetZone(string zoneName)
    {
        if (zoneName == "ZoneA") selectedZonePoint = zoneA_TargetPoint;
        if (zoneName == "ZoneB") selectedZonePoint = zoneB_TargetPoint;
    }

    public void CommandRobotToStart()
    {
        if (selectedZonePoint != null && robotInstance != null)
        {
            string zone = selectedZonePoint.gameObject.layer == LayerMask.NameToLayer("ZoneA") ? "ZoneA" : "ZoneB";
            robotInstance.AssignTargetTask(zone);
        }
    }

    public void ReportBlockDestroyed(GameObject blockObject)
    {
        if (destroyedBlocksList.Add(blockObject))
            UpdateUIProgressDisplay();
    }

    private void UpdateUIProgressDisplay()
    {
        if (totalDestructibleBlocksCount == 0) return;
        float progress = (float)destroyedBlocksList.Count / totalDestructibleBlocksCount;
        percentageUItext.text = $"Здание демонтировано: {progress * 100f:F1}%";
    }
}
