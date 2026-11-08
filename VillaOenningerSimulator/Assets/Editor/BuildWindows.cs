using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

public static class VillaBuildWindows
{
    private const string ScenePath = "Assets/Scenes/Villa.unity";
    private const string OutputDir = "Builds/Windows";
    private const string OutputExe = "Builds/Windows/VillaOenninger.exe";

    [MenuItem("Tools/Вилла Оэннинга/Собрать Windows exe")]
    public static void BuildFromMenu()
    {
        Build(BuildOptions.None);
    }

    public static void BuildBatch()
    {
        Build(BuildOptions.None);
    }

    private static void Build(BuildOptions options)
    {
        VillaBuilder.EnsureTag("Destructible");
        VillaBuilder.BuildScene();

        EditorBuildSettings.scenes = new[]
        {
            new EditorBuildSettingsScene(ScenePath, true)
        };

        Directory.CreateDirectory(OutputDir);

        BuildPlayerOptions playerOptions = new BuildPlayerOptions
        {
            scenes = new[] { ScenePath },
            locationPathName = OutputExe,
            target = BuildTarget.StandaloneWindows64,
            options = options
        };

        BuildReport report = BuildPipeline.BuildPlayer(playerOptions);

        if (report.summary.result == BuildResult.Succeeded)
            Debug.Log("Сборка успешна: " + OutputExe + " (" + report.summary.totalSize + " байт)");
        else
            throw new BuildFailedException("Сборка не удалась: " + report.summary.result);
    }
}
