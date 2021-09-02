Shader "Unity Shaders Book/C12/C12-Bloom"
{
    Properties
    {
        //输入的渲染纹理
        _MainTex ("Base(RGB)", 2D) = "white" {}
        //高斯模糊后较亮区域
        _Bloom ("Bloom(RGB)",2D) = "black"{}
        //提取较亮区域用的阈值
        _luminanceThreshold("luminance Threshold",Float) = 0.5
        //模糊区域范围
        _BlurSize ("Blur Size",Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _luminanceThreshold;
        float _BlurSize;

        struct v2f{
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        v2f vertExtractBright(appdata_img v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        fixed luminance(fixed4 color){
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        fixed4 fragExtractBright(v2f i) : SV_Target{
            fixed4 c = tex2D(_MainTex,i.uv);
            //将采样得到的亮度值减去阈值,并把结果截取到0~1之间
            fixed val = clamp(luminance(c) - _luminanceThreshold,0.0,1.0);
            return c * val;
        }
        //混合亮部图像和原图像时使用的顶点着色器和片元着色器
        struct v2fBloom{
            float4 pos : SV_POSITION;
            //xy对应_Maintex,zw对应_Bloom
            half4 uv : TEXCOORD0;
        };

        v2fBloom vertBloom(appdata_img v){
            v2fBloom o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0.0)
                o.uv.w = 1.0 - o.uv.w;
            #endif

            return o;
        }

        fixed4 fragBloom(v2fBloom i) : SV_Target{
            return tex2D(_MainTex,i.uv.xy) + tex2D(_Bloom,i.uv.zw);
        }

        ENDCG

        ZTest Always Cull Off ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }

        UsePass "Unity Shaders Book/C12/C12-GaussianBlur/GAUSSIAN_BLUR_VERTICAL"

        UsePass "Unity Shaders Book/C12/C12-GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }
    }
    Fallback Off
}
