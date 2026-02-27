//
//  HowToPlayCard.swift
//  Tiger And Goat
//
//  Created by Atharv on 28/02/26.
//


import SwiftUI

struct HowToPlayCard: View {
    var body: some View {
        LearnCardView(
            imageName: "how_to_play_cover", // We will add an image with this name to Assets soon
            title: "How to Play",
            description: "Learn the core rules, board variations, and how to master the hunt and the trap."
        )
    }
}

#Preview {
    HowToPlayCard()
        .padding()
}