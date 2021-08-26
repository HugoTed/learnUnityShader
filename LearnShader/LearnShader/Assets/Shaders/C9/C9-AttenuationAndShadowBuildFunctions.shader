Shader "Unity Shaders Book/C9/C9-AttenuationAndShadowBuildFunctions"
{
	Properties
	{
		_Diffuse("Color",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{
		//Base Pass处理平行光
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			//保证使用光照衰减等光照变量可以正确赋值
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 vNormal : TEXCOORD0;
				float3 vPos : TEXCOORD1;
				//声明一个对阴影纹理采样的坐标
				SHADOW_COORDS(2)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vNormal = UnityObjectToWorldNormal(v.normal);
				o.vPos = mul(unity_ObjectToWorld,v.vertex);
				//计算上一步中声明的阴影纹理坐标
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				
				//fixed shadow = SHADOW_ATTENUATION(i);

				fixed3 n = normalize(i.vNormal);
				fixed3 l = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(n,l));

				fixed3 v = normalize(_WorldSpaceCameraPos.xyz - i.vPos);

				fixed3 h = normalize(v+l);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(n,h)),_Gloss);
				//平行光衰减值为1.0
				//fixed atten = 1.0;

				//第一个参数会将阴影值和光照衰减值相乘,保存到atten中会自动定义
				//第二个参数是结构体v2f传递到SHADOW_ATTENUATION中,计算阴影值
				//第三个参数是世界空间坐标,用于计算光源空间下的坐标,对光照衰减贴图进行采样得到光照衰减值.
				UNITY_LIGHT_ATTENUATION(atten,i,i.vPos);

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}

		Pass{
			//Additional pass处理其他逐像素光源
			Tags{"LightMode" = "ForwardAdd"}
			//开启和设置混合模式,这个pass计算得到的光照结果可以和帧缓存的结果进行叠加
			Blend One One

			CGPROGRAM
			//保证在Additional pass中访问到正确的光照变量
			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 vNormal : TEXCOORD0;
				float3 vPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vNormal = UnityObjectToWorldNormal(v.normal);
				o.vPos = mul(unity_ObjectToWorld,v.vertex);

				//计算上一步中声明的阴影纹理坐标
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				
				fixed shadow = SHADOW_ATTENUATION(i);

				fixed3 n = normalize(i.vNormal);

				//fixed3 l = normalize(_WorldSpaceLightPos0.xyz);
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 l = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 l = normalize(_WorldSpaceLightPos0.xyz - i.vPos);
				#endif
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(n,l));

				fixed3 v = normalize(_WorldSpaceCameraPos.xyz - i.vPos);

				fixed3 h = normalize(v+l);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(n,h)),_Gloss);
				//不同光源的衰减
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					float3 lightCoord = mul(unity_WorldToLight,float4(i.vPos,1)).xyz;
					fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif
				return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);
			}
			ENDCG
		}
	}
	//Fallback "Specular"
}
