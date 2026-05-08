static float2 positions[6] = float2[](
    float2(0.0, 0.0),
    float2(0.5, 0.0),
    float2(0.5, 0.5),
    float2(0.5, 0.5),
    float2(0.0, 0.5),
    float2(0.0, 0.0)
);

struct UniformBuffer {
    float4x4 model;
    float4x4 view;
    float4x4 proj;
};
ConstantBuffer<UniformBuffer> ubo;

[shader("vertex")]
float4 vertMain(uint i : SV_VertexID) : SV_Position {
    // The last value of the vector is used to divide the rest of the vector values when
    // normalizing. Setting it to "1.0" makes it not have any effect.
    // return float4(positions[i], 0.0, 1.0);
    return mul(ubo.proj, mul(ubo.view, mul(ubo.model, float4(positions[i], 0.0, 1.0))));
}

[shader("fragment")]
float4 fragMain() : SV_Target
{
    return float4(1.0, 0.6, 0.2, 1.0);
}