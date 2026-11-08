using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class IntroController : MonoBehaviour
{
    [Header("UI References")]
    public GameObject introPanel;
    public CanvasGroup introCanvasGroup;
    public Text lawsText;
    public GameObject gameplayHUD;

    [Header("Timing")]
    public float delayBetweenLaws = 4.0f;
    public float fadeDuration = 1.5f;
    public float holdBeforeDrive = 1.0f;

    [Header("Scene")]
    public ArrivalSequence arrival;
    public CollapseDirector collapseDirector;
    public float collapseDelayAfterArrival = 5f;

    private readonly string[] asimovLaws = new string[]
    {
        "ЗАКОН I\n\nРобот не может причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.",
        "ЗАКОН II\n\nРобот должен повиноваться всем приказам, которые даёт человек, кроме случаев, когда эти приказы противоречат Первому Закону.",
        "ЗАКОН III\n\nРобот должен заботиться о своей безопасности в той мере, в какой это не противоречит Первому и Второму Законам."
    };

    private void Start()
    {
        if (gameplayHUD != null)
            gameplayHUD.SetActive(false);

        if (introPanel != null)
            introPanel.SetActive(true);

        if (introCanvasGroup != null)
            introCanvasGroup.alpha = 1f;

        StartCoroutine(ExecuteIntroSequence());
    }

    private IEnumerator ExecuteIntroSequence()
    {
        if (lawsText != null)
        {
            for (int i = 0; i < asimovLaws.Length; i++)
            {
                lawsText.text = asimovLaws[i];
                lawsText.canvasRenderer.SetAlpha(0f);
                lawsText.CrossFadeAlpha(1f, 0.5f, false);
                yield return new WaitForSeconds(delayBetweenLaws);

                if (i < asimovLaws.Length - 1)
                {
                    lawsText.CrossFadeAlpha(0f, 0.5f, false);
                    yield return new WaitForSeconds(0.6f);
                }
            }
        }

        yield return new WaitForSeconds(holdBeforeDrive);

        if (introCanvasGroup != null)
        {
            float elapsed = 0f;
            while (elapsed < fadeDuration)
            {
                elapsed += Time.deltaTime;
                introCanvasGroup.alpha = Mathf.Lerp(1f, 0f, elapsed / fadeDuration);
                yield return null;
            }
        }

        if (introPanel != null)
            introPanel.SetActive(false);

        if (gameplayHUD != null)
            gameplayHUD.SetActive(true);

        if (arrival != null)
            arrival.Play();

        yield return new WaitForSeconds(collapseDelayAfterArrival);

        if (collapseDirector != null)
            collapseDirector.StartCollapse();
    }
}
