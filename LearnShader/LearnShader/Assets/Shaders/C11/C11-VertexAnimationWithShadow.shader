Shader "Unity Shaders Book/C11/C11-VertexAnimationWithShadow"
{
    Properties
    {
        //河流纹理
        _MainTex ("Texture", 2D) = "white" {}
        //整体颜色
        _Color ("Color Tint",Color) = (1,1,1,1)
        //水流波动的幅度
        _Magnitude ("Distortion Magnitude", Float) = 1
        //波动频率
        _Frequency ("Distortion Magnitude", Float) = 1
        //波长的倒数,越大,波长越小
        _InvWaveLength ("Distortion Inverse Wave Length",Float) = 10
        //控制河流纹理的移动速度
        _Speed ("Speed",Float) = 0.5
    }
    SubShader
    {
        //DisableBatching是否对该subshader使用批处理
        //包含离模型空间动画的shader需要关闭批处理,因为批处理会合并所有相关的模型,各自的模型空间会丢失
        Tags{"DisableBatching"="True"}
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            //关闭深度写入,开启混合模式,关闭剔除功能,让水流的每个面都能显示
            //ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
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
                float2 uv : TEXCOORD0; 
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            v2f vert (a2v v)
            {
                v2f o;
                float4 offset;
                //只希望x方向偏移,所以yzw方向设置为0
                offset.yzw = float3(0.0,0.0,0.0);
                //_Frequency和_Time.y控制频率
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
                o.pos = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv += float2(0.0, _Time.y * _Speed);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
          
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };
            v2f vert (appdata_base v){
            //v2f vert (a2v v){

                v2f o;
                float4 offset;
                //只希望x方向偏移,所以yzw方向设置为0
                offset.yzw = float3(0.0,0.0,0.0);
                //_Frequency和_Time.y控制频率
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
               
                v.vertex = v.vertex + offset;

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }


            ENDCG
        }
    }
    Fallback "VertexLit"
}
