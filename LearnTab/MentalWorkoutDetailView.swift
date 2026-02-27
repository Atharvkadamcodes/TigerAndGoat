import SwiftUI

struct MentalWorkoutDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            // Added warm background
            Color(red: 0.98, green: 0.92, blue: 0.84).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .compact ? 40 : 80) {
                    
                    // MARK: - iPhone Layout (Stacked)
                    if horizontalSizeClass == .compact {
                        VStack(spacing: 32) {
                            VStack(alignment: .leading, spacing: 16) {
                                DetailImage(imageName: "cognitive_development2")
                                DetailText(
                                    title: "Cognitive Development",
                                    text: "Aadupuli Aatam is more than just a traditional pastime; it is a powerful tool for cognitive development and mental conditioning. Playing this highly tactical, asymmetrical game actively sharpens critical thinking, spatial awareness, and long-term strategic foresight. Players must constantly analyze the board for geometric patterns, anticipate their opponent's multi-step plans, and calculate risks before making a move. It serves as an excellent way to train the brain to solve complex, dynamic puzzles under pressure."
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                DetailImage(imageName: "two_mindsets")
                                DetailText(
                                    title: "Two Different Mindsets",
                                    text: "What makes this game truly unique is how it forces players to adapt to two completely opposing cognitive mindsets. Playing as the Tigers hones opportunistic tactics, aggressive problem-solving, and the ability to strike quickly when a vulnerability appears. You must think like a solitary, powerful hunter. Conversely, playing as the Goats teaches the immense power of unity, patience, and defensive positioning. You learn that a coordinated team, willing to make strategic sacrifices, can encircle and completely neutralize a much stronger force through pure synergy and collective strategy."
                                )
                            }
                        }
                    }
                    // MARK: - iPad Layout (Alternating Z-Pattern)
                    else {
                        VStack(spacing: 100) {
                            // Row 1
                            HStack(alignment: .center, spacing: 60) {
                                DetailText(
                                    title: "Cognitive Development",
                                    text: "Aadupuli Aatam is more than just a traditional pastime; it is a powerful tool for cognitive development and mental conditioning. Playing this highly tactical, asymmetrical game actively sharpens critical thinking, spatial awareness, and long-term strategic foresight. Players must constantly analyze the board for geometric patterns, anticipate their opponent's multi-step plans, and calculate risks before making a move. It serves as an excellent way to train the brain to solve complex, dynamic puzzles under pressure."
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                DetailImage(imageName: "cognitive_development2")
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Row 2
                            HStack(alignment: .center, spacing: 60) {
                                DetailImage(imageName: "two_mindsets")
                                    .frame(maxWidth: .infinity)
                                
                                DetailText(
                                    title: "Two Different Mindsets",
                                    text: "What makes this game truly unique is how it forces players to adapt to two completely opposing cognitive mindsets. Playing as the Tigers hones opportunistic tactics, aggressive problem-solving, and the ability to strike quickly when a vulnerability appears. You must think like a solitary, powerful hunter. Conversely, playing as the Goats teaches the immense power of unity, patience, and defensive positioning. You learn that a coordinated team, willing to make strategic sacrifices, can encircle and completely neutralize a much stronger force through pure synergy and collective strategy."
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalSizeClass == .compact ? 24 : 80)
                .padding(.vertical, horizontalSizeClass == .compact ? 24 : 60)
            }
        }
        .ignoresSafeArea(.all, edges: .leading) // Stops the sidebar from squishing the page
        .navigationTitle("A Workout for the Mind")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MentalWorkoutDetailView()
    }
}
