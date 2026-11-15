using System.Collections.Generic;
using UnityEngine;

public sealed class MazeGenerator : MonoBehaviour
{
    private const int Columns = 13;
    private const int Rows = 9;
    private const float CellSize = 1.35f;

    private static readonly Vector2Int StartCell = new(1, 1);
    private static readonly Vector2Int[] Directions =
    {
        Vector2Int.right, Vector2Int.up, Vector2Int.left, Vector2Int.down
    };

    [SerializeField] private int seed = 17;
    [SerializeField, Min(1)] private int coinCount = 12;
    [SerializeField] private GameObject wallPrefab;
    [SerializeField] private GameObject coinPrefab;
    [SerializeField] private MazePlayer player;
    [SerializeField] private Transform ghost;

    private readonly bool[,] passages = new bool[Columns, Rows];

    public int Seed => seed;
    public int TotalCoins { get; private set; }

    private void Awake()
    {
        if (wallPrefab == null || coinPrefab == null || player == null || ghost == null)
        {
            Debug.LogError("Assign the wall, coin, player and ghost in the Maze Generator.", this);
            return;
        }

        var random = new System.Random(seed);
        Vector2Int ghostCell = CarvePassages(random);
        Transform walls = PlaceObjects(random, ghostCell);
        ghost.position = WorldPoint(ghostCell);
        player.Initialize(WorldPoint(StartCell));

        if (TryGetComponent(out MazeNavigation navigation) && ghost.TryGetComponent(out MazeGhost pursuer))
            navigation.Build(walls, pursuer, player);
    }

    public bool IsPassage(Vector2Int cell)
    {
        return cell.x >= 0 && cell.x < Columns && cell.y >= 0 && cell.y < Rows
            && passages[cell.x, cell.y];
    }

    public Vector3 WorldPoint(Vector2Int cell)
    {
        return transform.position + new Vector3(
            (cell.x - (Columns - 1) * 0.5f) * CellSize, 0,
            (cell.y - (Rows - 1) * 0.5f) * CellSize);
    }

    // Randomized depth-first search carves a connected maze. The longest branch holds the ghost.
    private Vector2Int CarvePassages(System.Random random)
    {
        Vector2Int east = StartCell + Vector2Int.right * 2;
        var stack = new Stack<Vector2Int>();
        var candidates = new List<Vector2Int>(4);
        Open(StartCell);
        Open(StartCell + Vector2Int.right);
        Open(east);
        stack.Push(StartCell);
        stack.Push(east);
        Vector2Int deepestCell = east;
        int maxDepth = stack.Count;

        while (stack.Count > 0)
        {
            Vector2Int cell = stack.Peek();
            candidates.Clear();
            foreach (Vector2Int direction in Directions)
            {
                Vector2Int next = cell + direction * 2;
                if (next.x > 0 && next.x < Columns - 1 && next.y > 0 && next.y < Rows - 1
                    && !IsPassage(next))
                    candidates.Add(direction);
            }

            if (candidates.Count == 0)
            {
                stack.Pop();
                continue;
            }

            Vector2Int chosen = candidates[random.Next(candidates.Count)];
            Vector2Int destination = cell + chosen * 2;
            Open(cell + chosen);
            Open(destination);
            stack.Push(destination);
            if (stack.Count > maxDepth)
            {
                deepestCell = destination;
                maxDepth = stack.Count;
            }
        }

        return deepestCell;
    }

    private void Open(Vector2Int cell)
    {
        passages[cell.x, cell.y] = true;
    }

    private Transform PlaceObjects(System.Random random, Vector2Int ghostCell)
    {
        Transform walls = CreateGroup("Generated Walls");
        Transform pickups = CreateGroup("Generated Coins");
        Vector2Int firstCoin = StartCell + Vector2Int.right;
        var candidates = new List<Vector2Int>();

        for (int row = 0; row < Rows; row++)
        {
            for (int column = 0; column < Columns; column++)
            {
                var cell = new Vector2Int(column, row);
                if (!IsPassage(cell))
                {
                    var wall = Instantiate(wallPrefab, WorldPoint(cell), Quaternion.identity, walls);
                    wall.name = $"Wall {row:00}-{column:00}";
                }
                else if (cell != StartCell && cell != ghostCell && cell != firstCoin)
                {
                    candidates.Add(cell);
                }
            }
        }

        PlaceCoin(firstCoin, pickups, 1);
        int extraCoins = Mathf.Clamp(coinCount - 1, 0, candidates.Count);
        for (int i = 0; i < extraCoins; i++)
        {
            int index = random.Next(i, candidates.Count);
            (candidates[i], candidates[index]) = (candidates[index], candidates[i]);
            PlaceCoin(candidates[i], pickups, i + 2);
        }

        TotalCoins = pickups.childCount;
        return walls;
    }

    private Transform CreateGroup(string groupName)
    {
        var group = new GameObject(groupName).transform;
        group.SetParent(transform, false);
        return group;
    }

    private void PlaceCoin(Vector2Int cell, Transform parent, int number)
    {
        var coin = Instantiate(coinPrefab, WorldPoint(cell), Quaternion.identity, parent);
        coin.name = $"Coin {number:00}";
    }
}
