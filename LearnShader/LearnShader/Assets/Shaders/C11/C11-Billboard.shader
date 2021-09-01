Shader "Unity Shaders Book/C11/C11-Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color",Color) = (1,1,1,1)
        //固定法线还是约束垂直方向
        _VerticalBillboarding("Vertical Restraints", Range(0,1)) = 1
    }
    SubShader
    {
        Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _VerticalBillboarding;

            v2f vert (a2v v)
            {
                float3 center = float3(0,0,0);
                float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));

                float3 normalDir = viewer - center;
                normalDir.y = normalDir.y * _VerticalBillboarding;
                normalDir = normalize(normalDir);

                float3 up = abs(normalDir.y)>0.999?float3(0,0,1):float3(0,1,0);
                float3 right = normalize(cross(up,normalDir));
                up = normalize(cross(normalDir,right));

                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + right * centerOffs.x + up * centerOffs.y + normalDir * centerOffs.z;

                v2f o;
                o.pos = UnityObjectToClipPos(float4(localPos,1));
                //o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }
            ENDCG
        }
        
    }
    Fallback "Transparent/VertexLit"
}
