#include <metal_stdlib>

#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

//
//#include "MetalCommon/shaderSample.h"
//#include "MetalCommon/shadersample_internal.h"

#define M_PI 3.14159265359

template <typename Tx, typename Ty>
inline Tx mod(Tx x, Ty y)
{
    return x - y * floor(x / y);
}

float3x3 rotationXYZ(float angleX, float angleY, float angleZ)
{
    float cx = cos(angleX);
    float sx = sin(angleX);
    float cy = cos(angleY);
    float sy = sin(angleY);
    float cz = cos(angleZ);
    float sz = sin(angleZ);

    float3x3 rx = float3x3(
        float3(1, 0, 0),
        float3(0, cx, -sx),
        float3(0, sx, cx)
    );

    float3x3 ry = float3x3(
        float3(cy, 0, sy),
        float3(0, 1, 0),
        float3(-sy, 0, cy)
    );

    float3x3 rz = float3x3(
        float3(cz, -sz, 0),
        float3(sz, cz, 0),
        float3(0, 0, 1)
    );

    return rz * ry * rx;
}

template <typename Tx ,typename T>
inline Tx trans(Tx p, T m)
{
    return (p - m) * m + m;
}

float sphareDistanceTrans(float3 p, float3 center, float radius, float m)
{
    float3 pt = trans(p, m);
    return length(pt - center) - radius;
}

float sphareDistance(float3 p, float3 center, float radius, float m)
{
    return length(p - center) - radius;
}

float sdBox(float3 p, float3 b)
{
    float3 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

float distance(float3 p)
{
    float sph = sphareDistance(p, float3(0.0,0.0,0.0), 1.0, 1.0);
    float box = sdBox(p - float3(1.5, 0, 0), float3(0.5, 0.5, 0.5));
    return min(sph, box);
}

float3 sphareNormal(float3 p, float3 center, float radius, float m)
{
    float epsilon = 0.001;
    float3 e = float3(epsilon, 0, 0);
    float d = sphareDistance(p, center, radius, m);
    float nx = sphareDistance(p + e.xyy, center, radius, m) - d;
    float ny = sphareDistance(p + e.yxy, center, radius, m) - d;
    float nz = sphareDistance(p + e.yyx, center, radius, m) - d;
    return normalize(float3(nx, ny, nz));
}

float3 sdBoxNormal(float3 p)
{
    float epsilon = 0.001;
    float3 e = float3(epsilon, 0, 0);
    float d = sdBox(p, float3(0.5, 0.5, 0.5));
    float nx = sdBox(p + e.xyy, float3(0.5, 0.5, 0.5)) - d;
    float ny = sdBox(p + e.yxy, float3(0.5, 0.5, 0.5)) - d;
    float nz = sdBox(p + e.yyx, float3(0.5, 0.5, 0.5)) - d;
    return normalize(float3(nx, ny, nz));
}

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};
//
//fragment float4 shaderSampleRayMarching01(VertexOut in [[stage_in]],
//                                          constant float2 &viewportSize [[viewport_size]])
//{
//    float2 resolution = viewportSize;
//    float2 fragCoord = in.uv * resolution;
//
//    float2 p = (fragCoord - 0.5 * resolution) / resolution.y;
//    float3 ro = float3(0.0, 0.0, 5.0);
//    float3 rd = normalize(float3(p.x, p.y, -1.0));
//
//    float totalDistance = 0.0;
//    float3 pos;
//    float dist;
//
//    const int MAX_STEPS = 100;
//    const float MAX_DISTANCE = 100.0;
//    const float SURFACE_DIST = 0.001;
//    int i;
//    for(i = 0; i < MAX_STEPS; i++)
//    {
//        pos = ro + totalDistance * rd;
//        dist = distance(pos);
//        if(dist < SURFACE_DIST || totalDistance > MAX_DISTANCE)
//            break;
//        totalDistance += dist;
//    }
//
//    if(totalDistance > MAX_DISTANCE)
//    {
//        return float4(0.0, 0.0, 0.0, 1.0);
//    }
//
//    float3 normal;
//    if(dist < 0.01)
//    {
//        if(length(pos - float3(0.0,0.0,0.0)) < 1.0 + 0.01)
//        {
//            normal = sphareNormal(pos, float3(0.0,0.0,0.0), 1.0, 1.0);
//        }
//        else
//        {
//            normal = sdBoxNormal(pos - float3(1.5, 0, 0));
//        }
//    }
//    else
//    {
//        normal = float3(0.0, 0.0, 1.0);
//    }
//
//    float3 lightDir = normalize(float3(0.5, 1.0, 0.8));
//    float diff = clamp(dot(normal, lightDir), 0.0, 1.0);
//    float3 color = diff * float3(1.0, 0.7, 0.3);
//
//    return float4(color, 1.0);
//}
//
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
        dist = distance(pos);
        if (dist < SURFACE_DIST || totalDistance > MAX_DISTANCE) break;
        totalDistance += dist;
    }

    if (totalDistance > MAX_DISTANCE) {
        return half4(0.0h, 0.0h, 0.0h, 1.0h);
    }

    float3 normal;
    if (dist < 0.01) {
        if (length(pos - float3(0.0, 0.0, 0.0)) < 1.0 + 0.01) {
            normal = sphareNormal(pos, float3(0.0, 0.0, 0.0), 1.0, 1.0);
        } else {
            normal = sdBoxNormal(pos - float3(1.5, 0, 0));
        }
    } else {
        normal = float3(0.0, 0.0, 1.0);
    }

    float3 lightDir = normalize(float3(0.5, 1.0, 0.8));
    float diff = clamp(dot(normal, lightDir), 0.0, 1.0);
    float3 color = diff * float3(1.0, 0.7, 0.3);

    return half4(half(color.r), half(color.g), half(color.b), 1.0h);
}
