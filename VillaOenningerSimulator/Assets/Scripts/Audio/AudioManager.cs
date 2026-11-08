using UnityEngine;

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    public AudioSource ambientSource;
    public AudioSource uiSource;
    public AudioSource wreckerSource;

    public AudioClip introAmbient;
    public AudioClip typewriter;
    public AudioClip transitionSwoosh;
    public AudioClip robotEngine;
    public AudioClip wallCrash;

    private void Awake()
    {
        Instance = this;
    }

    public void StartRobotEngine()
    {
        if (wreckerSource == null || robotEngine == null) return;
        wreckerSource.clip = robotEngine;
        wreckerSource.loop = true;
        wreckerSource.Play();
    }

    public void PlayCrashSound(Vector3 pos)
    {
        if (wallCrash == null) return;
        AudioSource.PlayClipAtPoint(wallCrash, pos, 1f);
    }
}
