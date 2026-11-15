using System.Net;
using UnityEngine;

public static class MazePeerSession
{
    public const int Port = 47850;
    public static MazePeerLink Current { get; private set; }

    public static void Open(IPAddress address, bool host)
    {
        Close();
        Current = new MazePeerLink();
        Current.Open(address, Port, host);
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    public static void Close()
    {
        Current?.Dispose();
        Current = null;
    }
}
