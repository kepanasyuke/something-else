using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollapseDirector : MonoBehaviour
{
    public static CollapseDirector Instance { get; private set; }

    [Header("Scene")]
    public Transform[] shockOrigins;
    public float startDelay = 6f;
    public float waveStep = 0.35f;
    public float powerMultiplier = 1f;
    public float shakeAmplitude = 0.12f;
    public float shakeDuration = 2.5f;

    [Header("Audio")]
    public AudioSource rumbleSource;

    private readonly List<CollapsePart> parts = new List<CollapsePart>();
    private bool started;

    private void Awake()
    {
        Instance = this;
    }

    public void Register(CollapsePart part)
    {
        if (part != null && !parts.Contains(part))
            parts.Add(part);
    }

    public int TotalParts()
    {
        return parts.Count;
    }

    public void StartCollapse()
    {
        if (started) return;
        started = true;
        StartCoroutine(RunCollapse());
    }

    private IEnumerator RunCollapse()
    {
        yield return new WaitForSeconds(startDelay);

        List<CollapsePart> ordered = new List<CollapsePart>(parts);
        ordered.Sort((a, b) => b.transform.position.y.CompareTo(a.transform.position.y));

        int index = 0;
        foreach (CollapsePart part in ordered)
        {
            if (part == null) continue;

            Vector3 origin = ResolveOrigin(part, index);
            part.Collapse(origin, powerMultiplier);

            if (index % 3 == 0)
                StartCoroutine(ShakeCouroutine());
            if (rumbleSource != null && !rumbleSource.isPlaying)
                rumbleSource.Play();

            index++;
            yield return new WaitForSeconds(waveStep * Random.Range(0.6f, 1.4f));
        }
    }

    private Vector3 ResolveOrigin(CollapsePart part, int index)
    {
        if (shockOrigins != null && shockOrigins.Length > 0)
        {
            Transform t = shockOrigins[index % shockOrigins.Length];
            if (t != null)
                return t.position;
        }
        Vector3 p = part.transform.position;
        return new Vector3(p.x, p.y - 1f, p.z);
    }

    private IEnumerator ShakeCouroutine()
    {
        if (Camera.main == null) yield break;

        Transform cam = Camera.main.transform;
        Vector3 basePos = cam.localPosition;
        float elapsed = 0f;

        while (elapsed < shakeDuration)
        {
            elapsed += Time.deltaTime;
            float damping = 1f - elapsed / shakeDuration;
            Vector3 offset = Random.insideUnitSphere * shakeAmplitude * damping;
            cam.localPosition = basePos + offset;
            yield return null;
        }

        cam.localPosition = basePos;
    }
}
