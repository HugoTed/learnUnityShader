Shader "Unity Shaders Book/C10/C10-GlassRefraction"
{
	Properties
	{
		//该玻璃的材质纹理,默认白色
		_MainTex ("Main Tex", 2D) = "white" {}
		//玻璃法线纹理
		_BumpMap("Normal Map",2D) = "bump" {}
		//模拟反射环境纹理
		_Cubemap("Environment Cubemap",Cube) = "_Skybox"{}
		//控制折射时的扭曲程度
		_Distortion("Distortion",Range(0,100)) = 10
		//控制折射程度,为0时,该玻璃只包含反射效果,为1时只包含折射效果
		_RefractAmount("Refract Amount",Range(0.0,1.0)) = 1.0

	}
	SubShader
	{
		//设置透明队列确保不透明物体已经被绘制
		Tags{"Queue" = "Transparent" "RenderType" = "Opaque"}
		//获取玻璃后面的屏幕图像
		GrabPass{"_RefractionTex"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{	
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 scrPos : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;
				float4 TtoW1 : TEXCOORD3;
				float4 TtoW2 : TEXCOORD4;
			};
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//对被抓取的屏幕图像采样坐标
				o.scrPos = ComputeGrabScreenPos(o.pos);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 v = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));

				//计算切线空间偏移
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset + i.scrPos.xy;
				//用屏幕坐标除以屏幕分辨率得到视口空间中的坐标
				fixed3 refrCol = tex2D(_RefractionTex,i.scrPos.xy / i.scrPos.w).rgb;

				bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
				fixed3 reflDir = reflect(-v,bump);
				fixed4 texColor = tex2D(_MainTex,i.uv.xy);
				fixed3 reflCol = texCUBE(_Cubemap,reflDir).rgb * texColor.rgb;

				fixed3 finalColor = refrCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
			
				return fixed4(finalColor,1);
			}
			ENDCG
		}
	}
}
