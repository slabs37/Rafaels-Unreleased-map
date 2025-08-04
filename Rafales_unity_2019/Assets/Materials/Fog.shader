// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/FogMB"
{
	Properties
	{
	   _Color("Main Color", Color) = (1, 1, 1, .5)
       _Opacity("Opacity", float) = 1
	   _IntersectionThresholdMax("Intersection Threshold Max", float) = 1
       _Pow("Fog to power of", float) = 3
       _SecondDepth("Second Depth Disable", float) = 0
	}
		SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent"  }

		Pass
		{
		   Blend SrcAlpha OneMinusSrcAlpha
		   ZWrite Off
           Cull Off
		   CGPROGRAM
		   #pragma vertex vert
		   #pragma fragment frag
		   #pragma multi_compile_fog
		   #include "UnityCG.cginc"

		   struct appdata
		   {
			   float4 vertex : POSITION;
               
		   };

		   struct v2f
		   {
			   float4 scrPos : TEXCOORD0;
			   UNITY_FOG_COORDS(1)
			   float4 vertex : SV_POSITION;
		   };

		   sampler2D _CameraDepthTexture;
		   float4 _Color;
		   float4 _IntersectionColor;
		   float _IntersectionThresholdMax;
           float _Opacity;
           float _Pow;
           float _SecondDepth;

		   v2f vert(appdata v)
		   {
			   v2f o;
			   o.vertex = UnityObjectToClipPos(v.vertex);
			   o.scrPos = ComputeScreenPos(o.vertex);
			   UNITY_TRANSFER_FOG(o,o.vertex);
			   return o;
		   }


			half4 frag(v2f i) : SV_TARGET
			{
			   float depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
			   float diff = saturate(_IntersectionThresholdMax * (depth - i.scrPos.w));
               float diff2 = saturate(_IntersectionThresholdMax * (depth*_SecondDepth - i.scrPos.w)) ;
			   fixed4 col = lerp(fixed4(_Color.rgb, 0.0), _Color, pow(diff, _Pow) - diff2);
               fixed4 colo = col*fixed4(1, 1, 1, _Opacity);

			   UNITY_APPLY_FOG(i.fogCoord, colo);
			   return colo;
			}

			ENDCG
		}
	}
}