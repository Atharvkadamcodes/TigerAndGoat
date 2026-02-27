import SwiftUI

struct LearnCardView: View {
    // ADDED: Environment variable to check for iPad
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var imageName: String
    var title: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Image Section
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                // CHANGED: iPhone stays 140, iPad image stretches to 260 to make the card more square
                .frame(height: horizontalSizeClass == .compact ? 140 : 260)
                .clipped()
            
            // Bottom Text Section
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    // CHANGED: Slightly bigger font on iPad
                    .font(horizontalSizeClass == .compact ? .headline : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(description)
                    // CHANGED: Slightly bigger font on iPad
                    .font(horizontalSizeClass == .compact ? .subheadline : .body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // CHANGED: More padding inside the card on iPad
            .padding(horizontalSizeClass == .compact ? 16 : 24)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

#Preview {
    LearnCardView(
        imageName: "decisive_move",
        title: "Test Title",
        description: "This is a test description to see how the card looks in the preview."
    )
    .padding()
}
