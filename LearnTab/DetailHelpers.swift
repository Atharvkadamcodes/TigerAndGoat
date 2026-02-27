//
//  DetailImage.swift
//  Tiger And Goat
//
//  Created by Atharv on 28/02/26.
//


import SwiftUI

struct DetailImage: View {
    var imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .cornerRadius(20) // Slightly larger corner radius for a premium look
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

struct DetailText: View {
    var title: String
    var text: String
    
    // Check if we are on iPad or iPhone
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .compact ? 12 : 24) {
            Text(title)
                // INCREASED: iPad title size is now 44
                .font(horizontalSizeClass == .compact ? .title : .system(size: 44, weight: .bold))
                .foregroundColor(.primary)
            
            Text(text)
                // INCREASED: iPad body size is now 24
                .font(horizontalSizeClass == .compact ? .body : .system(size: 24, weight: .regular))
                .foregroundColor(.secondary)
                // INCREASED: Line spacing for better readability
                .lineSpacing(horizontalSizeClass == .compact ? 4 : 12)
        }
    }
}
