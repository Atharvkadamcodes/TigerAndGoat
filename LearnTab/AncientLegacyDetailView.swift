import SwiftUI

struct AncientLegacyDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.92, blue: 0.84).ignoresSafeArea()
            
            ScrollView {
                // Responsive vertical spacing based on device size
                VStack(spacing: horizontalSizeClass == .compact ? 40 : 100) {
                    
                    // MARK: - iPhone Layout (Stacked)
                    if horizontalSizeClass == .compact {
                        VStack(spacing: 32) {
                            // Section 1: Etched in History (The "When")
                            VStack(alignment: .leading, spacing: 16) {
                                DetailImage(imageName: "temple_carving") // Make sure this matches your asset name
                                DetailText(
                                    title: "Origins Etched in Stone",
                                    text: "While the exact date of its creation is lost to time, historians believe Aadupuli Aatam was developed well over a thousand years ago, flourishing during the era of great South Indian empires like the Cholas. The most prominent evidence of its age lies in ancient temples across Tamil Nadu and Karnataka, such as the Chamundeshwari Temple in Mysore, where game boards are found permanently carved into the stone flooring. These carvings suggest the game was a respected intellectual pursuit for pilgrims and royals alike."
                                )
                            }
                            
                            // Section 2: A Living Tradition (The "Why")
                            VStack(alignment: .leading, spacing: 16) {
                                DetailImage(imageName: "traditional_gameplay") // Make sure this matches your asset name
                                DetailText(
                                    title: "Designed with a Purpose",
                                    text: "Aadupuli Aatam was not created merely for entertainment; it was designed as a martial and philosophical teaching tool. For ancient warriors, it simulated battlefield tactics, teaching them how to strategically corner a powerful enemy or survive against overwhelming numbers. For the common people, it was traditionally drawn on the dirt and played with pebbles, passing down a vital societal lesson: that ordinary individuals (the goats), when united and coordinated, can overcome a much stronger, predatory force (the tiger)."
                                )
                            }
                        }
                    }
                    // MARK: - iPad Layout (Alternating Z-Pattern)
                    else {
                        VStack(spacing: 120) {
                            // Row 1: Text Left, Image Right
                            HStack(alignment: .center, spacing: 80) {
                                DetailText(
                                    title: "Origins Etched in Stone",
                                    text: "While the exact date of its creation is lost to time, historians believe Aadupuli Aatam was developed well over a thousand years ago, flourishing during the era of great South Indian empires like the Cholas. The most prominent evidence of its age lies in ancient temples across Tamil Nadu and Karnataka, such as the Chamundeshwari Temple in Mysore, where game boards are found permanently carved into the stone flooring. These carvings suggest the game was a respected intellectual pursuit for pilgrims and royals alike."
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                DetailImage(imageName: "temple_carving")
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Row 2: Image Left, Text Right
                            HStack(alignment: .center, spacing: 80) {
                                DetailImage(imageName: "traditional_gameplay")
                                    .frame(maxWidth: .infinity)
                                
                                DetailText(
                                    title: "Designed with a Purpose",
                                    text: "Aadupuli Aatam was not created merely for entertainment; it was designed as a martial and philosophical teaching tool. For ancient warriors, it simulated battlefield tactics, teaching them how to strategically corner a powerful enemy or survive against overwhelming numbers. For the common people, it was traditionally drawn on the dirt and played with pebbles, passing down a vital societal lesson: that ordinary individuals (the goats), when united and coordinated, can overcome a much stronger, predatory force (the tiger)."
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                // Responsive padding around the edges
                .padding(.horizontal, horizontalSizeClass == .compact ? 24 : 80)
                .padding(.vertical, horizontalSizeClass == .compact ? 24 : 60)
            }
        }
        .ignoresSafeArea(.all, edges: .leading) // Sidebar fix
        .navigationTitle("An Ancient Legacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AncientLegacyDetailView()
    }
}
