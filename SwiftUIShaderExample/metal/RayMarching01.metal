#include <metal_stdlib>

#include <SwiftUI/SwiftUI_Metal.h>
#include "common.metal"
using namespace metal;

// 法線を求める。
float3 sphareNormal(float3 p, float3 center, float radius, float m)
{
  float d = 0.001;

  return normalize(float3(
      sphareDistance(p + float3(d, 0.0, 0.0), center, radius, m) - sphareDistance(p + float3(-d, 0.0, 0.0), center, radius, m),
      sphareDistance(p + float3(0.0, d, 0.0), center, radius, m) - sphareDistance(p + float3(0.0, -d, 0.0), center, radius, m),
      sphareDistance(p + float3(0.0, 0.0, d), center, radius, m) - sphareDistance(p + float3(0.0, 0.0, -d), center, radius, m)));
}



/// ボックス形状の法線をSDFの勾配を利用して求める。
float3 sdBoxNormal(float3 p)
{
  float d = 0.001;

  return normalize(float3(
      distance(p + float3(d, 0.0, 0.0)) - distance(p + float3(-d, 0.0, 0.0)),
      distance(p + float3(0.0, d, 0.0)) - distance(p + float3(0.0, -d, 0.0)),
      distance(p + float3(0.0, 0.0, d)) - distance(p + float3(0.0, 0.0, -d))));
}

/// `p` 位置にあるオブジェクト（繰り返しボックス）の距離を返す。
static float distance01(float3 p)
{
//  return sdBox(trans(p - float3(0), 1), float3(0.1, 0.1, 0.1));
  return sphareDistance(trans(p - float3(0), 1), float3(0.1, 0.1, 0.1), 0.6 , 1.0);
}


[[ stitchable ]] half4 rayMarching01(
    float2 position,
    SwiftUI::Layer layer,
    float time,
    float2 viewportSize
) {
  // 球の半径（ここでは固定値で使用）
  float radius = 0.1;

  // 球の中心位置（未使用だが残っている）
  float3 spharePos = float3(0.0);

  // -1.0 ~ 1.0 に正規化されたスクリーン座標を計算
  float2 pos = (position.xy * 2.0 - viewportSize) / min(viewportSize.x, viewportSize.y);

  // カメラの初期位置（Z方向に奥に配置）
  float3 cameraPos = float3(0.0, .0, 5.0);

  // スクリーン上のZ位置（基本的に0）
  float zPos = 0.0;

  // レイの方向ベクトルを正規化して生成
  float3 ray = normalize(float3(pos, zPos) - cameraPos);

  // 光の方向ベクトル（Z方向から）
  float3 lightDir = normalize(float3(1.0, -1.0, 1.0));

  // レイの進行距離初期化
  float depth = 0.05;

  // ベースカラーと初期カラー設定
  float colorelement = 0.5 * sin(time) + 0.5;
  float3 baseColor = float3(colorelement, colorelement, colorelement);
  float3 color = float3(0.1);

  // 時間に応じて繰り返し配置の間隔を変化させる（最低0.5、最大10.0）
  float m = clamp(10.0 * cos(time), 0.5, 10.0);

  // 最大ステップ数でループ（Ray Marching）
  for (int i = 0; i < 128; i++) {
    // 現在のレイの位置を計算
    float3 rayPos = cameraPos + ray * depth;

    // その位置とオブジェクトとの距離を取得
    float dist = distance01(rayPos);

    // しきい値以下なら衝突とみなす
    if (dist < 0.001) {
      // 衝突面の法線を取得
//      float3 normal = sdBoxNormal(cameraPos);
      
      float3 normal = sphareNormal( rayPos, float3(0,0,0),0.5,1.0 );

      // 法線と光の方向の内積からディフューズライティングを計算
      float differ = dot(normal, lightDir);

      // カラーを光とベースカラーで調整
      color = clamp(float3(differ) * baseColor, 0.1, 1.0);
      break;
    }

    // 衝突しなければ、レイをさらに進める
    cameraPos += ray * dist;
  }

  // フラグメントカラーとして返す（アルファは1.0）
  return half4(half3(color), 1.0);
}
