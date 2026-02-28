import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            PlayTabView()
                .tabItem {
                    Label("Play", systemImage: "gamecontroller.fill")
                }
            
            LearnTabView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
        }
        .accentColor(.mint)
    }
}
