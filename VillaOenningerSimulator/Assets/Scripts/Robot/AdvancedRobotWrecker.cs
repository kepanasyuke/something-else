using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class AdvancedRobotWrecker : MonoBehaviour
{
    public float movementSpeed = 4f;
    public float rotationSpeed = 5f;
    public float scanRadius = 40f;
    public float shockwaveRadius = 6f;
    public float kineticImpactForce = 700f;
    public Material wallInsideMaterial;
    public GameObject concreteDustPrefab;
    public string activeZoneLayer = "";

    private GameObject currentTarget;
    private bool isActive;
    private Rigidbody rb;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.isKinematic = true;
    }

    public void AssignTargetTask(string zoneLayerName)
    {
        activeZoneLayer = zoneLayerName;
        isActive = true;
        FindNextTarget();
        if (AudioManager.Instance != null)
            AudioManager.Instance.StartRobotEngine();
    }

    private void FixedUpdate()
    {
        if (!isActive) return;

        if (currentTarget == null)
        {
            FindNextTarget();
            if (currentTarget == null) return;
        }

        Vector3 dir = currentTarget.transform.position - transform.position;
        dir.y = 0f;

        if (dir.sqrMagnitude < 0.04f) return;

        Quaternion look = Quaternion.LookRotation(dir, Vector3.up);
        transform.rotation = Quaternion.Slerp(transform.rotation, look, Time.fixedDeltaTime * rotationSpeed);
        transform.position += transform.forward * movementSpeed * Time.fixedDeltaTime;
    }

    private void FindNextTarget()
    {
        Collider[] hits = Physics.OverlapSphere(transform.position, scanRadius);
        float minDist = float.MaxValue;
        GameObject closest = null;

        foreach (Collider col in hits)
        {
            if (!col.CompareTag("Destructible")) continue;

            CollapsePart part = col.GetComponent<CollapsePart>();
            if (part == null || part.IsCollapsed()) continue;

            float d = Vector3.Distance(transform.position, col.transform.position);
            if (d < minDist)
            {
                minDist = d;
                closest = col.gameObject;
            }
        }

        currentTarget = closest;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Destructible")) return;

        Vector3 contact = other.ClosestPointOnBounds(transform.position);
        if (AudioManager.Instance != null)
            AudioManager.Instance.PlayCrashSound(contact);

        CollapsePart part = other.GetComponent<CollapsePart>();
        if (part != null)
            part.Collapse(contact, 0.6f);

        FindNextTarget();
    }
}
