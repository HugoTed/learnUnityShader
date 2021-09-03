Shader "Unity Shaders Book/Keyword/Keyword"
{
    Properties
    {
       //必须使用[Toggle]才能在在Inspector激活keyword
        [Toggle]_RED("Red",float) = 0
        [Toggle(_ShowGreen)]_Green("Green",float) = 0
        [Toggle]_BLUE("Blue",Range(0,1)) = 0
    }
    SubShader
    {
        Tags{"RenderType" = "Queue"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //不用括号直接指定,必须_开头,全大写加_ON
            #pragma multi_compile __ _RED_ON
            //由Toggle()指定keyword,不用全大写也不用加_ON
            #pragma multi_compile __ _ShowGreen
            //Inspector内可以随意但打包后只保留一个shader变体
            #pragma multi_compile __ _BLUE_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;               
            };

            struct v2f
            {              
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = float4(0,0,0,0);

                #ifdef _RED_ON
                    col.r = 1;
                #endif

                #if defined(_ShowGreen)
                    col.g = 1;
                #endif

                #ifdef _BLUE_ON
                    col.b = 1;
                #endif

                return col;
            }
            ENDCG
        }
    }
}
