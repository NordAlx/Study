using System;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

internal static partial class MazeSceneSetup
{
    [MenuItem("Coin Maze/2. Create Player and Prefabs")]
    private static void CreatePrefabs()
    {
        if (EditorSceneManager.GetActiveScene().path != ScenePath)
        {
            Debug.LogError("Open the Maze scene before creating the prefabs.");
            return;
        }

        EnsureFolder(Prefabs);
        var wall = MaterialAsset("Wall", 0x30516A);
        var cap = MaterialAsset("WallCap", 0x527D93);
        var teal = MaterialAsset("PlayerTurquoise", 0x3CD9CC, 0.45f);
        var visor = MaterialAsset("PlayerVisor", 0x143A4A, 0.65f);
        var ghost = MaterialAsset("GhostIvory", 0xEEE9FD, 0.4f);
        var shadow = MaterialAsset("GhostViolet", 0x7D62BE);
        var ink = MaterialAsset("Eye", 0x281E40);
        var rim = MaterialAsset("CoinRim", 0xBD6B1D, 0.45f);
        var gold = MaterialAsset("CoinGold", 0xFFCE56, 0.45f);
        var mark = MaterialAsset("CoinStamp", 0xFFF0A0, 0.45f);

        PrefabAsset("Wall", root =>
        {
            Part(root, "Stone", PrimitiveType.Cube, new Vector3(0, 0.48f, 0),
                new Vector3(CellSize, 0.96f, CellSize), wall, true);
            Part(root, "Coping", PrimitiveType.Cube, new Vector3(0, 0.99f, 0),
                new Vector3(1.29f, 0.11f, 1.29f), cap);
        });

        var coinPrefab = PrefabAsset("Coin", root =>
        {
            var face = new GameObject("Tilted Coin");
            face.transform.SetParent(root, false);
            face.transform.localPosition = new Vector3(0, 0.45f, 0);
            face.transform.localRotation = Quaternion.Euler(-38, 0, 0);
            Part(face.transform, "Rim", PrimitiveType.Cylinder, Vector3.zero,
                new Vector3(0.58f, 0.048f, 0.58f), rim);
            Part(face.transform, "Face", PrimitiveType.Cylinder, new Vector3(0, 0.045f, 0),
                new Vector3(0.49f, 0.011f, 0.49f), gold);
            Part(face.transform, "Stamp", PrimitiveType.Cube, new Vector3(0, 0.059f, 0),
                new Vector3(0.065f, 0.017f, 0.23f), mark);
        });

        var player = PrefabAsset("Player", root =>
        {
            Part(root, "Suit", PrimitiveType.Capsule, new Vector3(0, 0.49f, 0),
                new Vector3(0.62f, 0.49f, 0.62f), teal, true);
            Part(root, "Visor", PrimitiveType.Sphere, new Vector3(0, 0.63f, -0.2f),
                new Vector3(0.49f, 0.25f, 0.3f), visor);
        });

        var ghostPrefab = PrefabAsset("Ghost", root =>
        {
            Part(root, "Shadow", PrimitiveType.Cylinder, new Vector3(0, 0.017f, 0),
                new Vector3(0.82f, 0.012f, 0.82f), shadow);
            Part(root, "Body", PrimitiveType.Capsule, new Vector3(0, 0.72f, 0),
                new Vector3(0.71f, 0.5f, 0.66f), ghost, true);
            for (int i = -1; i <= 1; i++)
                Part(root, $"Hem {i + 2}", PrimitiveType.Sphere,
                    new Vector3(i * 0.2f, 0.36f, -0.07f), new Vector3(0.28f, 0.28f, 0.55f), ghost);
            for (int i = -1; i <= 1; i += 2)
                Part(root, i < 0 ? "Left Eye" : "Right Eye", PrimitiveType.Sphere,
                    new Vector3(i * 0.13f, 0.88f, -0.27f), new Vector3(0.105f, 0.19f, 0.11f), ink);
        });

        PlacePrefab(player, new Vector3(-5 * CellSize, 0, -3 * CellSize));
        PlacePrefab(ghostPrefab, new Vector3(5 * CellSize, 0, 3 * CellSize));
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());
        AssetDatabase.SaveAssets();
        Selection.activeObject = coinPrefab;
        EditorGUIUtility.PingObject(coinPrefab);
    }

    private static GameObject PrefabAsset(string name, Action<Transform> build)
    {
        string path = $"{Prefabs}/{name}.prefab";
        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
        if (prefab != null)
            return prefab;

        var root = new GameObject(name);
        try
        {
            build(root.transform);
            return PrefabUtility.SaveAsPrefabAsset(root, path);
        }
        finally
        {
            UnityEngine.Object.DestroyImmediate(root);
        }
    }

    private static void PlacePrefab(GameObject prefab, Vector3 position)
    {
        if (GameObject.Find(prefab.name) != null)
            return;

        var instance = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        instance.transform.position = position;
    }
}
