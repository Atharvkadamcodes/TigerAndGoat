import SwiftUI

struct AncientLegacyDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.92, blue: 0.84).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .compact ? 40 : 80) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        DetailImage(imageName: "temple_carving")
                        DetailText(
                            title: "Origins Etched in Stone",
                            text: "While the exact date of its creation is lost to time, historians believe Aadupuli Aatam was developed well over a thousand years ago, flourishing during the era of great South Indian empires like the Cholas. The most prominent evidence of its age lies in ancient temples across Tamil Nadu and Karnataka, such as the Chamundeshwari Temple in Mysore, where game boards are found permanently carved into the stone flooring. These carvings suggest the game was a respected intellectual pursuit for pilgrims and royals alike."
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        DetailImage(imageName: "traditional_gameplay")
                        DetailText(
                            title: "Designed with a Purpose",
                            text: "Aadupuli Aatam was not created merely for entertainment; it was designed as a martial and philosophical teaching tool. For ancient warriors, it simulated battlefield tactics, teaching them how to strategically corner a powerful enemy or survive against overwhelming numbers. For the common people, it was traditionally drawn on the dirt and played with pebbles, passing down a vital societal lesson: that ordinary individuals (the goats), when united and coordinated, can overcome a much stronger, predatory force (the tiger)."
                        )
                    }
                }
                .frame(maxWidth: 800) // Apple standard readable width for iPad/Mac
                .padding(.horizontal, horizontalSizeClass == .compact ? 24 : 60)
                .padding(.vertical, horizontalSizeClass == .compact ? 24 : 60)
            }
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        AncientLegacyDetailView()
    }
}
