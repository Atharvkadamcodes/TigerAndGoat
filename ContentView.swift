import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
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
        } else {
            NavigationSplitView {
                List {
                    NavigationLink(destination: PlayTabView()) {
                        Label("Play", systemImage: "gamecontroller.fill")
                    }
                    NavigationLink(destination: LearnTabView()) {
                        Label("Learn", systemImage: "book.fill")
                    }
                }
                .navigationTitle("Aadu Puli Aatam")
            } detail: {
                PlayTabView()
            }
            .accentColor(.mint)
        }
    }
}
