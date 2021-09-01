Shader "Unity Shaders Book/C10/C10-Refraction"
{
	Properties
	{
		_Color ("Color Tint",Color) = (1,1,1,1)
		_RefractColor("Refraction Color",Color) = (1,1,1,1)
		_RefractAmount("Refract Amount",Range(0,1)) = 1
		_RefractRatio("Refract Ratio",Range(0.1,1)) = 0.5
		_Cubemap("Refraction Cubemap",Cube) = "_Skybox"{}
	}
	SubShader
	{
		

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			fixed4 _RefractColor;
			float _RefractAmount;
			float _RefractRatio;
			samplerCUBE _Cubemap;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{				
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldViewDir : TEXCOORD1;
				float3 worldRefr : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				//refract
				//第一个参数:入射光线方向,必须归一化
				//第二个参数:表面法线,须归一化
				//第三个参数:入射介质和折射介质
				o.worldRefr = refract(-normalize(o.worldViewDir),normalize(o.worldNormal),_RefractRatio);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 n = normalize(i.worldNormal);
				fixed3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 v = normalize(i.worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(n,l));

				//cube map计算反射
				fixed3 refraction = texCUBE(_Cubemap,i.worldRefr).rgb * _RefractColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				//用_RefractAmount来混合漫反射和折射颜色
				fixed3 color = ambient + lerp(diffuse,refraction,_RefractAmount) * atten;
				return fixed4(color,1.0);
				
			}
			ENDCG
		}
	}
}
