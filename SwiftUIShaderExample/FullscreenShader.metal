#include <metal_stdlib>
using namespace metal;

// SwiftUI's shader entry point signature for layerEffect/imageEffect
// We use a fragment-like function that writes a color per pixel.
// Parameters are passed as a float array in order; SwiftUI binds them by index.

struct ShaderParams {
    float time;      // param 0
    float hue;       // param 1 (0..1)
    float intensity; // param 2 (0..1)
};

// Convert HSV to RGB (h in [0,1], s in [0,1], v in [0,1])
float3 hsv2rgb(float3 c) {
    float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    float3 p = abs(fract(float3(c.x) + float3(K.x, K.y, K.z)) * 6.0 - K.www);
    return c.z * mix(float3(K.x), clamp(p - K.x, 0.0, 1.0), c.y);
}

// Signed distance to a circle for a soft vignette effect
float sdCircle(float2 p, float r) {
    return length(p) - r;
}

// Main shader function for SwiftUI layerEffect
// Naming convention: ShaderLibrary.<name> in Swift is mapped by filename-scope.
[[ stitchable ]] half4 fullscreenGradient(
    float2 position,              // destination pixel position
    half4 color                  // destination base color (unused)
) {
    // Read parameters provided by SwiftUI in the order they were passed.
    // stitchable functions can access them via `float paramN()` builtins,
    // but here we use the new parameter() accessors by index.
    float time      = parameter(0);
    float hue       = parameter(1);
    float intensity = parameter(2);

    // Normalize coordinates to [-1, 1] with aspect correction assumed square-ish.
    float2 uv = position;
    // Scale down to create a repeating pattern
    float2 p = (uv / 200.0); // adjust scale for effect size

    // Animated field using sin/cos and time
    float v = 0.5 + 0.5 * sin(p.x * 3.1 + time) * cos(p.y * 2.7 - time * 1.3);
    v = mix(0.0, 1.0, pow(clamp(v, 0.0, 1.0), 1.5));

    // Modulate hue over time slightly
    float h = fract(hue + 0.1 * sin(time * 0.2));
    float s = clamp(intensity, 0.0, 1.0);
    float l = mix(0.2, 1.0, v);

    float3 rgb = hsv2rgb(float3(h, s, l));

    // Optional soft vignette using distance from center
    float2 centered = (uv - float2(512.0, 512.0)) / 512.0; // assume ~1024 canvas; robust enough for demo
    float d = sdCircle(centered, 0.95);
    float vignette = smoothstep(1.2, 0.0, d);

    return half4(half3(rgb) * half(vignette), 1.0);
}
