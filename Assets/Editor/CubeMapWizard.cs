using UnityEngine;
using UnityEditor;

public class CubeMapWizard: ScriptableWizard {
    public Transform renderPosition;
    public Cubemap cubemap;

    [MenuItem("ShaderLab/CubeMap")]
    private static void MenuEntryCall() {
        DisplayWizard<CubeMapWizard>("渲染立方体贴图", "渲染贴图");
    }

    private void OnWizardCreate() {
        GameObject go = new GameObject("CubeCamera");
        go.AddComponent<Camera>();
        go.transform.position = renderPosition.position;
        go.GetComponent<Camera>().RenderToCubemap(cubemap);

        DestroyImmediate(go);
    }

    private void OnWizardUpdate() {
        helpString = "在指定位置渲染贴图";
        isValid = renderPosition && cubemap;
    }
}