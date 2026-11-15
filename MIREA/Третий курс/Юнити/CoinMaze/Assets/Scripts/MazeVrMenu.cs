using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public sealed class MazeVrMenu : MonoBehaviour
{
    [SerializeField] private GameObject panel;
    [SerializeField] private Button simulation;
    [SerializeField] private Button open;

    public void Show()
    {
        panel.SetActive(true);
        EventSystem.current?.SetSelectedGameObject(simulation.gameObject);
    }

    public void Hide()
    {
        panel.SetActive(false);
        EventSystem.current?.SetSelectedGameObject(open.gameObject);
    }

    public void StartSimulation() => MazeRunResult.PlayView(MazeRunResult.ViewMode.Simulation);
    public void StartHeadset() => MazeRunResult.PlayView(MazeRunResult.ViewMode.OpenXR);
}
