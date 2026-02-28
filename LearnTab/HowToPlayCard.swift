import SwiftUI

struct HowToPlayCard: View {
    var body: some View {
        LearnCardView(
            imageName: "how_to_play_cover",
            title: "How to Play",
            description: "Learn the core rules, board variations, and how to master the hunt and the trap. Learn game from basics to mastery"
        )
    }
}

#Preview {
    HowToPlayCard()
        .padding()
}
