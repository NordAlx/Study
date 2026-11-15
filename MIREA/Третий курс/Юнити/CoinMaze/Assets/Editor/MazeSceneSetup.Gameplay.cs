using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

internal static partial class MazeSceneSetup
{
    [MenuItem("Coin Maze/3. Connect Gameplay Scripts")]
    private static void ConnectGameplay()
    {
        if (EditorSceneManager.GetActiveScene().path != ScenePath)
        {
            Debug.LogError("Open the Maze scene before connecting the gameplay scripts.");
            return;
        }

        var playerObject = GameObject.Find("Player");
        var ghost = GameObject.Find("Ghost");
        var wall = AssetDatabase.LoadAssetAtPath<GameObject>($"{Prefabs}/Wall.prefab");
        var coin = AssetDatabase.LoadAssetAtPath<GameObject>($"{Prefabs}/Coin.prefab");
        if (playerObject == null || ghost == null || wall == null || coin == null)
        {
            Debug.LogError("Create the player and prefabs before connecting the gameplay scripts.");
            return;
        }

        var player = playerObject.GetComponent<MazePlayer>();
        if (player == null)
            player = Undo.AddComponent<MazePlayer>(playerObject);

        var generatorObject = GameObject.Find("Maze Generator");
        if (generatorObject == null)
        {
            generatorObject = new GameObject("Maze Generator");
            Undo.RegisterCreatedObjectUndo(generatorObject, "Create Maze Generator");
        }

        var generator = generatorObject.GetComponent<MazeGenerator>();
        if (generator == null)
            generator = Undo.AddComponent<MazeGenerator>(generatorObject);

        var settings = new SerializedObject(generator);
        settings.FindProperty("wallPrefab").objectReferenceValue = wall;
        settings.FindProperty("coinPrefab").objectReferenceValue = coin;
        settings.FindProperty("player").objectReferenceValue = player;
        settings.FindProperty("ghost").objectReferenceValue = ghost.transform;
        settings.ApplyModifiedProperties();
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene());

        Selection.activeGameObject = generatorObject;
        var script = MonoScript.FromMonoBehaviour(generator);
        EditorGUIUtility.PingObject(script);
    }
}
