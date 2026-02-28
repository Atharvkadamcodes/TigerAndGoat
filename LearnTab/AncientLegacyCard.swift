import SwiftUI

struct AncientLegacyCard: View {
    var body: some View {
        LearnCardView(
            imageName: "temple_carving2",
            title: "An Ancient Legacy",
            description: "Discover the centuries-old history etched into the stone floors of South Indian temples."
        )
    }
}

#Preview {
    AncientLegacyCard()
        .padding()
}
