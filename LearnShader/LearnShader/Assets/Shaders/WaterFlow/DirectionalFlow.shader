Shader "Custom/DirectionalFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
         //导数图，保存了高度在XY方向上切线的导数
        //为什么不使用法线贴图，因为平均法线没多大意义
        //正确的方法是将法线向量转换为高度导数，将它们相加，然后再转换回法线向量。
        [NoScaleOffset] _MainTex ("Deriv(AG) Height(B", 2D) = "black"{}
        //[NoScaleOffset]表示不需要分离UV和偏移
        [NoScaleOffset] _FlowMap ("Flow (RG, A noise)", 2D) = "black"{}
        //使用一个Toggle对比两种方法
        [Toggle(_DUAL_GRID)] _DualGrid ("Dual Grid", Int) = 0
       
        //Tiling
        _Tiling ("Tiling, Constant", Float) = 1
        _TilingModulated ("Tiling, Modulated", Float) = 1
        _GridResolution ("Grid Resolution", Float) = 10
        _Speed ("Speed", Float) = 1
        _FlowStrength ("Flow Strength", Float) = 1
        _HeightScale ("Height Scale, Constant", Float) = 1
        //基于流速的高度控制
        _HeightScaleModulated ("Height Scale, Modulated",Float) = 0.75

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        //toggle关键字
        #pragma shader_feature _DUAL_GRID

        #include "Flow.cginc"

        sampler2D _MainTex, _FlowMap;
        float  _Tiling, _TilingModulated, _GridResolution, _Speed, _FlowStrength;
        float _HeightScale, _HeightScaleModulated;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float3 UnpackDerivativeHeight(float4 textureData){
            float3 dh = textureData.agb;
            dh.xy = dh.xy * 2 -1;
            return dh;
        }

        float3 FlowCell (float2 uv, float2 offset, float time, float gridB){
            float2 shift = 1- offset;
            shift *= 0.5;
            //采样流动图的UV跳跃导致GPU选择一个不同级别的mipmap，
            //打断流数据导致边缘锯齿
            //避免边缘锯齿，我们要保证边缘的权重为0
            //缩放0.5使贴图有所重叠
            offset *= 0.5;
            if(gridB){
                offset += 0.25;
                shift -= 0.25;
            }
            float2x2 derivRotation;
            //划分网格,在floor UV之前通过添加偏移来找到固定流
            float2 uvTiled = (floor(uv * _GridResolution + offset) + shift) / _GridResolution;
            float3 flow = tex2D(_FlowMap, uvTiled).rgb;
            flow.xy = flow.xy * 2 - 1;
            flow.z *= _FlowStrength;
            //根据流速缩放图案大小，快速流动的地方有许多小波纹，
            //较慢的区域有较少大波纹
            //流速结合平铺可以做到
            float tiling = flow.z * _TilingModulated + _Tiling;
            float2 uvFlow = DirectionalFlow(
                uv + offset, flow, tiling, time,
                derivRotation);
            float3 dh = UnpackDerivativeHeight(tex2D(_MainTex, uvFlow));
            dh.xy = mul(derivRotation, dh.xy);
            //适应贴图缩放
            dh *= flow.z * _HeightScaleModulated + _HeightScale;
            return dh;
        }

        float3 FlowGrid (float2 uv, float time, bool gridB){
            //分别采样源和偏移网格
            //AB横向、CD纵向
            float3 dhA = FlowCell(uv, float2(0, 0), time, gridB);
            float3 dhB = FlowCell(uv, float2(1, 0), time, gridB);
            float3 dhC = FlowCell(uv, float2(0, 1), time, gridB);
            float3 dhD = FlowCell(uv, float2(1, 1), time, gridB);
            //使用三角波插值，确保两边权重为0，中间为1
            //|2t - 1|
            float2 t = uv * _GridResolution;
            if(gridB){
                t += 0.25;
            }
            t = abs(2 * frac(t) - 1);
            //AB的权重值，使用线性插值
            float wA = (1 - t.x) * (1 - t.y);
            float wB = t.x * (1 - t.y);
            float wC = (1 - t.x) * t.y;
            float wD = t.x * t.y;
            //以权重值混合它们
            return dhA * wA + dhB * wB + dhC * wC + dhD * wD;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float time = _Time.y * _Speed;
            float2 uv = IN.uv_MainTex;
            float3 dh = FlowGrid(uv, time, false);
            #if defined(_DUAL_GRID)
                dh = (dh + FlowGrid(uv, time, true)) * 0.5;
            #endif
            fixed4 c = dh.z * dh.z * _Color;
            o.Albedo = c.rgb;
            //o.Albedo = float3(t,1);
            o.Normal = normalize(float3(-dh.xy,1));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
