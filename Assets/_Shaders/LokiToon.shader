Shader "Loki/Loki Toon" {
    Properties {
        // All the properties. The order seems random, but that's just because their order is controlled by the LokiGUI script
        _rampTexture ("Ramp Texture", 2D) = "white" {}
        _outlineThickness ("Outline Thickness", Range (0.0, 10.0)) = 0.0
        _rimColour("Rim Colour", Color) = (1,1,1,1)
        _rimPower("Rim Power", Range(0, 8)) = 3
        _rimEmission("Rim Emission", Range(0, 10)) = 0
        _lightingMode ("Lighting Mode", Float) = 0
        _mainColor("Main Color", Color) = (1,1,1,1)
        _outlineColour ("Outline Colour", Color) = (0,0,0,1)
        _mainEmission("Main Emission", Color) = (1,1,1,1)
        _emissionStrength("Emission Strength", Range(0, 10)) = 0
        _metallic("Metallic Strength", Range(0, 1)) = 0
        _scrollSpeed ("Scroll Speed", Vector) = (0.0, 0.0, 0, 0)
        _smoothness("Smoothness", Range(0, 1)) = 0.5
        _blurStrength("Blur Strength", Range(0, 0.1)) = 0.0
        _blurSpeed("Blur Speed", Range(0, 10)) = 0.0
        _distortionStrength("Distortion Strength", Range(0, 10)) = 0.0
        _distortionSpeed("Distortion Speed", Range(0, 10)) = 0.0
        [HideInInspector] _InvertSmoothness("Invert Smoothness", Float) = 0.0
        [HideInInspector] _textureToggle("Texture Toggle", Float) = 1.0
        _mainTexture("Main Texture", 2D) = "white"
        _emissionMap("Emission Map", 2D) = "black"
        _mainNormal("Normal Map", 2D) = "bump"
        _metallicMap("Metallic Map", 2D) = "black"
        _smoothnessMap("Smoothness Map", 2D) = "white"
        _ShadingMode ("Shading Mode", Float) = 0 //0 for realistic, 1 for toon (doesn't fully work right now)
    }
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        // Dedicated Outline Pass
        Pass {
            Name "Outline"
            Tags { "LightMode" = "Always" } // Makes it so that the outline is not affected by light, as that would look...weird
            Cull Front // Set to front, as outlines need to only render the inside, or else the mesh will become just a solid color of the outline
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
            };
            uniform float _outlineThickness; // Only need thickness and colour for the outline
            uniform float4 _outlineColour;
            v2f vert (appdata v) {
                // Extrudes the outline along the normals
                v2f o;
                float3 norm = mul((float3x3)unity_ObjectToWorld, v.normal); // Gets the normals to extrude from (this line was given by ChatGPT, as I didn't know how to get the normals)
                o.pos = UnityObjectToClipPos(v.vertex + norm * (_outlineThickness/10000)); // Divided by 10000, as the outlines were waaaay too thick otherwise
                o.color = _outlineColour;
                return o;
            }
            half4 frag (v2f i) : SV_Target {
                return i.color; // The final output for the pass
            }
            ENDCG
        }

        // Dedicated Shadow Pass. Without this, the shader has no shadows
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On // Enables writing to the depth buffer, which is very much needed
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata 
            {
                float4 vertex : POSITION;
            };
            struct v2f 
            {
                float4 pos : SV_POSITION;
            };
            v2f vert (appdata v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            half4 frag(v2f i) : SV_Target 
            {
                return 0; // Doesn't need to return anything, as it's just for shadows, not colour
            }
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            sampler2D _mainTexture;
            float _distortionStrength;
            float _distortionSpeed;
            float _textureToggle;

            float noise(float2 pos) 
            {
                return frac(sin(dot(pos, float2(12.9898, 78.233))) * 43758.5453); //Values from here: https://www.reddit.com/r/GraphicsProgramming/comments/3kp644/this_generates_pseudorandom_numbers_fractsindota/
            }

            v2f vert(appdata v) 
            {
                v2f o;
                if (_distortionStrength < 0.01) // If the distortion strength is less than 0.01, which is basically nothing, it will not distort the mesh at all, saving performance
                {
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                }
                else 
                {
                    float noiseValue = noise(v.vertex.xy * _distortionSpeed + _Time.y); //Generate a random number using the noise function
                    float3 distortion = v.normal * noiseValue * _distortionStrength * 0.0001; //Gets the distortion offset for the vertex
                    v.vertex.xyz += distortion; //Applies the distortion to the vertex
                    o.pos = UnityObjectToClipPos(v.vertex); //Sets the position of the vertex
                    o.uv = v.uv; //Sets the UV of the vertex
                }
                return o;
            }

            half4 frag(v2f i) : SV_Target 
            {
                if (_distortionStrength > 0) //If the distortion strength is greater than 0, it will return the texture, otherwise it will discard the pixel
                {
                    if (_textureToggle > 0.5)
                        return tex2D(_mainTexture, i.uv);
                    else
                        return 1;
                }
                else
                {
                    discard; //Discards the pixel if the effect is disabled, preventing Z-fighting
                    return 0;
                }
            }
            
            ENDCG
        }
        // Main Pass
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma multi_compile _ CEL_SHADING
        struct Input {
            float2 uv_mainTexture;
            float3 viewDir;
        };
        sampler2D _mainTexture;
        sampler2D _emissionMap;
        sampler2D _mainNormal;
        sampler2D _metallicMap;
        sampler2D _smoothnessMap;
        sampler2D _rampTexture;
        float _metallic;
        float _smoothness;
        float _InvertSmoothness;
        fixed4 _mainColor;
        fixed4 _mainEmission;
        float _emissionStrength;
        float4 _scrollSpeed;
        float4 _rimColour;
        float _rimPower;
        float _rimEmission;
        float _blurStrength;
        float _ShadingMode;
        float _blurSpeed;
        float _textureToggle;
        
        float noise(float2 pos) 
        {
            return frac(sin(dot(_Time.xy + pos, float2(12.9898, 78.233))) * 43758.5453); //Values from here: https://www.reddit.com/r/GraphicsProgramming/comments/3kp644/this_generates_pseudorandom_numbers_fractsindota/
        }

        void surf(Input IN, inout SurfaceOutputStandard o) {
            //Blur effect changes the UVs of the model, causing textures to be blurred. Rotation is handled by using sin and cos functions with time
            float3 distortedPos = float3((IN.uv_mainTexture.x + noise(IN.uv_mainTexture) * _blurStrength * cos(_Time.y * _blurSpeed)), (IN.uv_mainTexture.y + noise(IN.uv_mainTexture) * _blurStrength * sin(_Time.y * _blurSpeed)), 0.0);
            fixed4 c = (0,0,0,0);
            if(_textureToggle > 0.5)
            {
                c = tex2D(_mainTexture, distortedPos.xy) * _mainColor; // Tints the texture with the main colour
                o.Normal = UnpackNormal(tex2D(_mainNormal, distortedPos.xy)); // Sets the normal map
                o.Emission = tex2D(_emissionMap, distortedPos.xy).rgb * _mainEmission.rgb * _emissionStrength; // Sets emission, using a map if specified
                if (_InvertSmoothness > 0.5)
                    o.Smoothness = (1.0 - tex2D(_smoothnessMap, distortedPos.xy).r) * _smoothness; // Used to invert the smoothness map, so the user can use roughness maps instead
                else
                    o.Smoothness = tex2D(_smoothnessMap, distortedPos.xy).r * _smoothness;
                o.Metallic = tex2D(_metallicMap, distortedPos.xy).r * _metallic;
            }
            else
            {
                c = _mainColor; // If the texture toggle is off, it will just use the main colour
                o.Normal = float3(0, 0, 1); // Sets the normal to a default value
                o.Emission = _mainEmission.rgb * _emissionStrength; // Sets the emission to a default value
                o.Smoothness = _smoothness; // Sets the smoothness to a default value
                o.Metallic = _metallic; // Sets the metallic to a default value
            }
            o.Albedo = c.rgb;
            half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal)); // Calculates the rim lighting, using the angle of a given normal and the view direction
            o.Emission += _rimColour.rgb * pow(rim, 8 - _rimPower) * _rimEmission; // Adds the rim lighting to the emission, as it should be emissive
            #ifdef CEL_SHADING // If cel shading is enabled, this will run, but it's not fully functional yet
            if (_ShadingMode > 0.5) {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); // Gets the light direction
                float NdotL = dot(o.Normal, lightDir); // Calculates the dot product of the normal and light direction
                float ramp = tex2D(_rampTexture, float2(NdotL, 0.5)).r; // Gets the value from the ramp texture
                o.Albedo *= ramp; // Multiplies the albedo by the ramp value, giving a toon shading effect
            }
            #endif
        }
        ENDCG
    }
    CustomEditor "LokiGUI"
}
