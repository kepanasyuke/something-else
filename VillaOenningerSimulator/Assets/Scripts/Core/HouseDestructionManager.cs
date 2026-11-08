using UnityEngine;

public class HouseDestructionManager : MonoBehaviour
{
    public static HouseDestructionManager Instance { get; private set; }

    public Transform zoneA_TargetPoint;
    public Transform zoneB_TargetPoint;
    public AdvancedRobotWrecker robotInstance;

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        int count = FindObjectsOfType<CollapsePart>().Length;

        if (DestructionProgress.Instance != null)
            DestructionProgress.Instance.SetTotal(count);
    }

    public void SelectTargetZone(string zoneName)
    {
        if (zoneName == "ZoneA")
            zoneA_TargetPoint = transform;
        if (zoneName == "ZoneB")
            zoneB_TargetPoint = transform;
    }

    public void CommandRobotToStart()
    {
        if (robotInstance != null)
            robotInstance.AssignTargetTask("ZoneA");
    }

    public void ReportBlockDestroyed(GameObject blockObject)
    {
        CollapsePart part = blockObject != null ? blockObject.GetComponent<CollapsePart>() : null;
        if (part != null && DestructionProgress.Instance != null)
            DestructionProgress.Instance.ReportDestroyed(part);
    }
}
