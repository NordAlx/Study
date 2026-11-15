using UnityEngine;
using UnityEngine.SceneManagement;

public readonly struct MazeRunResult
{
    public const string MenuScene = "MainMenu";
    public const string GameScene = "Maze";
    public const string ResultScene = "Result";

    public enum ViewMode { Desktop, Simulation, OpenXR }

    public static MazeRunResult? Last { get; private set; }
    public static ViewMode View { get; private set; }

    public int Coins { get; }
    public int TotalCoins { get; }
    public int Health { get; }
    public bool Won => Health > 0 && Coins >= TotalCoins;

    private MazeRunResult(int coins, int totalCoins, int health)
    {
        Coins = coins;
        TotalCoins = totalCoins;
        Health = health;
    }

    public static void Play()
    {
        Last = null;
        SceneManager.LoadScene(GameScene);
    }

    public static void PlayView(ViewMode view)
    {
        View = view;
        Play();
    }

    public static void OpenMenu()
    {
        Reset();
        MazePeerSession.Close();
        SceneManager.LoadScene(MenuScene);
    }

    public static void Finish(int coins, int totalCoins, int health)
    {
        Last = new MazeRunResult(coins, totalCoins, health);
        SceneManager.LoadScene(ResultScene);
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void Reset()
    {
        Last = null;
        View = ViewMode.Desktop;
    }
}
