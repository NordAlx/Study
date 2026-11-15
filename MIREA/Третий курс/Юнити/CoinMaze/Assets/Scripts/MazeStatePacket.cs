using System;
using System.IO;

public readonly struct MazeStatePacket
{
    private const uint Signature = 0x314D5A43;
    public const int Length = 32;

    public readonly int Seed, TotalCoins, Coins, Health, Sequence;
    public readonly float X, Z;

    public MazeStatePacket(int seed, int totalCoins, float x, float z, int coins, int health, int sequence)
    {
        Seed = seed;
        TotalCoins = totalCoins;
        X = x;
        Z = z;
        Coins = coins;
        Health = health;
        Sequence = sequence;
    }

    public byte[] Encode()
    {
        using var bytes = new MemoryStream(Length);
        using var writer = new BinaryWriter(bytes);
        writer.Write(Signature);
        writer.Write(Seed);
        writer.Write(TotalCoins);
        writer.Write(X);
        writer.Write(Z);
        writer.Write(Coins);
        writer.Write(Health);
        writer.Write(Sequence);
        return bytes.ToArray();
    }

    public static bool TryDecode(byte[] bytes, out MazeStatePacket packet)
    {
        packet = default;
        if (bytes.Length != Length)
            return false;

        using var reader = new BinaryReader(new MemoryStream(bytes, false));
        if (reader.ReadUInt32() != Signature)
            return false;

        var value = new MazeStatePacket(reader.ReadInt32(), reader.ReadInt32(), reader.ReadSingle(),
            reader.ReadSingle(), reader.ReadInt32(), reader.ReadInt32(), reader.ReadInt32());
        if (value.TotalCoins < 1 || value.Coins < 0 || value.Coins > value.TotalCoins || value.Health < 0
            || !(Math.Abs(value.X) <= 50f && Math.Abs(value.Z) <= 50f) || value.Sequence < 1)
            return false;

        packet = value;
        return true;
    }
}
