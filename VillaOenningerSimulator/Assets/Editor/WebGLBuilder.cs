using UnityEditor;
using UnityEngine;
using System.IO;

public static class WebGLBuilder
{
    public static void Build()
    {
        // Сначала создаём сцену, если её нет
        SceneBuilder.BuildScene();

        string[] scenes = { "Assets/Scenes/SampleScene.unity" };
        string buildPath = "Builds/WebGL";

        if (!Directory.Exists(buildPath))
            Directory.CreateDirectory(buildPath);

        BuildPipeline.BuildPlayer(scenes, buildPath, BuildTarget.WebGL, BuildOptions.None);
        Debug.Log("✅ WebGL build finished successfully.");
    }
}
