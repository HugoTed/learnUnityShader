Shader "Unity Shaders Book/C10/C10-Fresnel"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_FresnelScale("Fresnel Scale",Range(0,1)) = 0.5
		_Cubemap("Reflection Cubemap",Cube) = "_Skybox"{}
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
			float _FresnelScale;
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
				float3 worldRefl : TEXCOORD2;
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
				o.worldRefl = reflect(-o.worldViewDir,o.worldNormal);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 n = normalize(i.worldNormal);
				fixed3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 v = normalize(i.worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				fixed3 reflection = texCUBE(_Cubemap,i.worldRefl).rgb;
				//菲涅尔等式 F(v,n) = F0 + (1 - F0)(1 - v · n)^5
				fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(v,n),5);

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(n,l));

				fixed3 color = ambient + lerp(diffuse, reflection,saturate(fresnel)) * atten;

				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}
}
