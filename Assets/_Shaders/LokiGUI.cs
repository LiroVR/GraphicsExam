using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

#if UNITY_EDITOR
public class LokiGUI : ShaderGUI
{
    private bool showTextureOptions = false;
    private string[] options = new string[] { "Realistic", "Cel Shading" };
    private int selectedOption = 0, transparencyOption = 0;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //Finds all the properties in the shader
        MaterialProperty rampTexture = FindProperty("_rampTexture", properties);
        MaterialProperty rimColour = FindProperty("_rimColour", properties);
        MaterialProperty rimPower = FindProperty("_rimPower", properties);
        MaterialProperty rimEmission = FindProperty("_rimEmission", properties);
        MaterialProperty mainColor = FindProperty("_mainColor", properties);
        MaterialProperty mainTexture = FindProperty("_mainTexture", properties);
        MaterialProperty mainEmission = FindProperty("_mainEmission", properties);
        MaterialProperty normalMap = FindProperty("_mainNormal", properties);
        MaterialProperty emissionMap = FindProperty("_emissionMap", properties);
        MaterialProperty metallicMap = FindProperty("_metallicMap", properties);
        MaterialProperty smoothnessMap = FindProperty("_smoothnessMap", properties);
        MaterialProperty emissionStrength = FindProperty("_emissionStrength", properties);
        MaterialProperty metallic = FindProperty("_metallic", properties);
        MaterialProperty smoothness = FindProperty("_smoothness", properties);
        MaterialProperty invertSmoothness = FindProperty("_InvertSmoothness", properties);
        MaterialProperty shadingMode = FindProperty("_ShadingMode", properties);
        MaterialProperty outlineThickness = FindProperty("_outlineThickness", properties);
        MaterialProperty outlineColour = FindProperty("_outlineColour", properties);
        MaterialProperty blurStrength = FindProperty("_blurStrength", properties);
        MaterialProperty blurSpeed = FindProperty("_blurSpeed", properties);
        MaterialProperty distortionStrength = FindProperty("_distortionStrength", properties);
        MaterialProperty distortionSpeed = FindProperty("_distortionSpeed", properties);
        MaterialProperty _textureToggle = FindProperty("_textureToggle", properties);


        selectedOption = EditorGUILayout.Popup("Lighting Mode", selectedOption, options); //Can switch between realistic and Cel Shading (again, not fully functional)

        //Applies the selected lighting mode, by enabling the keyword in the shader
        foreach (Material material in materialEditor.targets)
        {
            if (selectedOption == 1)
            {
                material.EnableKeyword("CEL_SHADING");
                material.SetFloat("_ShadingMode", 1);
                materialEditor.ShaderProperty(rampTexture, rampTexture.displayName);
            }
            else
            {
                material.DisableKeyword("CEL_SHADING");
                material.SetFloat("_ShadingMode", 0);
            }
        }

        //Displays the properties in the desired order
        EditorGUILayout.BeginHorizontal(); //Puts everything between the "begin" and "end" in a horizontal line, keeping it clean
        materialEditor.ColorProperty(mainColor, "Main Color");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        GUILayout.ExpandWidth(false); //Used in an attempt to keep the texture property right beside the dropdown menu, but not fully working
        showTextureOptions = EditorGUILayout.Foldout(showTextureOptions, "");
        materialEditor.TexturePropertySingleLine(new GUIContent("Main Texture"), mainTexture);
        EditorGUILayout.EndHorizontal();
        if (showTextureOptions) //Dropdown menu for texture options
        {
            // Display texture tiling and offset options
            materialEditor.TextureScaleOffsetProperty(mainTexture);

            // Add fields for texture panning
            MaterialProperty scrollSpeed = FindProperty("_scrollSpeed", properties);
            materialEditor.VectorProperty(scrollSpeed, "Scroll Speed");
        }
        materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map"), normalMap);
        EditorGUILayout.BeginHorizontal();
        materialEditor.ColorProperty(mainEmission, "Main Emission");
        EditorGUILayout.EndHorizontal();
        materialEditor.TexturePropertySingleLine(new GUIContent("Emission Map"), emissionMap);
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(emissionStrength, "Emission Strength");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.ColorProperty(outlineColour, "Outline Color");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(outlineThickness, "Outline Thickness");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.ColorProperty(rimColour, "Rim Colour");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(rimPower, "Rim Power");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(rimEmission, "Rim Emission");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(blurStrength, "Blur Strength");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(blurSpeed, "Blur Speed");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(distortionStrength, "Distortion Strength");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(distortionSpeed, "Distortion Speed");
        EditorGUILayout.EndHorizontal();
        materialEditor.TexturePropertySingleLine(new GUIContent("Metallic Map"), metallicMap);
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(metallic, "Metallic");
        EditorGUILayout.EndHorizontal();
        materialEditor.TexturePropertySingleLine(new GUIContent("Smoothness Map"), smoothnessMap);
        EditorGUILayout.BeginHorizontal();
        materialEditor.RangeProperty(smoothness, "Smoothness");
        EditorGUILayout.EndHorizontal();
        bool invert = EditorGUILayout.Toggle("Invert Smoothness", invertSmoothness.floatValue == 1);
        bool texToggle = EditorGUILayout.Toggle("Texture Toggle", _textureToggle.floatValue == 1);


        if (EditorGUI.EndChangeCheck())
        {
            invertSmoothness.floatValue = invert ? 1 : 0; //Controls the invert smoothness checkbox
            _textureToggle.floatValue = texToggle ? 1 : 0; //Controls the texture toggle checkbox
        }
        EditorGUI.BeginChangeCheck();
    }

    
}
#endif