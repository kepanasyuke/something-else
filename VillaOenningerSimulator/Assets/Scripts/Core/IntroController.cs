using UnityEngine;
using TMPro;
using System.Collections;

[RequireComponent(typeof(HouseDestructionManager))]
public class IntroController : MonoBehaviour
{
    [Header("UI References")]
    [SerializeField] private GameObject introPanel;
    [SerializeField] private CanvasGroup introCanvasGroup;
    [SerializeField] private TextMeshProUGUI lawsTextMesh;
    [SerializeField] private GameObject gameplayHUD;

    [Header("Timing Settings")]
    [SerializeField] private float delayBetweenLaws = 4.0f;
    [SerializeField] private float fadeDuration = 1.5f;

    private readonly string[] asimovLaws = new string[]
    {
        "<color=#FF3333>ЗАКОН I</color>\n\nРобот не может причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.",
        "<color=#FF3333>ЗАКОН II</color>\n\nРобот должен повиноваться всем приказам, которые даёт человек, кроме случаев, когда эти приказы противоречат Первому Закону.",
        "<color=#FF3333>ЗАКОН III</color>\n\nРобот должен заботиться о своей безопасности в той мере, в какой это не противоречит Первому и Второму Законам."
    };

    private void Start()
    {
        gameplayHUD.SetActive(false);
        introPanel.SetActive(true);
        introCanvasGroup.alpha = 1f;
        StartCoroutine(ExecuteIntroSequence());
    }

    private IEnumerator ExecuteIntroSequence()
    {
        for (int i = 0; i < asimovLaws.Length; i++)
        {
            lawsTextMesh.text = asimovLaws[i];
            lawsTextMesh.canvasRenderer.SetAlpha(0.0f);
            lawsTextMesh.CrossFadeAlpha(1.0f, 0.5f, false);
            yield return new WaitForSeconds(delayBetweenLaws);
            if (i < asimovLaws.Length - 1)
            {
                lawsTextMesh.CrossFadeAlpha(0.0f, 0.5f, false);
                yield return new WaitForSeconds(0.6f);
            }
        }

        float elapsedTime = 0f;
        while (elapsedTime < fadeDuration)
        {
            elapsedTime += Time.deltaTime;
            introCanvasGroup.alpha = Mathf.Lerp(1f, 0f, elapsedTime / fadeDuration);
            yield return null;
        }

        introPanel.SetActive(false);
        gameplayHUD.SetActive(true);
        if (Camera.main != null && Camera.main.TryGetComponent<AdvancedSimsCamera>(out var simsCam))
            simsCam.enabled = true;
    }
}
