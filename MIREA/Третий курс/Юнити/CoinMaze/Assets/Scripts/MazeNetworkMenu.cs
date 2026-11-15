using System.Net;
using System.Net.Sockets;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public sealed class MazeNetworkMenu : MonoBehaviour
{
    [SerializeField] private GameObject panel;
    [SerializeField] private InputField address;
    [SerializeField] private Text status;
    [SerializeField] private Button hostButton;
    [SerializeField] private Button joinButton;
    [SerializeField] private Button openButton;

    private MazePeerLink link;
    private bool enteredMaze;
    private float deadline;

    public void Show()
    {
        panel.SetActive(true);
        EventSystem.current?.SetSelectedGameObject(hostButton.gameObject);
    }

    public void Close()
    {
        MazePeerSession.Close();
        link = null;
        status.text = "Один игрок создаёт комнату, второй подключается.";
        hostButton.interactable = joinButton.interactable = true;
        panel.SetActive(false);
        EventSystem.current?.SetSelectedGameObject(openButton.gameObject);
    }

    public void Host() => Open(true);
    public void Join() => Open(false);

    private void Open(bool host)
    {
        if (!IPAddress.TryParse(address.text.Trim(), out var ip) || ip.AddressFamily != AddressFamily.InterNetwork
            || ip.Equals(IPAddress.Any) || ip.Equals(IPAddress.Broadcast))
        {
            status.text = "Укажите IPv4-адрес компьютера, который создаёт комнату.";
            return;
        }

        MazePeerSession.Open(ip, host);
        link = MazePeerSession.Current;
        deadline = Time.unscaledTime + 12f;
        hostButton.interactable = joinButton.interactable = false;
    }

    private void Update()
    {
        if (link == null || enteredMaze)
            return;

        link.UpdateConnection();
        if (link.Connected)
        {
            enteredMaze = true;
            MazeRunResult.Play();
            return;
        }
        if (!link.Hosting && Time.unscaledTime >= deadline && link.Status == "Подключаемся…")
            link.Fail("Время подключения истекло");
        status.text = link.Status;
        bool waiting = link.Status == "Ожидаем второго игрока…" || link.Status == "Подключаемся…";
        hostButton.interactable = joinButton.interactable = !waiting;
    }

    private void OnDestroy()
    {
        if (!enteredMaze && link != null)
            MazePeerSession.Close();
    }
}
