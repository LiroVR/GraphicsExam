# Final Exam

## Implemented Effects
### Colour Correction
Uses a LUT (Lookup Texture) to do colour grading in the scene

This was done to help capture the "retro" feel of the game, as older games had very vibrant colours

This was done by taking a screenshot of the game, placing a neutral LUT in the corner, adjusting the values, then exporting the LUT with the changes:

![LUTExample](https://github.com/user-attachments/assets/4909053b-6297-480d-9b49-b56f66011b4d)

This LUT was then placed into Unity's Post Processing layer to add the colour correction to the camera:

![image](https://github.com/user-attachments/assets/145f58e1-db6a-49f2-8bd8-0f97197d0a59)

### Texture Scrolling
This offsets the UVs, and therefore textures, to give a desired effect

This was used for the power meter in the upper corner. As the payer shoots, and uses power, the UV is scrolled, moving the yellow away, which lowers the power bar

![PowerMeter](https://github.com/user-attachments/assets/a80ad12a-e8d3-40cd-ac07-93bfb938cd54)
```hlsl
float _ScrollY;
float _ScrollX;

struct Input
{
    float2 uv_MainTex;
};

void surf (Input IN, inout SurfaceOutput o)
{
    float2 scrollUV = IN.uv_MainTex + float2(_ScrollX, _ScrollY); //Adds the scrolling offsets to the UV
    fixed4 c = tex2D(_MainTex, scrollUV) * _Color; //Uses the new UV to map the texture with the offsets
    o.Albedo = c.rgb;
}
```

### Outlines
Adds a black outline to each mesh, highlighting the edges

This was done, as "Yoshi's Safari" has outlines in the game, so it only felt right to add them back in

Works by extruding a duplicate mesh along the normals of the original, but has culling set to "front" so that it only appears behind the original, giving the illusion of an outline

![image](https://github.com/user-attachments/assets/8ebfb0ad-8a60-4c4d-8db1-f9db4bfb15ca)

```hlsl
Pass
{
    Name "Outline"
    Tags { "LightMode" = "Always" }
    Cull Front
    ZWrite On
    ZTest LEqual
    Blend SrcAlpha OneMinusSrcAlpha

    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #include "UnityCG.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
    };

    struct v2f
    {
        float4 pos : POSITION;
        float4 color : COLOR;
    };

    uniform float _OutlineThickness;
    uniform float4 _OutlineColor;

    v2f vert (appdata v)
    {
        v2f o;
        float3 norm = normalize(v.normal);
        o.pos = UnityObjectToClipPos(v.vertex + norm * _OutlineThickness/10);
        o.color = _OutlineColor;
        return o;
    }

    half4 frag (v2f i) : SV_Target
    {
        return i.color;
    }
    ENDCG
}
```

### Toon Shading

Added toon shading, which uses a ramp texture to control the lightness of the albedo, giving a toon shadow appearance

Was added to try and keep the retro feel, while still highlighting the fact that the game is 3D, so it needs some form of shadows

![image](https://github.com/user-attachments/assets/e3f63f96-8305-46bf-9e04-bc2638807ec8)

![LightingDiagrams](https://github.com/user-attachments/assets/13d6dfdb-97be-4271-a615-e220aa5f0527)

```hlsl
half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, half atten)
{
    half3 normal = normalize(s.Normal);
    half NdotL = dot(normal, lightDir);
    float h = NdotL * 0.5 + 0.5;
    float2 rh = h;
    half ramp = tex2D(_RampTex, rh).rgb;
    half3 color = s.Albedo * ramp;
    return half4(color, s.Alpha);
}
```
