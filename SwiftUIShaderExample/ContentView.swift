//
// Copyright (c) 2025, ___ORGANIZATIONNAME___ All rights reserved.
//
//

import SwiftUI

struct ContentView: View {
  enum ShaderType: String, CaseIterable, Identifiable {
    case gradient1 = "Gradient 1"
    case gradient2 = "Gradient 2"
    case crosshair = "Crosshair SDF"
    case raymarch1 = "RayMarching 01"
    case raymarch2 = "RayMarching 02"
    var id: String { rawValue }
  }

  @State private var time: Double = 0
  @State private var hue: Double = 0.6
  @State private var intensity: Double = 0.8
  @State private var speed: Double = 0.3
  @State private var selectedShader: ShaderType = .gradient1
  @State private var showControls: Bool = false
  private let startDate = Date()

  var body: some View {

    ZStack {
      // Fullscreen rectangle that uses a Metal shader

      TimelineView(.animation) { context in
        //            let t = context.date.timeIntervalSinceReferenceDate
        // Smooth time progression (can be scaled by speed)
        let animatedTime =
          (context.date.timeIntervalSince1970 - self.startDate.timeIntervalSince1970) * speed

        //            let animatedTime = t * speed
        GeometryReader { proxy in
          Rectangle()
            .ignoresSafeArea()
            .foregroundColor(.brown)
            .clipped(antialiased: true)
            .border(Color.green, width: 2)
            .layerEffect(
              {
                switch selectedShader {
                case .gradient1:
                  return ShaderLibrary.fullscreenGradient(
                    .float(animatedTime)
                  )
                case .gradient2:
                  return ShaderLibrary.fullscreenGradient2(
                    .float(animatedTime)
                  )
                case .crosshair:
                  return ShaderLibrary.crosshairSDF(
                    .float(animatedTime),
                    .float2(Float(proxy.size.width), Float(proxy.size.height))
                  )
                case .raymarch1:
                  return ShaderLibrary.rayMarching01(
                    .float(animatedTime),
                    .float2(Float(proxy.size.width), Float(proxy.size.height))
                  )
                case .raymarch2:
                  return ShaderLibrary.rayMarching02(
                    .float(animatedTime),
                    .float2(Float(proxy.size.width), Float(proxy.size.height))
                  )
                }
              }(),
              maxSampleOffset: .zero
            )
        }

      }
      // Simple controls overlay
      if showControls {
        VStack(alignment: .leading, spacing: 12) {
          HStack(alignment: .center) {
            Text("Metal Shader Sample")
              .font(.headline)
            Spacer()
            Button {
              withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                showControls = false
              }
            } label: {
              Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .padding(8)
                .background(.thinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
          }
          .padding(.bottom, 8)

          // Shader selector (segmented for clarity)
          Picker("Shader", selection: $selectedShader) {
            ForEach(ShaderType.allCases) { shader in
              Text(shader.rawValue).tag(shader)
            }
          }
          .pickerStyle(.segmented)

          // Per-shader controls
          Group {
            switch selectedShader {
            case .gradient1:
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Text("Hue")
                  Slider(value: $hue, in: 0...1)
                }
                HStack {
                  Text("Intensity")
                  Slider(value: $intensity, in: 0...1)
                }
              }
            case .gradient2:
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Text("Speed")
                  Slider(value: $speed, in: 0...2)
                }
              }
            case .crosshair:
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Text("Speed")
                  Slider(value: $speed, in: 0...2)
                }
              }
            case .raymarch1:
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Text("Speed")
                  Slider(value: $speed, in: 0...2)
                }
              }
            case .raymarch2:
              VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Text("Speed")
                  Slider(value: $speed, in: 0...2)
                }
              }
            }
          }

          //                        HStack {
          //                            Text("\(animatedTime)")
          //                        }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 2))
        .padding()
        .frame(maxWidth: 480)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }

      if !showControls {
        HStack { Spacer() }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
          .overlay(alignment: .bottomTrailing) {
            Menu {
              // Shader list section
              Section("Shaders") {
                ForEach(ShaderType.allCases) { shader in
                  Button(action: { selectedShader = shader }) {
                    Label(shader.rawValue, systemImage: selectedShader == shader ? "checkmark" : "")
                  }
                }
              }

              // Controls section
              Section("Controls") {
                Button(action: {
                  withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                    showControls = true
                  }
                }) {
                  Label("Show Controls", systemImage: "slider.horizontal.3")
                }
              }
            } label: {
              Image(systemName: "line.3.horizontal")
                .font(.system(size: 20, weight: .bold))
                .padding(14)
                .background(.ultraThinMaterial, in: Circle())
            }
            .menuStyle(.automatic)
            .padding(2)
          }
          .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .onAppear {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
        showControls = true
      }
    }
  }

}

#Preview {
  ContentView()
}
