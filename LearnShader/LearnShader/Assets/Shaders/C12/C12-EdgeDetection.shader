Shader "Unity Shaders Book/C12/C12-EdgeDetection"
{
    Properties
    {
        _MainTex ("Base(RGB)", 2D) = "white" {}
        _EdgeOnly("Edge Only",Float) = 1.0
        _EdgeColor("Edge Color",Color) = (0,0,0,1)
        _BackgroundColor("Background Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            //关闭深度写入,防止它挡住后面被渲染的物体(标配)
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D  _MainTex;
            //纹理对应每个纹素的大小
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            
            struct v2f
            {
                half2 uv[9] : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;
                //v2f结构体中定义了一个维度为9的数组,对应了Sobel算子采样需要的9个邻域纹理坐标
                //计算采样纹理的代码在顶点着色器中,可以减少运算提高性能
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,-1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,-1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1,0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0,1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1,1);

                return o;
            }

            fixed luminance(fixed4 color){
                return 0.2125 * color + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(v2f i){
                //水平方向卷积核
                const half Gx[9] = {-1,-2,-1,
                                    0,0,0,
                                    1,2,1};
                //竖直方向卷积核
                const half Gy[9] = {-1,0,1,
                                    -2,0,2,
                                    -1,0,1};

                half texColor;
                half edgeX = 0;
                half edgeY = 0;
                for(int it = 0; it < 9; it++){
                    //采样得到亮度值
                    texColor = luminance(tex2D(_MainTex,i.uv[it]));
                    //水平方向梯度
                    edgeX += texColor * Gx[it];
                    //竖直方向梯度
                    edgeY += texColor * Gy[it];
                }
                //edge越小,表面该位置越可能是边缘
                half edge = 1 - abs(edgeX) - abs(edgeY);

                return edge;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               half edge = Sobel(i);

               fixed4 withEdgeColor = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
               fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackgroundColor,edge);
               return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
            }

            ENDCG
        }
    }
    Fallback Off
}
