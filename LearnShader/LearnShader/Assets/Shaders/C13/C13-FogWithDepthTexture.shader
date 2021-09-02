Shader "Unity Shaders Book/C13/C13-FogWithDepthTexture"
{
    Properties
    {
        _MainTex ("Base(RGB)", 2D) = "white" {}
        _FogDensity ("Fog Density",Float) = 1.0
        _FogColor ("Fog Color",Color) = (1,1,1,1)
        _FogStart ("Fog Start",Float) = 0.0
        _FogEnd ("Fog End",Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        float4x4 _FrustumCornersRay;

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDensity;
        fixed4 _FogColor;
        float _FogStart;
        float _FogEnd;

        struct v2f{
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
            float4 interpolatedRay : TEXCOORD2;
        };

        v2f vert(appdata_img v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0)
                o.uv_depth.y = 1 - o.uv_depth.y;
            #endif
        }

        ENDCG
    }
}
