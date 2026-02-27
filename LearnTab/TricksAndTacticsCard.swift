//
//  TricksAndTacticsCard.swift
//  Tiger And Goat
//
//  Created by Atharv on 28/02/26.
//


import SwiftUI

struct TricksAndTacticsCard: View {
    var body: some View {
        LearnCardView(
            imageName: "tactics_cover", // Add a cover image to your Assets
            title: "Tricks & Tactics",
            description: "Master the art of the hunt and the power of the herd. Learn advanced strategies for both sides."
        )
    }
}

#Preview {
    TricksAndTacticsCard()
        .padding()
}