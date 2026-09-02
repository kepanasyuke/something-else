using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class AdvancedRobotWrecker : MonoBehaviour
{
    [Header("Navigation")]
    [SerializeField] private float movementSpeed = 10f;
    [SerializeField] private float rotationSpeed = 7f;
    [SerializeField] private float scanRadius = 50f;

    [Header("Demolition")]
    [SerializeField] private float shockwaveRadius = 5f;
    [SerializeField] private float kineticImpactForce = 1100f;
    [SerializeField] private Material wallInsideMaterial;

    [Header("FX")]
    [SerializeField] private GameObject concreteDustPrefab;

    private GameObject currentTarget;
    private bool isActive = false;
    private Rigidbody rb;
    private string activeZoneLayer = "";

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
            if (currentTarget == null) { isActive = false; return; }
        }

        Vector3 dir = currentTarget.transform.position - transform.position;
        dir.y = 0;
        if (dir.magnitude > 0.2f)
        {
            Quaternion look = Quaternion.LookRotation(dir);
            rb.MoveRotation(Quaternion.Slerp(transform.rotation, look, Time.fixedDeltaTime * rotationSpeed));
            rb.MovePosition(rb.position + transform.forward * movementSpeed * Time.fixedDeltaTime);
        }
    }

    private void FindNextTarget()
    {
        Collider[] hits = Physics.OverlapSphere(transform.position, scanRadius);
        float minDist = float.MaxValue;
        GameObject closest = null;
        int targetLayer = LayerMask.NameToLayer(activeZoneLayer);
        foreach (var col in hits)
        {
            if (col.CompareTag("Destructible") && col.gameObject.layer == targetLayer)
            {
                var body = col.GetComponent<Rigidbody>();
                if (body != null && body.isKinematic)
                {
                    float d = Vector3.Distance(transform.position, col.transform.position);
                    if (d < minDist) { minDist = d; closest = col.gameObject; }
                }
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
        ExecuteSlice(other.gameObject, contact);
    }

    private void ExecuteSlice(GameObject wall, Vector3 contact)
    {
        if (concreteDustPrefab != null)
            Destroy(Instantiate(concreteDustPrefab, contact, Quaternion.identity), 3f);

        var pieces = MeshSlicer.Slice(wall, contact, transform.right, wallInsideMaterial);
        if (pieces != null)
        {
            Destroy(wall);
            foreach (var piece in pieces)
            {
                var body = piece.GetComponent<Rigidbody>();
                if (body != null)
                    body.AddExplosionForce(kineticImpactForce, contact, shockwaveRadius, 2f, ForceMode.Impulse);
                HouseDestructionManager.Instance?.ReportBlockDestroyed(piece);
            }
        }
        FindNextTarget();
    }
}
