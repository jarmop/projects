struct VertexInput {
    float3 pos;
    float3 normal;
};

struct VertexOutput {
    float4 pos : SV_Position;
    float3 normal;
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
    out.normal = in.normal;
    out.color = ubo.color;
    return out;
}

[shader("fragment")]
float4 fragMain(VertexOutput in) : SV_Target
{
    // float3 lightDirection = normalize(-float3(-0.2, -1.0, -0.3));
    float3 lightDirection = normalize(float3(0.4, 1.0, 0.7));
    float3 lightDirection2 = normalize(float3(-0.8, 1.0, -0.6));

    float3 ambient  = float3(0.2, 0.2, 0.2);
    float diffuseStrength = max(dot(in.normal, lightDirection), 0.0);
    float diffuseStrength2 = max(dot(in.normal, lightDirection2), 0.0);
    float3 diffuse = diffuseStrength * float3(0.6, 0.6, 0.6);
    float3 diffuse2 = diffuseStrength2 * float3(0.2, 0.2, 0.2);

    return float4((ambient + diffuse + diffuse2) * in.color, 1.0);
}