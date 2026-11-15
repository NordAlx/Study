using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;

internal static partial class MazeSceneSetup
{
    private const string ScenePath = "Assets/Scenes/Maze.unity";
    private const string Materials = "Assets/Materials";
    private const string Prefabs = "Assets/Prefabs";
    private const int Columns = 13;
    private const int Rows = 9;
    private const float CellSize = 1.35f;

    [MenuItem("Coin Maze/1. Create Maze Scene")]
    private static void CreateScene()
    {
        if (AssetDatabase.LoadAssetAtPath<SceneAsset>(ScenePath) != null)
        {
            EditorSceneManager.OpenScene(ScenePath);
            return;
        }

        if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
            return;

        EnsureFolder(Materials);
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        var stage = new GameObject("Environment");
        var floor = MaterialAsset("Floor", 0x273F54);
        var baseMaterial = MaterialAsset("Platform", 0x142337);
        Part(stage.transform, "Platform", PrimitiveType.Cube,
            new Vector3(0, -0.33f, 0), new Vector3(18.7f, 0.6f, 13.3f), baseMaterial, true);
        Part(stage.transform, "Floor", PrimitiveType.Cube,
            new Vector3(0, -0.1f, 0), new Vector3(Columns * CellSize, 0.2f, Rows * CellSize), floor, true);

        var camera = new GameObject("Main Camera").AddComponent<Camera>();
        camera.tag = "MainCamera";
        camera.gameObject.AddComponent<AudioListener>();
        camera.transform.position = new Vector3(0, 17, -10.6f);
        camera.transform.LookAt(new Vector3(0, 0, 0.45f));
        camera.orthographic = true;
        camera.orthographicSize = 7.65f;
        camera.clearFlags = CameraClearFlags.SolidColor;
        camera.backgroundColor = ColorOf(0x0D1625);

        var sun = new GameObject("Key Light").AddComponent<Light>();
        sun.type = LightType.Directional;
        sun.color = ColorOf(0xFFF0D8);
        sun.intensity = 1.65f;
        sun.shadows = LightShadows.Soft;
        sun.transform.rotation = Quaternion.Euler(55, -35, 0);
        RenderSettings.ambientMode = AmbientMode.Flat;
        RenderSettings.ambientLight = ColorOf(0x7E9AC0);

        EditorSceneManager.SaveScene(scene, ScenePath);
        EditorBuildSettings.scenes = new[] { new EditorBuildSettingsScene(ScenePath, true) };
        Selection.activeGameObject = stage;
        FrameScene();
    }

    private static void EnsureFolder(string path)
    {
        if (!AssetDatabase.IsValidFolder(path))
            AssetDatabase.CreateFolder("Assets", System.IO.Path.GetFileName(path));
    }

    private static Color ColorOf(int rgb)
    {
        return new Color32((byte)(rgb >> 16), (byte)(rgb >> 8), (byte)rgb, 255);
    }

    private static Material MaterialAsset(string name, int rgb, float smoothness = 0.25f)
    {
        string path = $"{Materials}/{name}.mat";
        var material = AssetDatabase.LoadAssetAtPath<Material>(path);
        if (material != null)
            return material;

        material = new Material(Shader.Find("Universal Render Pipeline/Lit"));
        material.color = ColorOf(rgb);
        material.SetFloat("_Smoothness", smoothness);
        AssetDatabase.CreateAsset(material, path);
        return material;
    }

    private static GameObject Part(Transform parent, string name, PrimitiveType primitive,
        Vector3 position, Vector3 scale, Material material, bool keepCollider = false)
    {
        var part = GameObject.CreatePrimitive(primitive);
        part.name = name;
        part.transform.SetParent(parent, false);
        part.transform.localPosition = position;
        part.transform.localScale = scale;
        part.GetComponent<Renderer>().sharedMaterial = material;
        if (!keepCollider)
            Object.DestroyImmediate(part.GetComponent<Collider>());
        return part;
    }

    private static void FrameScene()
    {
        SceneView.lastActiveSceneView?.LookAt(Vector3.zero, Quaternion.Euler(58, 0, 0), 14, true, true);
    }
}
