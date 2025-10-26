#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Crosshair + circle SDF with time modulation, adapted for SwiftUI layerEffect
[[ stitchable ]] half4 crosshairSDF(
    float2 position,
    SwiftUI::Layer layer,
    float time,
    float2 viewportSize
) {
    // Get destination size in pixels
    float2 vsize = viewportSize;
    float shorterSide = min(vsize.x, vsize.y);

    // Normalize to center origin, shorter side maps to [-1, 1]
    float2 pos = (position * 2.0 - vsize) / shorterSide;

    // Crosshair line width in normalized space
    float lineWidth = 1.0 / shorterSide * 2.0;

    // Draw horizontal line at y=0 (red)
    if (-lineWidth < pos.y && pos.y < lineWidth) {
        return half4(1, 0, 0, 1);
    }

    // Draw vertical line at x=0 (green)
    if (-lineWidth < pos.x && pos.x < lineWidth) {
        return half4(0, 1, 0, 1);
    }

    // Circle SDF centered at origin with radius 0.5 (normalized)
    float radius = 0.5;
    float sdf = length(pos) - radius;

    // Time-based luminance modulation
    float l = 0.5 + 0.5 * sin(time);

    // Smooth edge based on distance from circle (simple linearstep approximation)
    float edge = clamp((abs(sdf) - 0.0) / (0.1 - 0.0), 0.0, 1.0);
    float la = (1.0 - edge) * l; // brighter near the circle

    return half4(la, la, la, 1.0);
}
