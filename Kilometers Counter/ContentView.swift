import SwiftUI

struct ContentView: View {
    @State private var selectedFirstView = 0
    @State private var kmListed: [Int] = []
    
    var body: some View {
            TabView(selection: $selectedFirstView) {
                CentralView(kmList: $kmListed)
                    .tabItem {
                        Label("Viaggi", systemImage: "airplane")
                    }
                    .tag(0)
                
                SettingsScreen(kmListed: $kmListed)
                    .tabItem {
                        Label("Impostazioni", systemImage: "gear")
                    }
                    .tag(1)
            }
    }
}

#Preview{
    ContentView()
}
