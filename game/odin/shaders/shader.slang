struct VertexInput {
    float3 pos;
};

struct UniformBuffer {
    float4x4 model;
    float4x4 view;
    float4x4 proj;
};
ConstantBuffer<UniformBuffer> ubo;

[shader("vertex")]
// float4 vertMain(uint i : SV_VertexID) : SV_Position {
float4 vertMain(VertexInput in) : SV_Position {
    // The last value of the vector is used to divide the rest of the vector values when
    // normalizing. Setting it to "1.0" makes it not have any effect.
    return mul(ubo.proj, mul(ubo.view, mul(ubo.model, float4(in.pos, 1.0))));
}

[shader("fragment")]
float4 fragMain() : SV_Target
{
    return float4(1.0, 0.6, 0.2, 1.0);
}