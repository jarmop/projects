struct VertexInput {
    float3 pos;
};

struct VertexOutput {
    float4 pos : SV_Position;
    float3 color;
}

struct UniformBuffer {
    float4x4 model;
    float4x4 view;
    float4x4 proj;
    float3 color;
};
ConstantBuffer<UniformBuffer> ubo;

[shader("vertex")]
VertexOutput vertMain(VertexInput in) {
    VertexOutput out;
    // The last value of the vector is used to divide the rest of the vector values when
    // normalizing. Setting it to "1.0" makes it not have any effect.
    out.pos = mul(ubo.proj, mul(ubo.view, mul(ubo.model, float4(in.pos, 1.0))));
    out.color = ubo.color;
    return out;
}

[shader("fragment")]
float4 fragMain(VertexOutput in) : SV_Target
{
    return float4(in.color, 1.0);
}