using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public static class VillaBuilder
{
    private const string ScenePath = "Assets/Scenes/Villa.unity";

    private static Material concrete;
    private static Material concreteDark;
    private static Material glass;
    private static Material glassDark;
    private static Material metal;
    private static Material floorWood;
    private static Material water;
    private static Material rock;
    private static Material grass;
    private static Material robotWhite;
    private static Material visorGlow;
    private static Material carBody;
    private static Material asphalt;

    [MenuItem("Tools/Вилла Оэннинга/Собрать сцену")]
    public static void BuildScene()
    {
        EnsureTag("Destructible");

        Directory.CreateDirectory("Assets/Scenes");

        Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        CreateMaterials();
        ConfigureEnvironment();
        CreateLighting();

        CollapseDirector director = CreateDirector();
        CreateGroundAndCliff();
        CreateVilla(director);
        CreateTerraceAndPool(director);
        CreateDriveway();

        GameObject car = CreateCar();
        CreateRobot();
        PlayerWalkController player = CreatePlayer(out Camera playerCamera);
        CreateHud(out Text progressLabel, out Text hintLabel);
        CreateIntroUi(out GameObject introPanel, out CanvasGroup introGroup, out Text lawsText);

        DestructionProgress progress = new GameObject("DestructionProgress").AddComponent<DestructionProgress>();
        progress.label = progressLabel;
        progress.totalParts = director.TotalParts();

        ArrivalSequence arrival = new GameObject("ArrivalSequence").AddComponent<ArrivalSequence>();
        arrival.car = car.transform;
        arrival.driveFrom = new Vector3(-46f, 0f, -26f);
        arrival.driveTo = new Vector3(-19f, 0f, -15f);
        arrival.duration = 7f;
        arrival.player = player;
        arrival.playerSpawn = GameObject.Find("PlayerSpawn").transform;

        IntroController intro = new GameObject("IntroController").AddComponent<IntroController>();
        intro.introPanel = introPanel;
        intro.introCanvasGroup = introGroup;
        intro.lawsText = lawsText;
        intro.gameplayHUD = progressLabel.transform.parent.gameObject;
        intro.arrival = arrival;
        intro.collapseDirector = director;

        AudioManager audio = new GameObject("AudioManager").AddComponent<AudioManager>();
        audio.wreckerSource = audio.gameObject.AddComponent<AudioSource>();
        audio.wreckerSource.playOnAwake = false;
        director.rumbleSource = audio.wreckerSource;

        RenderSettings.skybox = null;

        EditorSceneManager.SaveScene(scene, ScenePath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("Вилла Оэннинга: сцена собрана -> " + ScenePath);
    }

    private static void CreateMaterials()
    {
        concrete = Mat("Concrete", new Color(0.72f, 0.71f, 0.68f), 0.18f, 0f);
        concreteDark = Mat("ConcreteDark", new Color(0.42f, 0.41f, 0.39f), 0.22f, 0f);
        glass = TransparentMat("Glass", new Color(0.62f, 0.78f, 0.85f, 0.22f));
        glassDark = TransparentMat("GlassDark", new Color(0.18f, 0.24f, 0.28f, 0.55f));
        metal = Mat("Metal", new Color(0.33f, 0.34f, 0.36f), 0.75f, 0.9f);
        floorWood = Mat("FloorWood", new Color(0.55f, 0.45f, 0.34f), 0.35f, 0f);
        water = TransparentMat("Water", new Color(0.25f, 0.55f, 0.62f, 0.75f));
        rock = Mat("Rock", new Color(0.38f, 0.36f, 0.33f), 0.1f, 0f);
        grass = Mat("Grass", new Color(0.33f, 0.42f, 0.27f), 0.1f, 0f);
        robotWhite = Mat("RobotWhite", new Color(0.92f, 0.93f, 0.95f), 0.85f, 0.2f);
        visorGlow = EmissiveMat("VisorGlow", new Color(0.25f, 0.85f, 1f));
        carBody = Mat("CarBody", new Color(0.12f, 0.13f, 0.15f), 0.9f, 0.4f);
        asphalt = Mat("Asphalt", new Color(0.18f, 0.18f, 0.19f), 0.12f, 0f);
    }

    private static Material Mat(string name, Color color, float smoothness, float metallic)
    {
        Material m = new Material(Shader.Find("Standard"));
        m.name = name;
        m.color = color;
        m.SetFloat("_Glossiness", smoothness);
        m.SetFloat("_Metallic", metallic);
        return m;
    }

    private static Material TransparentMat(string name, Color color)
    {
        Material m = new Material(Shader.Find("Standard"));
        m.name = name;
        m.color = color;
        m.SetFloat("_Mode", 3f);
        m.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
        m.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
        m.SetInt("_ZWrite", 0);
        m.DisableKeyword("_ALPHATEST_ON");
        m.EnableKeyword("_ALPHABLEND_ON");
        m.DisableKeyword("_ALPHAPREMULTIPLY_ON");
        m.renderQueue = 3000;
        return m;
    }

    private static Material EmissiveMat(string name, Color color)
    {
        Material m = new Material(Shader.Find("Standard"));
        m.name = name;
        m.color = color;
        m.EnableKeyword("_EMISSION");
        m.SetColor("_EmissionColor", color * 2.2f);
        m.globalIlluminationFlags = MaterialGlobalIlluminationFlags.RealtimeEmissive;
        return m;
    }

    private static void ConfigureEnvironment()
    {
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        RenderSettings.ambientLight = new Color(0.58f, 0.62f, 0.68f);
        RenderSettings.fog = true;
        RenderSettings.fogColor = new Color(0.66f, 0.74f, 0.83f);
        RenderSettings.fogMode = FogMode.Linear;
        RenderSettings.fogStartDistance = 90f;
        RenderSettings.fogEndDistance = 320f;
    }

    private static void CreateLighting()
    {
        GameObject sun = new GameObject("Sun");
        Light light = sun.AddComponent<Light>();
        light.type = LightType.Directional;
        light.intensity = 1.15f;
        light.color = new Color(1f, 0.96f, 0.9f);
        sun.transform.rotation = Quaternion.Euler(48f, -34f, 0f);
    }

    private static CollapseDirector CreateDirector()
    {
        GameObject go = new GameObject("CollapseDirector");
        CollapseDirector director = go.AddComponent<CollapseDirector>();
        director.startDelay = 4f;
        director.waveStep = 0.28f;
        director.powerMultiplier = 1f;

        Transform[] origins = new Transform[3];
        string[] names = { "Epicenter_Roof", "Epicenter_West", "Epicenter_East" };
        Vector3[] positions = { new Vector3(0f, 7.5f, 0f), new Vector3(-11f, 2f, 0f), new Vector3(11f, 2f, 0f) };

        for (int i = 0; i < origins.Length; i++)
        {
            GameObject e = new GameObject(names[i]);
            e.transform.position = positions[i];
            origins[i] = e.transform;
        }

        director.shockOrigins = origins;
        return director;
    }

    private static void CreateGroundAndCliff()
    {
        GameObject ground = GameObject.CreatePrimitive(PrimitiveType.Cube);
        ground.name = "Plateau";
        ground.transform.position = new Vector3(0f, -0.6f, 4f);
        ground.transform.localScale = new Vector3(96f, 1.2f, 72f);
        ground.GetComponent<Renderer>().sharedMaterial = grass;

        GameObject cliff = new GameObject("Cliff");
        for (int i = 0; i < 14; i++)
        {
            GameObject block = GameObject.CreatePrimitive(PrimitiveType.Cube);
            block.name = "CliffBlock_" + i;
            block.transform.SetParent(cliff.transform);
            float sx = Random.Range(7f, 15f);
            float sy = Random.Range(8f, 18f);
            float sz = Random.Range(7f, 15f);
            block.transform.localScale = new Vector3(sx, sy, sz);
            block.transform.position = new Vector3(
                Random.Range(-40f, 40f),
                -sy * 0.5f - Random.Range(2f, 22f),
                Random.Range(30f, 52f));
            block.transform.rotation = Quaternion.Euler(0f, Random.Range(0f, 360f), Random.Range(-6f, 6f));
            block.GetComponent<Renderer>().sharedMaterial = rock;
        }

        GameObject sea = GameObject.CreatePrimitive(PrimitiveType.Cube);
        sea.name = "Sea";
        sea.transform.position = new Vector3(0f, -34f, 120f);
        sea.transform.localScale = new Vector3(600f, 1f, 300f);
        sea.GetComponent<Renderer>().sharedMaterial = water;
        DestroyCollider(sea);
    }

    private static void CreateVilla(CollapseDirector director)
    {
        GameObject villa = new GameObject("Villa_Oenninger");
        Transform root = villa.transform;

        Color floorTint = new Color(0.86f, 0.85f, 0.82f);

        Solid("Slab_Ground", root, new Vector3(0f, -0.13f, 0f), new Vector3(26f, 0.26f, 18f), concrete, false, director);
        Solid("Slab_Level1", root, new Vector3(0f, 4.2f, 0f), new Vector3(26f, 0.3f, 18f), concrete, true, director, 0.05f);
        Solid("Slab_Roof", root, new Vector3(0f, 8.45f, 0f), new Vector3(27f, 0.35f, 19f), concreteDark, true, director, 0.1f);

        float[] xs = { -12f, -4f, 4f, 12f };
        float[] zs = { -8f, 0f, 8f };
        foreach (float x in xs)
        {
            foreach (float z in zs)
                Solid("Column", root, new Vector3(x, 2.1f, z), new Vector3(0.4f, 4.2f, 0.4f), concrete, false, director);
        }

        for (int i = 0; i < 9; i++)
        {
            float x = -11.2f + i * 2.8f;
            AddGlassPanel(root, "Glass_S_G_0_" + i, new Vector3(x, 2.1f, -9f), new Vector3(2.6f, 4f, 0.09f), director, 0.0f);
            AddGlassPanel(root, "Glass_S_G_1_" + i, new Vector3(x, 6.3f, -9f), new Vector3(2.6f, 4f, 0.09f), director, 0.35f);
        }

        for (int i = 0; i < 4; i++)
        {
            float z = -6f + i * 4.2f;
            AddGlassPanel(root, "Glass_E_G_0_" + i, new Vector3(13f, 2.1f, z), new Vector3(0.09f, 4f, 3.9f), director, 0.15f);
            AddGlassPanel(root, "Glass_E_G_1_" + i, new Vector3(13f, 6.3f, z), new Vector3(0.09f, 4f, 3.9f), director, 0.45f);
        }

        for (int i = 0; i < 6; i++)
        {
            float x = -11f + i * 4.4f;
            Solid("Wall_N_0_" + i, root, new Vector3(x, 2.1f, 9f), new Vector3(4.2f, 4.2f, 0.35f), concrete, true, director, 0.2f);
            Solid("Wall_N_1_" + i, root, new Vector3(x, 6.3f, 9f), new Vector3(4.2f, 4.2f, 0.35f), concrete, true, director, 0.5f);
        }

        Solid("Wall_W_0", root, new Vector3(-13f, 2.1f, -5f), new Vector3(0.35f, 4.2f, 8f), concrete, true, director, 0.25f);
        Solid("Wall_W_1", root, new Vector3(-13f, 2.1f, 5f), new Vector3(0.35f, 4.2f, 8f), concrete, true, director, 0.25f);
        Solid("Wall_W_F1", root, new Vector3(-13f, 6.3f, 0f), new Vector3(0.35f, 4.2f, 18f), concrete, true, director, 0.55f);

        Solid("Partition_1", root, new Vector3(-6f, 2.1f, 2f), new Vector3(0.25f, 4.2f, 9f), concreteDark, true, director, 0.3f);
        Solid("Partition_2", root, new Vector3(-1f, 2.1f, -3f), new Vector3(8f, 4.2f, 0.25f), concreteDark, true, director, 0.4f);
        Solid("Partition_3", root, new Vector3(4f, 6.3f, 3f), new Vector3(0.25f, 4.2f, 7f), concreteDark, true, director, 0.6f);

        Solid("Floor_Interior", root, new Vector3(0f, 0.03f, 0f), new Vector3(25f, 0.06f, 17f), floorWood, false, director);

        for (int i = 0; i < 15; i++)
        {
            float y = 0.15f + i * 0.29f;
            float z = -1.5f + i * 0.33f;
            Solid("Stair_" + i, root, new Vector3(8.4f, y, z), new Vector3(3.4f, 0.16f, 0.33f), floorWood, false, director);
        }
        Solid("Stair_Rail", root, new Vector3(10.1f, 2.2f, 1.0f), new Vector3(0.08f, 4.4f, 0.08f), metal, false, director);

        for (int i = 0; i < 6; i++)
        {
            Solid("Column_Glass_" + i, root, new Vector3(-8f + i * 3.2f, 4.5f, -9.05f), new Vector3(0.25f, 4.2f, 0.25f), metal, false, director);
        }
    }

    private static void CreateTerraceAndPool(CollapseDirector director)
    {
        GameObject terrace = new GameObject("Terrace");
        Transform root = terrace.transform;

        Solid("Terrace_Slab", root, new Vector3(0f, -0.16f, 14f), new Vector3(30f, 0.32f, 10f), concrete, true, director, 0.7f, false);
        Solid("Terrace_Deck", root, new Vector3(0f, 0.01f, 14f), new Vector3(29.6f, 0.04f, 9.6f), floorWood, false, director);

        Solid("Pool_Water", root, new Vector3(-7f, 0.06f, 14f), new Vector3(7f, 0.1f, 7.4f), water, false, director);
        Solid("Pool_Rim_N", root, new Vector3(-7f, 0.06f, 10.1f), new Vector3(7.4f, 0.12f, 0.4f), concreteDark, false, director);
        Solid("Pool_Rim_S", root, new Vector3(-7f, 0.06f, 17.9f), new Vector3(7.4f, 0.12f, 0.4f), concreteDark, false, director);

        for (int i = 0; i < 9; i++)
        {
            float x = -12f + i * 3f;
            AddGlassPanel(root, "Railing_S_" + i, new Vector3(x, 0.7f, 18.9f), new Vector3(2.9f, 1.1f, 0.05f), director, 0.8f);
        }
        for (int i = 0; i < 3; i++)
        {
            float z = 10.5f + i * 3f;
            AddGlassPanel(root, "Railing_E_" + i, new Vector3(14.9f, 0.7f, z), new Vector3(0.05f, 1.1f, 2.9f), director, 0.85f);
            AddGlassPanel(root, "Railing_W_" + i, new Vector3(-14.9f, 0.7f, z), new Vector3(0.05f, 1.1f, 2.9f), director, 0.85f);
        }
    }

    private static void CreateDriveway()
    {
        GameObject road = GameObject.CreatePrimitive(PrimitiveType.Cube);
        road.name = "Driveway";
        road.transform.position = new Vector3(-30f, 0.02f, -20f);
        road.transform.localScale = new Vector3(40f, 0.08f, 7f);
        road.transform.rotation = Quaternion.Euler(0f, -22f, 0f);
        road.GetComponent<Renderer>().sharedMaterial = asphalt;

        Solid("Entrance_Plaza", null, new Vector3(-17f, -0.05f, -14f), new Vector3(14f, 0.1f, 10f), concreteDark, false, null);
    }

    private static GameObject CreateCar()
    {
        GameObject car = new GameObject("Spooner_Car");
        car.transform.position = new Vector3(-46f, 0.05f, -26f);
        car.transform.rotation = Quaternion.Euler(0f, 60f, 0f);

        Solid("Car_Body", car.transform, new Vector3(0f, 0.65f, 0f), new Vector3(4.6f, 0.75f, 1.95f), carBody, false, null);
        Solid("Car_Cabin", car.transform, new Vector3(-0.15f, 1.2f, 0f), new Vector3(2.4f, 0.55f, 1.8f), carBody, false, null);
        Solid("Car_Windshield", car.transform, new Vector3(0.95f, 1.2f, 0f), new Vector3(0.08f, 0.5f, 1.75f), glassDark, false, null);
        Solid("Car_RearGlass", car.transform, new Vector3(-1.3f, 1.2f, 0f), new Vector3(0.08f, 0.5f, 1.75f), glassDark, false, null);

        Vector3[] wheels =
        {
            new Vector3(1.5f, 0.38f, 0.95f), new Vector3(1.5f, 0.38f, -0.95f),
            new Vector3(-1.5f, 0.38f, 0.95f), new Vector3(-1.5f, 0.38f, -0.95f)
        };

        foreach (Vector3 w in wheels)
        {
            GameObject wheel = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            wheel.name = "Wheel";
            wheel.transform.SetParent(car.transform);
            wheel.transform.localPosition = w;
            wheel.transform.localRotation = Quaternion.Euler(90f, 0f, 0f);
            wheel.transform.localScale = new Vector3(0.72f, 0.16f, 0.72f);
            wheel.GetComponent<Renderer>().sharedMaterial = Mat("Rubber", new Color(0.08f, 0.08f, 0.08f), 0.2f, 0f);
        }

        return car;
    }

    private static void CreateRobot()
    {
        GameObject robot = new GameObject("NS5_Robot");
        robot.transform.position = new Vector3(11.5f, 0f, 15.5f);
        robot.transform.rotation = Quaternion.Euler(0f, 215f, 0f);

        Transform t = robot.transform;
        Solid("Pelvis", t, new Vector3(0f, 0.95f, 0f), new Vector3(0.62f, 0.4f, 0.42f), robotWhite, false, null);
        Solid("Torso", t, new Vector3(0f, 1.55f, 0f), new Vector3(0.8f, 0.95f, 0.5f), robotWhite, false, null);
        Solid("ShoulderL", t, new Vector3(-0.52f, 1.9f, 0f), new Vector3(0.28f, 0.28f, 0.28f), metal, false, null);
        Solid("ShoulderR", t, new Vector3(0.52f, 1.9f, 0f), new Vector3(0.28f, 0.28f, 0.28f), metal, false, null);

        GameObject head = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        head.name = "Head";
        head.transform.SetParent(t);
        head.transform.localPosition = new Vector3(0f, 2.22f, 0f);
        head.transform.localScale = new Vector3(0.42f, 0.48f, 0.42f);
        head.GetComponent<Renderer>().sharedMaterial = robotWhite;

        Solid("Visor", t, new Vector3(0f, 2.24f, 0.17f), new Vector3(0.3f, 0.12f, 0.08f), visorGlow, false, null);

        Solid("ArmL", t, new Vector3(-0.56f, 1.45f, 0f), new Vector3(0.2f, 0.9f, 0.2f), robotWhite, false, null);
        Solid("ArmR", t, new Vector3(0.56f, 1.45f, 0f), new Vector3(0.2f, 0.9f, 0.2f), robotWhite, false, null);
        Solid("LegL", t, new Vector3(-0.2f, 0.45f, 0f), new Vector3(0.24f, 0.9f, 0.24f), robotWhite, false, null);
        Solid("LegR", t, new Vector3(0.2f, 0.45f, 0f), new Vector3(0.24f, 0.9f, 0.24f), robotWhite, false, null);

        Rigidbody rb = robot.AddComponent<Rigidbody>();
        rb.isKinematic = true;
        rb.useGravity = false;
        robot.AddComponent<AdvancedRobotWrecker>();
    }

    private static PlayerWalkController CreatePlayer(out Camera playerCamera)
    {
        GameObject spawn = new GameObject("PlayerSpawn");
        spawn.transform.position = new Vector3(-17f, 0.2f, -14f);

        GameObject player = new GameObject("Player");
        player.transform.position = spawn.transform.position;
        player.transform.rotation = Quaternion.Euler(0f, 180f, 0f);

        CharacterController cc = player.AddComponent<CharacterController>();
        cc.height = 1.8f;
        cc.radius = 0.35f;
        cc.center = new Vector3(0f, 0.9f, 0f);

        GameObject camGo = new GameObject("PlayerCamera");
        camGo.transform.SetParent(player.transform);
        camGo.transform.localPosition = new Vector3(0f, 1.65f, 0f);
        camGo.transform.localRotation = Quaternion.identity;
        camGo.tag = "MainCamera";

        playerCamera = camGo.AddComponent<Camera>();
        playerCamera.fieldOfView = 68f;
        playerCamera.nearClipPlane = 0.05f;
        playerCamera.farClipPlane = 600f;
        playerCamera.clearFlags = CameraClearFlags.SolidColor;
        playerCamera.backgroundColor = new Color(0.66f, 0.74f, 0.83f);
        camGo.AddComponent<AudioListener>();

        PlayerWalkController walk = player.AddComponent<PlayerWalkController>();
        walk.cameraPivot = camGo.transform;
        walk.controlEnabled = false;

        return walk;
    }

    private static void CreateHud(out Text progressLabel, out Text hintLabel)
    {
        GameObject canvasGo = new GameObject("HUD");
        Canvas canvas = canvasGo.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        CanvasScaler scaler = canvasGo.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920f, 1080f);

        Font font = LoadFont();

        GameObject progressGo = new GameObject("ProgressLabel");
        progressGo.transform.SetParent(canvasGo.transform, false);
        progressLabel = progressGo.AddComponent<Text>();
        progressLabel.font = font;
        progressLabel.fontSize = 30;
        progressLabel.color = new Color(1f, 0.92f, 0.86f);
        progressLabel.alignment = TextAnchor.UpperLeft;
        progressLabel.text = "Вилла Оэннинга разрушена: 0%";
        RectTransform pr = progressGo.GetComponent<RectTransform>();
        pr.anchorMin = new Vector2(0f, 1f);
        pr.anchorMax = new Vector2(0f, 1f);
        pr.pivot = new Vector2(0f, 1f);
        pr.anchoredPosition = new Vector2(40f, -36f);
        pr.sizeDelta = new Vector2(900f, 60f);

        GameObject hintGo = new GameObject("HintLabel");
        hintGo.transform.SetParent(canvasGo.transform, false);
        hintLabel = hintGo.AddComponent<Text>();
        hintLabel.font = font;
        hintLabel.fontSize = 20;
        hintLabel.color = new Color(0.9f, 0.9f, 0.92f, 0.75f);
        hintLabel.alignment = TextAnchor.LowerCenter;
        hintLabel.text = "WASD — идти, мышь — осмотреться, Shift — бежать, Space — прыжок, E — начать демонтаж";
        RectTransform hr = hintGo.GetComponent<RectTransform>();
        hr.anchorMin = new Vector2(0.5f, 0f);
        hr.anchorMax = new Vector2(0.5f, 0f);
        hr.pivot = new Vector2(0.5f, 0f);
        hr.anchoredPosition = new Vector2(0f, 28f);
        hr.sizeDelta = new Vector2(1400f, 40f);
    }

    private static void CreateIntroUi(out GameObject introPanel, out CanvasGroup introGroup, out Text lawsText)
    {
        GameObject canvasGo = new GameObject("IntroCanvas");
        Canvas canvas = canvasGo.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.sortingOrder = 10;
        CanvasScaler scaler = canvasGo.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920f, 1080f);
        introGroup = canvasGo.AddComponent<CanvasGroup>();

        introPanel = new GameObject("IntroPanel");
        introPanel.transform.SetParent(canvasGo.transform, false);
        Image bg = introPanel.AddComponent<Image>();
        bg.color = new Color(0.04f, 0.05f, 0.07f, 0.97f);
        RectTransform br = introPanel.GetComponent<RectTransform>();
        br.anchorMin = Vector2.zero;
        br.anchorMax = Vector2.one;
        br.offsetMin = Vector2.zero;
        br.offsetMax = Vector2.zero;

        Font font = LoadFont();

        GameObject lawsGo = new GameObject("LawsText");
        lawsGo.transform.SetParent(introPanel.transform, false);
        lawsText = lawsGo.AddComponent<Text>();
        lawsText.font = font;
        lawsText.fontSize = 34;
        lawsText.color = new Color(0.94f, 0.94f, 0.96f);
        lawsText.alignment = TextAnchor.MiddleCenter;
        lawsText.horizontalOverflow = HorizontalWrapMode.Wrap;
        lawsText.verticalOverflow = VerticalWrapMode.Overflow;
        RectTransform lr = lawsGo.GetComponent<RectTransform>();
        lr.anchorMin = new Vector2(0.15f, 0.2f);
        lr.anchorMax = new Vector2(0.85f, 0.8f);
        lr.offsetMin = Vector2.zero;
        lr.offsetMax = Vector2.zero;
    }

    private static Font LoadFont()
    {
        Font font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        if (font == null)
            font = Resources.GetBuiltinResource<Font>("Arial.ttf");
        return font;
    }

    private static void AddGlassPanel(Transform parent, string name, Vector3 pos, Vector3 size, CollapseDirector director, float delay)
    {
        Solid(name, parent, pos, size, glass, true, director, delay);
    }

    private static GameObject Solid(string name, Transform parent, Vector3 position, Vector3 scale, Material material, bool destructible, CollapseDirector director, float delay = 0f, bool register = true)
    {
        GameObject go = GameObject.CreatePrimitive(PrimitiveType.Cube);
        go.name = name;
        go.transform.SetParent(parent, true);
        go.transform.position = position;
        go.transform.localScale = scale;
        go.GetComponent<Renderer>().sharedMaterial = material;

        if (destructible)
        {
            go.tag = "Destructible";
            Rigidbody rb = go.AddComponent<Rigidbody>();
            rb.isKinematic = true;
            rb.useGravity = false;

            CollapsePart part = go.AddComponent<CollapsePart>();
            part.delay = delay;
            if (director != null && register)
                director.Register(part);
        }

        return go;
    }

    private static void DestroyCollider(GameObject go)
    {
        Collider c = go.GetComponent<Collider>();
        if (c != null) Object.DestroyImmediate(c);
    }

    public static void EnsureTag(string tag)
    {
        Object[] assets = AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset");
        if (assets == null || assets.Length == 0) return;

        SerializedObject so = new SerializedObject(assets[0]);
        SerializedProperty tags = so.FindProperty("tags");
        for (int i = 0; i < tags.arraySize; i++)
            if (tags.GetArrayElementAtIndex(i).stringValue == tag) return;

        tags.InsertArrayElementAtIndex(tags.arraySize);
        tags.GetArrayElementAtIndex(tags.arraySize - 1).stringValue = tag;
        so.ApplyModifiedProperties();
    }
}
