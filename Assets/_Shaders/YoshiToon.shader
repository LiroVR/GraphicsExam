Shader "Loki/Yoshi Toon"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _OutlineThickness ("Outline Thickness", Float) = 0.03
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _ScrollY ("Scroll Y", Range(-1,1)) = 0
        _ScrollX ("Scroll X", Range(-1,1)) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        // Outline Pass
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

        // Main Toon Pass
        CGPROGRAM
        #pragma surface surf ToonRamp

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _RampTex;
        half4 _Color;
        float _ScrollY;
        float _ScrollX;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            float2 scrollUV = IN.uv_MainTex + float2(_ScrollX, _ScrollY); 
            fixed4 c = tex2D(_MainTex, scrollUV) * _Color;
            o.Albedo = c.rgb;
        }

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

        ENDCG
    }
    FallBack "Diffuse"
}
