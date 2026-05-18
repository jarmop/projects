struct VS_Input {
    float2 pos   : POSITION;
    float2 uv    : TEXCOORD0;
    float4 color : COLOR0;
};

struct VS_Output {
    float4 pos   : SV_Position;
    float2 uv    : TEXCOORD0;
    float4 color : COLOR0;
};

[shader("vertex")]
VS_Output vertMain(VS_Input input) {
    VS_Output o;

    o.pos = float4(input.pos, 0.0, 1.0);
    o.uv = input.uv;
    o.color = input.color;

    return o;
}

[[vk::binding(0, 0)]]
Texture2D font_texture;

[[vk::binding(1, 0)]]
SamplerState font_sampler;

[shader("fragment")]
float4 fragMain(VS_Output input) : SV_Target {
    float alpha =
        font_texture.Sample(
            font_sampler,
            input.uv
        ).r;

    return float4(
        input.color.rgb,
        input.color.a * alpha
    );
}