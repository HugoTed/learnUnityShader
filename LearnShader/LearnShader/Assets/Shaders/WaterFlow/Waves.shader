Shader "Custom/Waves"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        //振幅
        //_Amplitude ("Amplitude", Float) = 1
        //控制波峰,使用这个表示振幅和波长之间的关系
        _Steepness ("Steepness", Range(0, 1)) = 0.5
        //波长
        _Wavelength ("Wavelength", Float) = 10
        _Speed ("Speed", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        //顶点偏移后，addshadow可以对偏移后的阴影产生影响
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0


        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Steepness, _Wavelength, _Speed;

        void vert(inout appdata_full vertexData){
            float3 p = vertexData.vertex.xyz;

            float k = 2 * UNITY_PI / _Wavelength;
            float f = k * (p.x - _Speed * _Time.y);
            //振幅
            float a = _Steepness / k;
            //Gerstner wave
            //P=[x+acosf]
            //  [ asinf ]
            p.x += a * cos(f);
            p.y = a * sin(f);
            //计算切线
            //T=P求导，P=[x asin(k(x-ct))]，忽略z轴
            //T=[1-kasinf kacosf]
            float3 tangent = normalize(float3(
                1 - _Steepness * sin(f), 
                _Steepness * cos(f), 
                0));
            //计算法线，因为z轴是固定的，所以副切线是单位向量可以忽略
            float3 normal = float3(-tangent.y, tangent.x, 0);
            vertexData.vertex.xyz = p;
            vertexData.normal = normal;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
