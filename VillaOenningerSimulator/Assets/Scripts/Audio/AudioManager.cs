using UnityEngine;

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    [Header("Audio Sources")]
    [SerializeField] private AudioSource ambientSource;
    [SerializeField] private AudioSource uiSource;
    [SerializeField] private AudioSource wreckerSource;

    [Header("Clips")]
    public AudioClip introAmbient;
    public AudioClip typewriter;
    public AudioClip transitionSwoosh;
    public AudioClip robotEngine;
    public AudioClip wallCrash;

    private void Awake() => Instance = this;

    public void StartRobotEngine()
    {
        wreckerSource.clip = robotEngine;
        wreckerSource.loop = true;
        wreckerSource.Play();
    }

    public void PlayCrashSound(Vector3 pos)
    {
        AudioSource.PlayClipAtPoint(wallCrash, pos, 1f);
    }
}
