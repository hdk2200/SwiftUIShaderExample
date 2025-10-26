#include <metal_stdlib>
using namespace metal;

#define M_PI 3.14159265359

// Generic mod helper

template <typename Tx, typename Ty>
static inline Tx mod(Tx x, Ty y)
{
    return x - y * floor(x / y);
}

// Rotation matrix (XYZ order)
static inline float3x3 rotationXYZ(float angleX, float angleY, float angleZ)
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

// Transform helper

template <typename Tx ,typename T>
static inline Tx trans(Tx p, T m)
{
    return (p - m) * m + m;
}

// SDF: sphere
static inline float sphareDistanceTrans(float3 p, float3 center, float radius, float m)
{
    float3 pt = trans(p, m);
    return length(pt - center) - radius;
}

static inline float sphareDistance(float3 p, float3 center, float radius, float m)
{
    return length(p - center) - radius;
}

// SDF: box (axis-aligned)
static inline float sdBox(float3 p, float3 b)
{
    float3 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}
