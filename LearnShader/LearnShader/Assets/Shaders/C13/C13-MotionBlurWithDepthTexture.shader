Shader "Unity Shaders Book/C13/MotionBlurWithDepthTexture"
{
    Properties
    {
        //输入的渲染纹理
        _MainTex ("Base(RGB)", 2D) = "white" {}
        _BlurSize("Blur Size",Float) = 1.0
    }
    SubShader
    {
        
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;  
        //用来对深度纹理的采样坐标进行平台差异化处理
        half4 _MainTex_TexelSize;
        //深度纹理
        sampler2D _CameraDepthTexture;
        float4x4 _CurrentViewProjectionInverseMatrix;
        float4x4 _PreviousViewProjectionMatrix;    
        half _BlurSize;
        float4x4 _ViewInvMatrix;    
        float4x4 _PreViewInvMatrix;  

        struct v2f{
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
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

            return o;
        }

        fixed4 frag(v2f i) : SV_Target{
            //利用深度纹理和当前帧视角*投影矩阵求得该像素在世界空间的坐标

            //利用SAMPLE_DEPTH_TEXTURE对深度纹理采样,得到深度值d
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth);
            // //通过映射反函数求得NDC的坐标H
            // float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1,d * 2 - 1,1 );
            // //当前帧的视角*投影逆矩阵对H进行变换
            // float4 D = mul(_CurrentViewProjectionInverseMatrix,H);
            // //把变换结果除以他的w分量得到世界空间下的坐标worldPos
            // float4 worldPos = D / D.w;
            
            float4 H = LinearEyeDepth(d);
            
            float4 worldPos = mul(_ViewInvMatrix,H);

            float4 currentPos = H;
            //使用前一帧的视角*投影矩阵对世界坐标进行变换,得到前一帧在NDC下的坐标previousPos
            // float4 previousPos = mul(_PreviousViewProjectionMatrix,worldPos);

            // previousPos /= previousPos.w;
            
            float4 previousPos = mul(_PreViewInvMatrix,worldPos);
            
            //然后计算前一帧和当前帧在屏幕空间下的位置差,得到速度velocity
            float2 velocity = (currentPos.xy - previousPos.xy)/2.0f;

            float2 uv = i.uv;
            float4 c = tex2D(_MainTex,uv);

            uv += velocity * _BlurSize;
            for(int it = 1;it < 3;it++,uv += velocity * _BlurSize){
                float4 currentColor = tex2D(_MainTex,uv);
                c += currentColor;
            }

            c /= 3;

            return fixed4(c.rgb,1.0);

        }

        ENDCG

        
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

        
    }
    Fallback Off
    
}
