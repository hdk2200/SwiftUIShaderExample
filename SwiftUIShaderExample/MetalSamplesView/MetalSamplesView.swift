import SwiftUI

struct MetalSamplesView: View {
    @State private var selectedShader: ShaderType = .sdf1
    @State private var fps: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            Picker("Shader", selection: $selectedShader) {
                ForEach(ShaderType.allCases) { shader in
                    Text(shader.name).tag(shader)
                }
            }
            .pickerStyle(.segmented)

            MTKViewRepresentable(fps: $fps, shaderType: selectedShader)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack {
                Text("FPS: \(Int(fps))")
                Spacer()
                Text("Shader: \(selectedShader.name)")
            }
            .font(.footnote)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Metal Samples")
    }
}

#Preview {
    NavigationStack {
        MetalSamplesView()
    }
}
