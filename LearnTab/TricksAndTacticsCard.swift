import SwiftUI

struct TricksAndTacticsCard: View {
    var body: some View {
        LearnCardView(
            imageName: "tactics_cover",
            title: "Tricks & Tactics",
            description: "Master the art of the hunt and the power of the herd. Learn advanced strategies for both sides."
        )
    }
}

#Preview {
    TricksAndTacticsCard()
        .padding()
}
