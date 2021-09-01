Shader "Matcap/Matcap"
{
    Properties
    {
        _MainTex ("Matcap Texture", 2D) = "white" {}
    }
    SubShader
    {
       
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
           
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 normal : Normal;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 matcapUV : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 n2v = mul(UNITY_MATRIX_IT_MV,v.normal);

                //将法线由模型空间转换到观察空间,用来采样matcap贴图
                // o.matcapUV.x = mul(UNITY_MATRIX_IT_MV[0],v.normal);
                // o.matcapUV.y = mul(UNITY_MATRIX_IT_MV[1],v.normal);
                o.matcapUV = normalize(n2v).xy;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //将matcapUV从[-1,1]映射到[0,1]区间
                //uv * 0.5 +0.5
                fixed4 col = tex2D(_MainTex,i.matcapUV * 0.5 + 0.5);
                return col; 
            }
            ENDCG
        }
    }
}
