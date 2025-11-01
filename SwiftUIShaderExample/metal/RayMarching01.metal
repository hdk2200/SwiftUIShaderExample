#include <metal_stdlib>

#include <SwiftUI/SwiftUI_Metal.h>
#include "common.metal"
using namespace metal;

float sceneDistance01(float3 p)
{
    float sph = sphareDistance(p, float3(0.0,0.0,0.0), 1.0, 1.0);
    float box = sdBox(p - float3(1.5, 0, 0), float3(0.5, 0.5, 0.5));
    return min(sph, box);
}

float3 estimateNormal01(float3 p)
{
    float e = 0.001;
    float3 ex = float3(e,0,0);
    float3 ey = float3(0,e,0);
    float3 ez = float3(0,0,e);
    float dx = sceneDistance01(p + ex) - sceneDistance01(p - ex);
    float dy = sceneDistance01(p + ey) - sceneDistance01(p - ey);
    float dz = sceneDistance01(p + ez) - sceneDistance01(p - ez);
    return normalize(float3(dx, dy, dz));
}

[[ stitchable ]] half4 rayMarching01(
    float2 position,
    SwiftUI::Layer layer,
    float time,
    float2 viewportSize
) {
    // Convert position (in pixels) to normalized device-like coordinates
    float2 resolution = viewportSize;
    float2 fragCoord = position; // position is already in pixel space

    float2 p = (fragCoord - 0.5 * resolution) / resolution.y;
    float3 ro = float3(0.0, 0.0, 5.0);
    float3 rd = normalize(float3(p.x, p.y, -1.0));

    float totalDistance = 0.0;
    float3 pos;
    float dist;

    const int MAX_STEPS = 100;
    const float MAX_DISTANCE = 100.0;
    const float SURFACE_DIST = 0.001;

    for (int i = 0; i < MAX_STEPS; i++) {
        pos = ro + totalDistance * rd;
        dist = sceneDistance01(pos);
        if (dist < SURFACE_DIST || totalDistance > MAX_DISTANCE) break;
        totalDistance += dist;
    }

    if (totalDistance > MAX_DISTANCE) {
        return half4(0.0h, 0.0h, 0.0h, 1.0h);
    }

    float3 normal = estimateNormal01(pos);

    float3 lightDir = normalize(float3(0.5, 1.0, 0.8));
    float diff = clamp(dot(normal, lightDir), 0.0, 1.0);
    float3 color = diff * float3(1.0, 0.7, 0.3);

    return half4(half(color.r), half(color.g), half(color.b), 1.0h);
}
