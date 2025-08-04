Shader "Custom/UVFadeWithEmission"
{
  Properties
  {
    _MainTex       ("Base Texture (RGBA)", 2D) = "white" {}
    _EmissionColor("Emission Color", Color)    = (1,1,1,1)
    _EmissionMap   ("Emission Map (RGBA)", 2D) = "white" {}
    _UseMap        ("Use Emission Map", Float)  = 0

    _FadeOffset    ("Fade Offset (V)", Range(0,1))    = 0
    _FadeRange     ("Fade Range (V)",  Range(0.01,2)) = 1
  }
  SubShader
  {
    Tags { "Queue"="Transparent" "RenderType"="Transparent" }
    Cull Off
    ZWrite Off
    Blend SrcAlpha OneMinusSrcAlpha

    Pass
    {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #include "UnityCG.cginc"

      sampler2D _MainTex;
      float4   _MainTex_ST;

      sampler2D _EmissionMap;
      float4   _EmissionMap_ST;
      float4   _EmissionColor;
      float    _UseMap;

      float    _FadeOffset;
      float    _FadeRange;

      struct appdata
      {
        float4 vertex : POSITION;
        float2 uv     : TEXCOORD0;
      };

      struct v2f
      {
        float2 uvMain : TEXCOORD0;
        float2 uvEm   : TEXCOORD1;
        float4 pos    : SV_POSITION;
      };

      v2f vert (appdata v)
      {
        v2f o;
        o.pos     = UnityObjectToClipPos(v.vertex);
        o.uvMain  = TRANSFORM_TEX(v.uv, _MainTex);
        o.uvEm    = TRANSFORM_TEX(v.uv, _EmissionMap);
        return o;
      }

      fixed4 frag (v2f i) : SV_Target
      {
        // 1) Sample base color & alpha
        fixed4 baseCol = tex2D(_MainTex, i.uvMain);

        // 2) Compute UV‐fade factor (0 when V < offset, 1 when V > offset+range)
        float fade = saturate((i.uvMain.y - _FadeOffset) / _FadeRange);

        // 3) Fade out alpha
        baseCol.a *= fade;

        // 4) Sample or use flat emission
        fixed4 emMap = tex2D(_EmissionMap, i.uvEm);
        fixed3 emBase = _UseMap > 0.5
                          ? emMap.rgb * emMap.a   // use alpha of map to modulate
                          : _EmissionColor.rgb;

        // fade the emission in exactly the same way
        fixed3 emission = emBase * fade;

        // 5) Final color: lit only by our own color + emission
        //    (since this is an unlit pass, "baseCol.rgb" is a straight texture tint)
        fixed3 finalRGB = baseCol.rgb + emission;

        return fixed4(finalRGB, baseCol.a);
      }
      ENDCG
    }
  }
  FallBack "Diffuse"
}
