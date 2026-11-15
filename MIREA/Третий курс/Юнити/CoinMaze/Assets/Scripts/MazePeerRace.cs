using UnityEngine;
using UnityEngine.UI;

public sealed class MazePeerRace : MonoBehaviour
{
    [SerializeField] private MazePlayer player;
    [SerializeField] private MazeGenerator maze;
    [SerializeField] private GameObject remotePlayer;
    [SerializeField] private Text status;

    private MazePeerLink link;
    private float nextSend;
    private int sequence;
    private MazeStatePacket last;
    private Vector3 target;

    public MazeStatePacket LastReceived => last;
    public int SentCount => sequence;

    private void Start()
    {
        link = MazePeerSession.Current;
        remotePlayer.SetActive(false);
        status.gameObject.SetActive(link != null);
    }

    private void Update()
    {
        if (link == null)
            return;

        if (link.Connected && Time.unscaledTime >= nextSend)
        {
            nextSend = Time.unscaledTime + 0.1f;
            Vector3 pos = player.transform.position;
            if (link.Send(new MazeStatePacket(maze.Seed, maze.TotalCoins, pos.x, pos.z,
                    player.CoinsCollected, player.CurrentHealth, sequence + 1)))
                sequence++;
        }

        for (int i = 0; i < 32 && link.TryReceive(out var packet); i++)
        {
            if (packet.Seed != maze.Seed || packet.TotalCoins != maze.TotalCoins || packet.Health > player.MaxHealth)
            {
                link.Fail("У второго игрока другая версия лабиринта");
                break;
            }
            if (packet.Sequence <= last.Sequence)
                continue;
            last = packet;
            target = new Vector3(packet.X, 0f, packet.Z);
            if (!remotePlayer.activeSelf)
            {
                remotePlayer.transform.position = target;
                remotePlayer.SetActive(true);
            }
        }

        if (!link.Connected)
        {
            remotePlayer.SetActive(false);
            status.text = link.Status;
            return;
        }

        if (last.Sequence == 0)
        {
            status.text = "Ожидаем пакет состояния…";
            return;
        }

        remotePlayer.transform.position = Vector3.Lerp(remotePlayer.transform.position, target,
            1f - Mathf.Exp(-15f * Time.unscaledDeltaTime));
        status.text = $"Игрок 2   Монеты {last.Coins}/{last.TotalCoins}   Здоровье {last.Health}";
    }

    private void OnDestroy()
    {
        if (link != null && MazePeerSession.Current == link)
            MazePeerSession.Close();
    }
}
