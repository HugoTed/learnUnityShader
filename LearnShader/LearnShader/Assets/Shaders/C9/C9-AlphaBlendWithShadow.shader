﻿Shader "Unity Shaders Book/C9/C9-AlphaBlendWithShadow"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_AlphaScale("Alpha Scale",Range(0,1)) = 1
	}
	SubShader
	{
		//渲染队列,不受投影器影响
		Tags{"Queue" = "Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		Pass
		{
			Tags{"LightMdoe" = "ForwardBase"}
			//第一个pass只渲染后面
			Cull Front

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"


			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;	
			fixed _AlphaScale;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float4 texcoord : TEXCOORD;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				//o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 n = normalize(i.worldNormal);
				fixed3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex,i.uv);
				
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(n,l));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4(ambient + diffuse * atten, texColor.a * _AlphaScale);
			}
			
			ENDCG
		}

		Pass
		{
			Tags{"LightMdoe" = "ForwardBase"}
			//第二个pass只渲染前面
			Cull Back

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;	
			fixed _AlphaScale;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float4 texcoord : TEXCOORD;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				//o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 n = normalize(i.worldNormal);
				fixed3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex,i.uv);
				
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(n,l));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				return fixed4(ambient + diffuse * atten, texColor.a * _AlphaScale);
			}
			
			ENDCG
		}
	}
	Fallback "VertexLit"
}
