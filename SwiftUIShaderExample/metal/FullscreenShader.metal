#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
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
//    half4 color,                   //destination base color (unused)
    SwiftUI::Layer layer,
    float time
//    float hue,
//    float intensity
) {
    // Simplified: always output solid red, ignore all inputs.
    // This helps verify the shader pipeline is wired correctly.
    // If you want to restore the animated gradient, revert this block.
//    (void)position; (void)color; (void)time; (void)hue; (void)intensity; // silence unused warnings
//    return half4(1.0, 0.0, 0.0, 1.0);
//  return half4(1.0, 0.0, 0.0, 1.0);

//  float r = abs(sin(time) * 254.0);
  float r =  0;
  float g =  abs(cos(time)) * 0.5;
  float b =  0;

//  float g = abs(cos(time)  * 1.0);
//  float b = abs(tan(time ) / 1.0);
  return half4(r, g, b, 1.0);

}


// Main shader function for SwiftUI layerEffect
// Naming convention: ShaderLibrary.<name> in Swift is mapped by filename-scope.
[[ stitchable ]] half4 fullscreenGradient2(
    float2 position,              // destination pixel position
//    half4 color,                   //destination base color (unused)
    SwiftUI::Layer layer,
    float time
//    float hue,
//    float intensity
) {
    // Simplified: always output solid red, ignore all inputs.
    // This helps verify the shader pipeline is wired correctly.
    // If you want to restore the animated gradient, revert this block.
//    (void)position; (void)color; (void)time; (void)hue; (void)intensity; // silence unused warnings
//    return half4(1.0, 0.0, 0.0, 1.0);
//  return half4(1.0, 0.0, 0.0, 1.0);

//  float r = abs(sin(time) * 254.0);
  float r =  abs(sin(time)) * 1.0;
  float g =  abs(cos(time)) * 1.0;
  float b =  abs(cos(time)) * 1.0;

//  float g = abs(cos(time)  * 1.0);
//  float b = abs(tan(time ) / 1.0);
  return half4(r, g, b, 1.0);

}
