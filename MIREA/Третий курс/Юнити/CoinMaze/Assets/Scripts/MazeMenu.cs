using UnityEngine;

public sealed class MazeMenu : MonoBehaviour
{
    public void Play() => MazeRunResult.Play();

    public void OpenMenu() => MazeRunResult.OpenMenu();
}
