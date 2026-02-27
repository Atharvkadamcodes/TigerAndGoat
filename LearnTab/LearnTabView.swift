//
//  LearnTabView.swift
//  Tiger And Goat
//
//  Created by SDC-USER on 27/02/26.
//


import SwiftUI

struct LearnTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("About")) {
                    NavigationLink("App Significance", destination: Text("App Info"))
                    NavigationLink("Historical Significance", destination: Text("History Info"))
                }
                Section(header: Text("Rules & Strategy")) {
                    NavigationLink("How to Play", destination: Text("Rules Info"))
                    NavigationLink("Tracks & Movement", destination: Text("Tracks Info"))
                }
            }
            .navigationTitle("Learn")
        }
    }
}