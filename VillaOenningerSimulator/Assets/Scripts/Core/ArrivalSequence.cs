using System.Collections;
using UnityEngine;

public class ArrivalSequence : MonoBehaviour
{
    public Transform car;
    public Vector3 driveFrom;
    public Vector3 driveTo;
    public float duration = 6f;
    public Transform playerSpawn;
    public PlayerWalkController player;
    public bool finished;

    public void Play()
    {
        StartCoroutine(Run());
    }

    private IEnumerator Run()
    {
        if (car != null)
        {
            car.position = driveFrom;
            car.gameObject.SetActive(true);
        }

        float elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / duration);
            float eased = Mathf.SmoothStep(0f, 1f, t);

            if (car != null)
            {
                car.position = Vector3.Lerp(driveFrom, driveTo, eased);
                Vector3 dir = DriveDirection(eased);
                if (dir.sqrMagnitude > 0.0001f)
                    car.rotation = Quaternion.LookRotation(dir, Vector3.up);
            }

            yield return null;
        }

        if (player != null)
        {
            if (playerSpawn != null)
                player.transform.position = playerSpawn.position;

            player.transform.rotation = Quaternion.Euler(0f, 180f, 0f);
            player.EnableControl(true);
        }

        finished = true;
    }

    private Vector3 DriveDirection(float t)
    {
        Vector3 dir = driveTo - driveFrom;
        dir.y = 0f;
        return dir.normalized;
    }
}
