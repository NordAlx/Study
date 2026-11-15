using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;

public sealed class MazePeerLink : IDisposable
{
    private readonly byte[] incoming = new byte[MazeStatePacket.Length];
    private TcpListener listener;
    private TcpClient client;
    private Task<TcpClient> opening;
    private Task sending;
    private NetworkStream stream;
    private int received;

    public bool Connected => stream != null;
    public bool Hosting { get; private set; }
    public string Status { get; private set; }

    public void Open(IPAddress address, int port, bool host)
    {
        Hosting = host;
        Status = host ? "Ожидаем второго игрока…" : "Подключаемся…";
        try
        {
            if (host)
            {
                listener = new TcpListener(address, port);
                listener.Start(1);
                opening = listener.AcceptTcpClientAsync();
            }
            else
            {
                client = new TcpClient(AddressFamily.InterNetwork);
                opening = Connect(client, address, port);
            }
        }
        catch (SocketException error)
        {
            Fail("Ошибка сети: " + error.SocketErrorCode);
        }
    }

    public void UpdateConnection()
    {
        if (opening == null || !opening.IsCompleted)
            return;

        var completed = opening;
        opening = null;
        try
        {
            client = completed.GetAwaiter().GetResult();
            client.NoDelay = true;
            stream = client.GetStream();
            listener?.Stop();
            listener = null;
            Status = "Соединение установлено";
        }
        catch (Exception error) when (error is SocketException || error is IOException || error is ObjectDisposedException)
        {
            Fail("Не удалось установить соединение");
        }
    }

    public bool Send(MazeStatePacket packet)
    {
        if (!Connected || (sending != null && !sending.IsCompleted))
            return false;

        try
        {
            sending?.GetAwaiter().GetResult();
            byte[] bytes = packet.Encode();
            sending = stream.WriteAsync(bytes, 0, bytes.Length);
            return true;
        }
        catch (Exception error) when (error is IOException || error is SocketException || error is ObjectDisposedException)
        {
            Fail("Связь прервана");
            return false;
        }
    }

    public bool TryReceive(out MazeStatePacket packet)
    {
        packet = default;
        if (!Connected)
            return false;

        try
        {
            Socket socket = client.Client;
            int available = socket.Available;
            if (available == 0)
            {
                if (socket.Poll(0, SelectMode.SelectRead))
                    Fail("Второй игрок отключился");
                return false;
            }

            int read = socket.Receive(incoming, received, Math.Min(available, incoming.Length - received), SocketFlags.None);
            if (read == 0)
            {
                Fail("Второй игрок отключился");
                return false;
            }

            received += read;
            if (received < incoming.Length)
                return false;

            received = 0;
            if (MazeStatePacket.TryDecode(incoming, out packet))
                return true;

            Fail("Получен несовместимый пакет");
            return false;
        }
        catch (Exception error) when (error is SocketException || error is ObjectDisposedException)
        {
            Fail("Связь прервана");
            return false;
        }
    }

    public void Fail(string message)
    {
        Dispose();
        Status = message;
    }

    public void Dispose()
    {
        stream = null;
        listener?.Stop();
        listener = null;
        client?.Close();
        client = null;

        if (opening != null)
        {
            _ = opening.ContinueWith(completed =>
            {
                if (completed.Status == TaskStatus.RanToCompletion)
                    completed.Result.Close();
                else
                    _ = completed.Exception;
            }, TaskScheduler.Default);
            opening = null;
        }
        if (sending != null)
        {
            _ = sending.ContinueWith(completed => { _ = completed.Exception; }, TaskScheduler.Default);
            sending = null;
        }
    }

    private static async Task<TcpClient> Connect(TcpClient client, IPAddress address, int port)
    {
        await client.ConnectAsync(address, port).ConfigureAwait(false);
        return client;
    }
}
