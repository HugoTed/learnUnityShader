#if !defined(FLOW_INCLUDED)
#define FLOW_INCLUDED

float3 FlowUVW(float2 uv, float2 flowVector, float2 jump, float flowOffset, float tiling, float time, bool flowB){
    //对UV交错位移，掩盖黑色渐变波纹
    float phaseOffset = flowB ? 0.5 : 0;
    float progress = frac(time + phaseOffset);
    float3 uvw;
    //使流动方向按速度图的方向流动
    //将B的uv偏移半个单位，使图案不同
    //flowOffset用于控制动画起始点
    uvw.xy = uv - flowVector * (progress + flowOffset);
    uvw.xy *= tiling;
    uvw.xy += phaseOffset;
    //每次权重为零时，我们都会进行 UV 跳跃,避免视觉滑动
    uvw.xy += (time - progress) * jump;
    //z分量作为权重控制淡出淡入,
    //w(0)=w(1)=0,w(1/2)=1
    //所以 w(p)=1-|1-2p|
    //三角波
    //不使用sin函数因为sin更复杂，但是对效果没有太多影响
    //因此我们使用效率更高的三角波
    uvw.z = 1 - abs(1 - 2 * progress);
    return uvw;
}

#endif