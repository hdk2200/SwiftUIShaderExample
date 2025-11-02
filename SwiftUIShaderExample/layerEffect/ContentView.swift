//
// Copyright (c) 2025, ___ORGANIZATIONNAME___ All rights reserved.
//
//

import SwiftUI

struct ContentView: View {
  @State private var selectedShader: any ShaderRenderable = RayMarchShader1()

  private let shaders: [any ShaderRenderable] = [
    Gradient1Shader(),
    crosshairSDF(),
    RayMarchShader1(),
    RayMarchShader2(),
    RayMarchShader3(),
    RayMarchShader4(),
  ]

  var body: some View {
    VStack(spacing: 0) {
      ShaderContainerView(shader: selectedShader)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

      Divider()
      
      // Grid selection for shaders
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(shaders, id: \.id) { shader in
            let isSelected = (shader.name == selectedShader.name)

            Button(action: { selectedShader = shader }) {
              Text(shader.name)
                .font(.callout)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                  RoundedRectangle(cornerRadius: 8)
                    .fill(
                      isSelected
                        ? Color.accentColor.opacity(0.2)  // 選択時の背景色
                        : Color(.systemBackground)  // 通常背景

                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
            }
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                //                              .fill( (selectedShader.id == shader.id) ? Color.accentColor.opacity(0.1) : Color.secondary)
                .stroke(
                  (selectedShader.id == shader.id)
                    ? Color.accentColor : Color.secondary.opacity(0.4),
                  lineWidth: 1
                )
            )
          }
        }
        .padding(12)
      }
      .background(.thinMaterial)
    }
  }
}

#Preview {
  ContentView()
}
