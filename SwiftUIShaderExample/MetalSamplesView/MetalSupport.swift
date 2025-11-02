import Foundation
import MetalKit
import SwiftUI

// MARK: - ShaderType

enum ShaderType: String, CaseIterable, Identifiable {
    case sdf1
    case sdf2
    case sdf3
    case raymarching01
    case raymarching02
    case raymarching03
    case raymarching04
    case raymarching05
    case raymarching06

    var id: String { rawValue }

    var name: String {
        switch self {
        case .sdf1: return "SDF1"
        case .sdf2: return "SDF2"
        case .sdf3: return "SDF3"
        case .raymarching01: return "Raymarching 01"
        case .raymarching02: return "Raymarching 02"
        case .raymarching03: return "Raymarching 03"
        case .raymarching04: return "Raymarching 04"
        case .raymarching05: return "Raymarching 05"
        case .raymarching06: return "Raymarching 06"
        }
    }
}

// MARK: - MTKViewRepresentable

protocol MTKViewRendererDelegate: AnyObject {
    func renderer(_ renderer: MTKViewDelegate, didUpdateFPS fps: Double)
}

final class ShaderSampleRenderer: NSObject, MTKViewDelegate {
    weak var delegate: MTKViewRendererDelegate?
    var shaderType: ShaderType = .sdf1

    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!

    init(metalKitView: MTKView) {
        super.init()
        self.device = metalKitView.device
        self.commandQueue = device.makeCommandQueue()
        // NOTE: Placeholder setup. Replace with real pipeline/state setup as needed.
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle resize if needed
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        // Placeholder clear-only rendering. Integrate real shader pipelines by switching on shaderType.
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

        // Fake FPS reporting for now; in a real renderer, compute based on frame timing
        delegate?.renderer(self, didUpdateFPS: Double(view.preferredFramesPerSecond))
    }
}

struct MTKViewRepresentable: UIViewRepresentable {
    @Binding var fps: Double
    var shaderType: ShaderType
    var preferredFPS: Int = 60

    func makeUIView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.enableSetNeedsDisplay = false
        mtkView.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        mtkView.isPaused = false

        let renderer = ShaderSampleRenderer(metalKitView: mtkView)
        renderer.delegate = context.coordinator
        context.coordinator.renderer = renderer
        mtkView.delegate = renderer
        return mtkView
    }

    func updateUIView(_ mtkView: MTKView, context: Context) {
        mtkView.preferredFramesPerSecond = preferredFPS
        context.coordinator.renderer?.shaderType = shaderType
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MTKViewRendererDelegate {
        let parent: MTKViewRepresentable
        var renderer: ShaderSampleRenderer?

        init(_ parent: MTKViewRepresentable) {
            self.parent = parent
        }

        func renderer(_ renderer: MTKViewDelegate, didUpdateFPS fps: Double) {
            parent.fps = fps
        }
    }
}
