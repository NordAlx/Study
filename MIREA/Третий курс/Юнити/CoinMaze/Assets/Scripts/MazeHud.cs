using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public sealed class MazeHud : MonoBehaviour
{
    [SerializeField] private MazePlayer player;
    [SerializeField] private MazeGenerator maze;
    [SerializeField] private Text coins;
    [SerializeField] private Text health;
    [SerializeField] private RectTransform healthFill;
    [SerializeField] private GameObject pausePanel;
    [SerializeField] private Button resumeButton;
    [SerializeField] private Button pauseButton;

    private int displayedCoins = -1;
    private int displayedHealth = -1;
    private bool paused;
    private bool leavingScene;

    public bool IsPaused => paused;

    public void TogglePause()
    {
        if (!leavingScene)
            SetPaused(!paused);
    }

    private void Update()
    {
        if (leavingScene || maze.TotalCoins == 0)
            return;

        int collected = player.CoinsCollected;
        int remainingHealth = player.CurrentHealth;
        if (displayedCoins != collected)
        {
            displayedCoins = collected;
            coins.text = $"{collected} / {maze.TotalCoins}";
        }

        if (displayedHealth != remainingHealth)
        {
            displayedHealth = remainingHealth;
            health.text = $"{remainingHealth} / {player.MaxHealth}";
            healthFill.anchorMax = new Vector2((float)remainingHealth / player.MaxHealth, 1f);
        }

        if (remainingHealth == 0 || collected >= maze.TotalCoins)
        {
            leavingScene = true;
            if (paused)
                SetPaused(false);
            MazeRunResult.Finish(collected, maze.TotalCoins, remainingHealth);
            return;
        }

        if (Keyboard.current?.escapeKey.wasPressedThisFrame == true)
            TogglePause();
    }

    public void Pause()
    {
        if (!paused && !leavingScene)
            SetPaused(true);
    }

    public void Resume()
    {
        if (paused)
            SetPaused(false);
    }

    public void OpenMenu()
    {
        if (leavingScene)
            return;

        leavingScene = true;
        Resume();
        MazeRunResult.OpenMenu();
    }

    private void SetPaused(bool value)
    {
        paused = value;
        Time.timeScale = value ? 0f : 1f;
        AudioListener.pause = value;
        pausePanel.SetActive(value);
        pauseButton.interactable = !value;
        EventSystem.current?.SetSelectedGameObject(value ? resumeButton.gameObject : null);
    }

    private void OnDisable()
    {
        if (!paused)
            return;

        Time.timeScale = 1f;
        AudioListener.pause = false;
    }
}
