using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;

public static class SceneBuilder
{
    [MenuItem("Tools/Build Default Scene")]
    public static void BuildScene()
    {
        Scene scene = SceneManager.GetActiveScene();
        if (scene.name != "SampleScene" || scene.rootCount == 0)
        {
            scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);
            CreateDefaultObjects();
            EditorSceneManager.SaveScene(scene, "Assets/Scenes/SampleScene.unity");
            Debug.Log("✅ Сцена создана с базовыми объектами.");
        }
    }

    private static void CreateDefaultObjects()
    {
        // Камера
        GameObject cam = GameObject.Find("Main Camera");
        if (cam == null) cam = new GameObject("Main Camera");
        cam.tag = "MainCamera";
        cam.AddComponent<Camera>();
        cam.transform.position = new Vector3(10, 8, -10);
        cam.transform.LookAt(Vector3.zero);

        // Свет
        GameObject light = GameObject.Find("Directional Light");
        if (light == null) light = new GameObject("Directional Light");
        Light l = light.GetComponent<Light>();
        if (l == null) l = light.AddComponent<Light>();
        l.type = LightType.Directional;
        light.transform.rotation = Quaternion.Euler(50, -30, 0);

        // Робот
        GameObject robot = GameObject.Find("Robot");
        if (robot == null) robot = GameObject.CreatePrimitive(PrimitiveType.Capsule);
        robot.name = "Robot";
        robot.tag = "Player";
        robot.transform.position = new Vector3(0, 1, 0);
        var rb = robot.GetComponent<Rigidbody>();
        if (rb == null) rb = robot.AddComponent<Rigidbody>();
        rb.isKinematic = true;
        robot.AddComponent<AdvancedRobotWrecker>();

        // Стены (кубы с тегом Destructible)
        CreateWall(new Vector3(5, 0.5f, 0), new Vector3(2, 1, 1), "WallA");
        CreateWall(new Vector3(-5, 0.5f, 0), new Vector3(2, 1, 1), "WallB");
        CreateWall(new Vector3(0, 0.5f, 5), new Vector3(1, 1, 2), "WallC");
        CreateWall(new Vector3(0, 0.5f, -5), new Vector3(1, 1, 2), "WallD");

        // Менеджеры
        GameObject manager = new GameObject("Managers");
        manager.AddComponent<HouseDestructionManager>();
        manager.AddComponent<AudioManager>();
        manager.AddComponent<IntroController>();
    }

    private static void CreateWall(Vector3 pos, Vector3 size, string name)
    {
        GameObject wall = GameObject.CreatePrimitive(PrimitiveType.Cube);
        wall.name = name;
        wall.tag = "Destructible";
        wall.transform.position = pos;
        wall.transform.localScale = size;
        var rb = wall.GetComponent<Rigidbody>();
        if (rb == null) rb = wall.AddComponent<Rigidbody>();
        rb.isKinematic = true;
        // Слой можно назначить позже, если нужно
    }
}
