import SwiftUI

struct LearnTabView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // CHANGED: This adaptive grid automatically switches to 1 column when the sidebar opens!
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 320), spacing: 24)]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: horizontalSizeClass == .compact ? 24 : 100) {
                    
                    // MARK: - About Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("About")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 24) {
                            // First Card Link
                            NavigationLink(destination: MentalWorkoutDetailView()) {
                                MentalWorkoutCard()
                            }
                            .buttonStyle(.plain)
                            
                            // Second Card Link
                            NavigationLink(destination: AncientLegacyDetailView()) {
                                AncientLegacyCard()
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Rules & Strategy Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Rules & Strategy")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 24) {
                            
                            // First Card: How to Play
                            NavigationLink(destination: HowToPlayDetailView()) {
                                HowToPlayCard()
                            }
                            .buttonStyle(.plain)
                            
                            // Second Card: Tricks & Tactics
                            NavigationLink(destination: TricksAndTacticsDetailView()) {
                                TricksAndTacticsCard()
                            }
                            .buttonStyle(.plain)
                            
                        }
                        .padding(.horizontal)
                    }
                    
                }
                .padding(.vertical, horizontalSizeClass == .compact ? 24 : 60)
            }
            .ignoresSafeArea(.all, edges: .leading) // <--- ADD THIS LINE HERE
                        .background(Color(red: 0.98, green: 0.92, blue: 0.84).ignoresSafeArea())
                        .navigationTitle("Learn")
        }
    }
}

#Preview {
    LearnTabView()
}
