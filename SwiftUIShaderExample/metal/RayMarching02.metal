#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

#include "common.metal"

// Scene distance for RayMarching02: same logic as 01 for now
inline float sceneDistance02(float3 p)
{
    float sph = sphareDistance(p, float3(0.0,0.0,0.0), 1.0, 1.0);
    float box = sdBox(p - float3(1.5, 0, 0), float3(0.5, 0.5, 0.5));
    return min(sph, box);
}

inline float3 estimateNormal02(float3 p)
{
    float e = 0.001;
    float3 ex = float3(e,0,0);
    float3 ey = float3(0,e,0);
    float3 ez = float3(0,0,e);
    float dx = sceneDistance02(p + ex) - sceneDistance02(p - ex);
    float dy = sceneDistance02(p + ey) - sceneDistance02(p - ey);
    float dz = sceneDistance02(p + ez) - sceneDistance02(p - ez);
    return normalize(float3(dx, dy, dz));
}

[[ stitchable ]] half4 rayMarching02(
    float2 position,
    SwiftUI::Layer layer,
    float time,
    float2 viewportSize
) {
    float2 resolution = viewportSize;
    float2 fragCoord = position;

    float2 p = (fragCoord - 0.5 * resolution) / resolution.y;

    // Camera: different viewpoint for 02
    // Animated orbiting camera around origin
    float angle = time * 0.5;
    float3 ro = float3(3.0 * sin(angle), 1.0, 3.0 * cos(angle));

    // Build a simple look-at ray direction using screen coords p
    float3 target = float3(0.0, 0.0, 0.0);
    float3 forward = normalize(target - ro);
    float3 right = normalize(cross(float3(0,1,0), forward));
    float3 up = cross(forward, right);
    float3 rd = normalize(forward + p.x * right + p.y * up);

    float totalDistance = 0.0;
    float3 pos;
    float dist;

    const int MAX_STEPS = 100;
    const float MAX_DISTANCE = 100.0;
    const float SURFACE_DIST = 0.001;

    for (int i = 0; i < MAX_STEPS; i++) {
        pos = ro + totalDistance * rd;
        dist = sceneDistance02(pos);
        if (dist < SURFACE_DIST || totalDistance > MAX_DISTANCE) break;
        totalDistance += dist;
    }

    if (totalDistance > MAX_DISTANCE) {
        return half4(0.0h, 0.0h, 0.0h, 1.0h);
    }

    float3 normal = estimateNormal02(pos);

    float3 lightDir = normalize(float3(0.5, 1.0, 0.8));
    float diff = clamp(dot(normal, lightDir), 0.0, 1.0);
    float3 color = diff * float3(1.0, 0.7, 0.3);

    return half4(half(color.r), half(color.g), half(color.b), 1.0h);
}
