using UnityEngine;

public class CollapsePart : MonoBehaviour
{
    public float delay = 0f;
    public float breakForce = 900f;
    public float shockRadius = 14f;
    public float upwardLift = 1.6f;
    public GameObject dustPrefab;

    private Rigidbody body;
    private bool collapsed;

    private void Awake()
    {
        body = GetComponent<Rigidbody>();
        if (body != null)
            body.isKinematic = true;
    }

    public void Collapse(Vector3 origin, float powerMultiplier)
    {
        if (collapsed) return;
        collapsed = true;

        if (body == null)
            body = gameObject.AddComponent<Rigidbody>();

        body.isKinematic = false;
        body.useGravity = true;
        body.mass = 60f;
        body.AddExplosionForce(breakForce * powerMultiplier, origin, shockRadius, upwardLift, ForceMode.Impulse);

        if (dustPrefab != null)
        {
            GameObject dust = Instantiate(dustPrefab, transform.position, Quaternion.identity);
            Destroy(dust, 4f);
        }
        else
        {
            SpawnDust();
        }

        if (DestructionProgress.Instance != null)
            DestructionProgress.Instance.ReportDestroyed(this);
    }

    public bool IsCollapsed()
    {
        return collapsed;
    }

    private void SpawnDust()
    {
        GameObject dustGo = new GameObject("Dust");
        dustGo.transform.position = transform.position;

        ParticleSystem ps = dustGo.AddComponent<ParticleSystem>();
        ParticleSystem.MainModule main = ps.main;
        main.duration = 1.2f;
        main.loop = false;
        main.startLifetime = 2.4f;
        main.startSpeed = 1.8f;
        main.startSize = 0.9f;
        main.startColor = new Color(0.82f, 0.8f, 0.75f, 0.55f);
        main.maxParticles = 220;
        main.playOnAwake = true;

        ParticleSystem.EmissionModule emission = ps.emission;
        emission.rateOverTime = 0f;
        emission.SetBursts(new ParticleSystem.Burst[]
        {
            new ParticleSystem.Burst(0f, 45)
        });

        ParticleSystem.ShapeModule shape = ps.shape;
        shape.shapeType = ParticleSystemShapeType.Sphere;
        shape.radius = 1.1f;

        ps.Play();
        Destroy(dustGo, 4.5f);
    }
}
