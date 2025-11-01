import SwiftUI

protocol ShaderRenderable: Identifiable {
    var id: UUID { get }
    var name: String { get }
    func makeShader(time: Double, size: CGSize) -> Shader
    func makeControls(speed: Binding<Double>, hue: Binding<Double>, intensity: Binding<Double>) -> AnyView
}
//
//struct AnyShaderRenderable: Identifiable, ShaderRenderable {
//    let id: AnyHashable
//    let name: String
//    private let _makeShader: (Double, CGSize) -> Shader
//    private let _makeControls: (Binding<Double>, Binding<Double>, Binding<Double>) -> AnyView
//
//    init<T: ShaderRenderable & Identifiable>(_ shader: T) {
//        self.id = shader.id
//        self.name = shader.name
//        self._makeShader = shader.makeShader
//        self._makeControls = shader.makeControls
//    }
//
//    func makeShader(time: Double, size: CGSize) -> Shader { _makeShader(time, size) }
//    func makeControls(speed: Binding<Double>, hue: Binding<Double>, intensity: Binding<Double>) -> AnyView {
//        _makeControls(speed, hue, intensity)
//    }
//}



struct Gradient1Shader: ShaderRenderable {
    let id = UUID()
    let name = "Gradient 1"
    
    func makeShader(time: Double, size: CGSize) -> Shader {
//      print("make shader [\(name)]")
      return ShaderLibrary.fullscreenGradient(.float(Float(time)))
    }
    
    func makeControls(speed: Binding<Double>, hue: Binding<Double>, intensity: Binding<Double>) -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Hue")
                    Slider(value: hue, in: 0...1)
                }
                HStack {
                    Text("Intensity")
                    Slider(value: intensity, in: 0...1)
                }
            }
        )
    }
}

struct crosshairSDF: ShaderRenderable {
    let id = UUID()
    let name = "crosshairSDF"
    
    func makeShader(time: Double, size: CGSize) -> Shader {
//      print("make shader [\(name)]")
      return ShaderLibrary.crosshairSDF(
        .float(Float(time)),
        .float2(Float(size.width), Float(size.height))
        
      )
    }
    
    func makeControls(speed: Binding<Double>, hue: Binding<Double>, intensity: Binding<Double>) -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Hue")
                    Slider(value: hue, in: 0...1)
                }
                HStack {
                    Text("Intensity")
                    Slider(value: intensity, in: 0...1)
                }
            }
        )
    }
}

struct RayMarchShader1: ShaderRenderable {
    let id = UUID()
    let name = "RayMarching 01"
    
    func makeShader(time: Double, size: CGSize) -> Shader {
      print("make shader [\(name)] \(time) \(size)")
      return
        ShaderLibrary.rayMarching01(
            .float(Float(time)),
            .float2(Float(size.width), Float(size.height))
        )
    }
    
    func makeControls(speed: Binding<Double>, hue: Binding<Double>, intensity: Binding<Double>) -> AnyView {
        AnyView(
            HStack {
                Text("Speed ")
                Slider(value: speed, in: 0...3)
                Text("\(String(format:"%.2f",speed.wrappedValue))")
            }
        )
    }
}




struct RayMarchShader2: ShaderRenderable {
    let id = UUID()
    let name = "RayMarching 02"
    
    func makeShader(time: Double, size: CGSize) -> Shader {
      print("make shader [\(name)] \(time) \(size)")
      return
        ShaderLibrary.rayMarching02(
            .float(Float(time)),
            .float2(Float(size.width), Float(size.height))
        )
    }
    
    func makeControls(speed: Binding<Double>, hue: Binding<Double>, intensity: Binding<Double>) -> AnyView {
        AnyView(
            HStack {
                Text("Speed")
                Slider(value: speed, in: 0...3)
              Text("\(String(format:"%.2f",speed.wrappedValue))")
            }
        )
    }
}



struct RayMarchShader3: ShaderRenderable {
    let id = UUID()
    let name = "RayMarching 03"
    
    func makeShader(time: Double, size: CGSize) -> Shader {
      print("make shader [\(name)] \(time) \(size)")
      return
        ShaderLibrary.rayMarching03(
            .float(Float(time)),
            .float2(Float(size.width), Float(size.height))
        )
    }
    
    func makeControls(speed: Binding<Double>, hue: Binding<Double>, intensity: Binding<Double>) -> AnyView {
        AnyView(
            HStack {
                Text("Speed")
                Slider(value: speed, in: 0...3)
              Text("\(String(format:"%.2f",speed.wrappedValue))")

            }
        )
    }
}

struct RayMarchShader4: ShaderRenderable {
    let id = UUID()
    let name = "RayMarching 04"
    
    func makeShader(time: Double, size: CGSize) -> Shader {
//      print("make shader [\(name)]")
      return
        ShaderLibrary.rayMarching04(
            .float(Float(time)),
            .float2(Float(size.width), Float(size.height))
        )
    }
    
    func makeControls(speed: Binding<Double>, hue: Binding<Double>, intensity: Binding<Double>) -> AnyView {
        AnyView(
            HStack {
                Text("Speed")
                Slider(value: speed, in: 0...3)
              Text("\(String(format:"%.2f",speed.wrappedValue))")

            }
        )
    }
}

