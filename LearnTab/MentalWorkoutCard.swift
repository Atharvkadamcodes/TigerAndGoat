//
//  MentalWorkoutCard.swift
//  Tiger And Goat
//
//  Created by Atharv on 27/02/26.
//


import SwiftUI

struct MentalWorkoutCard: View {
    var body: some View {
        LearnCardView(
            imageName: "cognitive_development",
            title: "A Workout for the Mind",
            description: "Sharpen critical thinking, spatial awareness, and strategic foresight by mastering both attack and defense."
        )
    }
}

#Preview {
    MentalWorkoutCard()
        .padding()
}
