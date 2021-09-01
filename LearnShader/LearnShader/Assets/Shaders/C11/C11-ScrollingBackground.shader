Shader "Unity Shaders Book/C11/C11-ScrollingBackground"
{
    Properties
    {
        //较远纹理
        _MainTex ("Base Layer(RGB)", 2D) = "white" {}
        //远纹理
        _DetailTex ("2nd Layer(RGB)", 2D) = "white" {}
        //第一层滚动速度
        _ScrollX("Base Layer Scroll Speed",Float) = 1.0
        _Scroll2X("2nd Layer Scroll Speed",Float) = 1.0
        //控制纹理整体亮度
        _Mutiplier("Layer Mutiplier",Float) = 1
    }
    SubShader
    {
       
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
         
            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Mutiplier;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + frac(float2(_ScrollX,0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex) + frac(float2(_Scroll2X,0.0) * _Time.y);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex,i.uv.zw);

                fixed4 c = lerp(firstLayer,secondLayer,secondLayer.a);
                c.rgb *= _Mutiplier;

               
                return c;
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}
