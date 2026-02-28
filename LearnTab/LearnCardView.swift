import SwiftUI

struct LearnCardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var imageName: String
    var title: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
          
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: horizontalSizeClass == .compact ? 140 : 200)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(horizontalSizeClass == .compact ? .headline : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(description)
                    .font(horizontalSizeClass == .compact ? .subheadline : .body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(horizontalSizeClass == .compact ? 16 : 24)
            .frame(maxWidth: .infinity, alignment: .leading)
           
        }
       
        .background(Color(UIColor.secondarySystemGroupedBackground).opacity(0.7))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
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
