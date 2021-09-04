#ifndef MY_BRDF_TERM
#define MY_BRDF_TERM
    //菲涅尔反射函数
    float Fresnel(float F0, float3 v, float3 n)
    {
        return F0 + (1 - F0) * pow(1 - dot(v,n), 5);
    }
    //法线分布函数
    float BackmannNDF(float2 roughness,float3 n,float3 tangent,float3 h)
    {
        float3 P = normalize(h - dot(h,n) * n);

        float px2 = P.x * P.x;
        float hz2 = h.z * h.z;
        float2 r2 = roughness*roughness;
        return 0.25/(roughness.x * roughness.y * h.z) * exp((px2/r2.x + (1 - px2)/r2.y) * (hz2 - 1)/hz2);
    }
    //阴影遮蔽函数
    float GeometricShadowing(float3 n, float3 l, float3 v)
    {
        float3 h = normalize(l+v);
        float3 nh = dot(n,h);
        float3 nl = dot(n,l);
        float3 nv = dot(n,v);
        float3 lh = dot(l,h);
        float3 vh = dot(v,h);

        float g1 = 2 * nh * nl / lh;
        float g2 = 2 * nh * nv / vh;
        return min(1,min(g1,g2));
    }

#endif