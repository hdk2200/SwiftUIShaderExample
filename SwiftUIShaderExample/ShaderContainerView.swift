import SwiftUI

struct ShaderContainerView: View {
  var shader: any ShaderRenderable

  @State private var hue: Double = 0.6
  @State private var intensity: Double = 0.8
  @State private var speed: Double = 1.0
  @State private var showControls: Bool = true
  private let startDate = Date()

  var body: some View {
    ZStack {
      TimelineView(.animation) { context in
        let time = (context.date.timeIntervalSince1970 - startDate.timeIntervalSince1970) * speed
        GeometryReader { proxy in
          Rectangle()
            .ignoresSafeArea()
            .foregroundColor(.clear)
            .border(Color.red.opacity(0.3))
            .layerEffect(
              shader.makeShader(time: time, size: proxy.size),
              maxSampleOffset: .zero
            )
        }
      }

      if showControls {
        VStack(alignment: .leading, spacing: 12) {
          HStack(alignment: .center) {
            Text(shader.name)
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

          shader.makeControls(speed: $speed, hue: $hue, intensity: $intensity)

        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
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
              Button(action: {
                withAnimation(.spring(response: 0.1, dampingFraction: 0.9)) {
                  showControls = true
                }
              }) {
                Label("Show Controls", systemImage: "slider.horizontal.3")
              }
              Button(action: {
                withAnimation(.spring(response: 0.1, dampingFraction: 0.9)) {
                  showControls = true
                }
              }) {
                Label("Show Controls", systemImage: "slider.horizontal.3")
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
    .ignoresSafeArea()
    .onAppear {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0.2)) {
        showControls = true
      }
    }
  }
}
