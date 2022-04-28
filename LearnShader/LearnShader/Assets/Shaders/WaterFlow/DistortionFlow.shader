Shader "Custom/DistortionFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        //[NoScaleOffset]表示不需要分离UV和偏移
        [NoScaleOffset] _FlowMap ("Flow (RG, A noise)", 2D) = "black"{}
        //导数图，保存了高度在XY方向上切线的导数
        //为什么不使用法线贴图，因为平均法线没多大意义
        //正确的方法是将法线向量转换为高度导数，将它们相加，然后再转换回法线向量。
        [NoScaleOffset] _DerivHeightMap ("Deriv(AG) Height(B", 2D) = "black"{}
        //控制UV跳动
        _UJump ("U jump per phase", Range(-0.25, 0.25)) = 0.25
        _VJump ("U jump per phase", Range(-0.25, 0.25)) = 0.25
        //Tiling
        _Tiling ("Tiling", Float) = 1
        _Speed ("Speed", Float) = 1
        _FlowStrength ("Flow Strength", Float) = 1
        _FlowOffset ("Flow Offset", Float) = 0
        _HeightScale ("Height Scale", Float) = 1
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

        #include "Flow.cginc"

        sampler2D _MainTex, _FlowMap, _DerivHeightMap;
        float _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset;
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

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            //采样速度图,使用和normal map一样的编码方式，所以*2-1来解码
            //从速度图上采样水流速度
            float3 flow = tex2D(_FlowMap, IN.uv_MainTex).rgb;
            flow.xy = flow.xy * 2 - 1;
            flow *= _FlowStrength;
            // flowVector *= _FlowStrength;
           
            //采样noise
            float noise = tex2D(_FlowMap, IN.uv_MainTex).a;
            float time = _Time.y * _Speed + noise;
            float2 jump = float2(_UJump, _VJump);
            //对贴图采样两次来混合淡出权重
            //调用Flow.cginc的FlowUVW返回新的UV坐标
            float3 uvwA = FlowUVW(
                IN.uv_MainTex, flow.xy, jump, 
                _FlowOffset, _Tiling, time, false);
            float3 uvwB = FlowUVW(
                IN.uv_MainTex, flow.xy, jump,
                _FlowOffset, _Tiling, time, true);
            // float3 uvwA = FlowUVW(IN.uv_MainTex, float2(0,0), jump, _Tiling, time, false);
            // float3 uvwB = FlowUVW(IN.uv_MainTex, float2(0,0), jump, _Tiling, time, true);

            //流速等于flowVector的模,再控制高度
            float finalHeightScale = flow.z * _HeightScaleModulated + _HeightScale;
            //计算导数图
            float3 dhA = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwA.xy)) * 
            (uvwA.z * finalHeightScale);
            float3 dhB = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwB.xy)) * 
            (uvwB.z * finalHeightScale);
            o.Normal = normalize(float3(-(dhA.xy + dhB.xy), 1));
           
            fixed4 texA = tex2D(_MainTex,uvwA.xy) * uvwA.z;
            fixed4 texB = tex2D(_MainTex,uvwB.xy) * uvwB.z;
            // Albedo comes from a texture tinted by color
            fixed4 c = (texA + texB) * _Color;
            o.Albedo = c.rgb;
            //显示高度数据
            //o.Albedo = pow(dhA.z + dhB.z, 2);
            //o.Albedo = float3(flowVector,0);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
