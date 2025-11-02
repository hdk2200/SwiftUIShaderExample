import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Samples") {
                    NavigationLink("SwiftUI Modifier Sample") {
                        SwiftUIModifierSampleView()
                    }
                    NavigationLink("Metal Samples") {
                        MetalSamplesView()
                    }
                }
            }
            .navigationTitle("Main Menu")
        }
    }
}

#Preview {
    MainMenuView()
}
