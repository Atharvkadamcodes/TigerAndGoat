import SwiftUI

struct LearnTabView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var columns: [GridItem] {
        if horizontalSizeClass == .compact {
            return [GridItem(.flexible())]
        } else {
            return [
                GridItem(.flexible(), spacing: 24),
                GridItem(.flexible(), spacing: 24)
            ]
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: horizontalSizeClass == .compact ? 32 : 60) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("About")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                        
                        LazyVGrid(columns: columns, spacing: 24) {
                            NavigationLink(destination: MentalWorkoutDetailView()) {
                                MentalWorkoutCard()
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink(destination: AncientLegacyDetailView()) {
                                AncientLegacyCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, horizontalSizeClass == .compact ? 20 : 40)
                    
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Rules & Strategy")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                        
                        LazyVGrid(columns: columns, spacing: 24) {
                            NavigationLink(destination: HowToPlayDetailView()) {
                                HowToPlayCard()
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink(destination: TricksAndTacticsDetailView()) {
                                TricksAndTacticsCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, horizontalSizeClass == .compact ? 20 : 40)
                    
                }
                .padding(.vertical, horizontalSizeClass == .compact ? 24 : 40)
            }
            // FIX: Removed .ignoresSafeArea(.all, edges: .leading)
            .background(Color(red: 0.98, green: 0.92, blue: 0.84).ignoresSafeArea())
            .navigationTitle("Learn")
        }
    }
}

#Preview {
    LearnTabView()
}
