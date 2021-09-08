Shader "MYPBR/MyPBR"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        
        _Roughness("Roughness", Range(0,1)) = 0.5
        _Metallic("Metallic",Range(0,1)) = 0.0
        _Fresnel("Fresnel",Range(0,1)) = 0.5
    }
    SubShader
    {
       Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Assets/Shaders/Ref/ref.cginc"
            #define PI 3.1415926

            float4 _Color;
            float _Roughness;
            float _Metallic;
            float _Fresnel;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 tangentV : TEXCOORD0;
                float3 tangentL : TEXCOORD1;
            };
          

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //副切线
                float3 binormal = cross(v.tangent.xyz,v.normal) * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
                //光源和视线方向转换到切线空间
                o.tangentL = mul(rotation,ObjSpaceLightDir(v.vertex));
                o.tangentV = mul(rotation,ObjSpaceViewDir(v.vertex));
               
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               
                float3 tangentNormal = float3(0,0,1);
                float3 tangentT = float3(1,0,0);
                float3 tangentV = normalize(i.tangentV);
                float3 tangentL = normalize(i.tangentL);
                float3 tangentH = normalize(tangentL + tangentV);
                //漫反射
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(tangentNormal,tangentL));
                //菲涅尔反射
                float F = Fresnel(_Fresnel,tangentV,tangentH);
                //微平面
                float2 roughness = float2(1 - _Roughness,1 -_Roughness);
                float D = BackmannNDF(roughness,tangentNormal,tangentT,tangentH);
                //几何衰减,阴影遮蔽函数
                float G = GeometricShadowing(tangentNormal,tangentL,tangentV);

                fixed3 specular = _LightColor0.rgb * F * D * G / (PI * dot(tangentNormal,tangentV) * dot(tangentNormal,tangentL));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.rgb;

                float3 finalCol = (1 - _Metallic) * diffuse + _Metallic * specular +ambient;

                return fixed4(finalCol,1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
