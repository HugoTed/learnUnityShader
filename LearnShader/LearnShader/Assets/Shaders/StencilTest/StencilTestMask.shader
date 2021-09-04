// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "StencilTest/StencilTestMask"
{
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-1"}
        CGINCLUDE
            struct appdata {
                float4 vertex : POSITION;
            };
            struct v2f {
                float4 pos : SV_POSITION;
            };
            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            half4 frag(v2f i) : SV_Target {
                return half4(1,1,0,1);
            }
        ENDCG
        Pass {
        ColorMask 0
	    ZWrite Off
	    Stencil
        {
            Ref 1
            Comp Always
            Pass Replace //当模版测试和深度测试都通过时，进行处理
            //替换(拿参考值替代原有值)

            // Pass 当模版测试和深度测试都通过时，进行处理

            // Fail 当模版测试和深度测试都失败时，进行处理
            // ZFail 当模版测试通过而深度测试失败时，进行处理

            // pass,Fail,ZFail都属于Stencil操作，他们参数统一如下：

            // Keep 保持(即不把参考值赋上去,直接不管)
            // Zero 归零
            // Replace 替换(拿参考值替代原有值)
            // IncrSat 值增加1，但不溢出，如果到255，就不再加
            // DecrSat 值减少1，但不溢出，值到0就不再减
            // Invert 反转所有位，如果1就会变成254
            // IncrWrap 值增加1，会溢出，所以255变成0
            // DecrWrap 值减少1，会溢出，所以0变成255
        }
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        ENDCG
        }   
    } 
}
