import SwiftUI

struct TricksAndTacticsDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.92, blue: 0.84).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .compact ? 50 : 100) {
                    
                    // MARK: - TIGER TACTICS HEADER
                    VStack(spacing: 16) {
                        Text("TIGER TACTICS")
                            .font(horizontalSizeClass == .compact ? .footnote : .headline)
                            .fontWeight(.black)
                            .tracking(4)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.orange))
                        
                        Text("The Art of the Hunt")
                            .font(horizontalSizeClass == .compact ? .title : .system(size: 48, weight: .bold))
                    }
                    .padding(.top, 40)
                    
                    // Tiger Content Sections
                    Group {
                        if horizontalSizeClass == .compact {
                            mobileTigerContent
                        } else {
                            ipadTigerContent
                        }
                    }

                    // Visual Separator
                    Divider()
                        .padding(.vertical, 40)
                    
                    // MARK: - GOAT TACTICS HEADER
                    VStack(spacing: 16) {
                        Text("GOAT TACTICS")
                            .font(horizontalSizeClass == .compact ? .footnote : .headline)
                            .fontWeight(.black)
                            .tracking(4)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.teal))
                        
                        Text("Power in Numbers")
                            .font(horizontalSizeClass == .compact ? .title : .system(size: 48, weight: .bold))
                    }
                    
                    // Goat Content Sections
                    Group {
                        if horizontalSizeClass == .compact {
                            mobileGoatContent
                        } else {
                            ipadGoatContent
                        }
                    }
                }
                .padding(.horizontal, horizontalSizeClass == .compact ? 24 : 80)
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(.all, edges: .leading) // Sidebar fix
        .navigationTitle("Tricks & Tactics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Layout Helpers
    
    private var ipadTigerContent: some View {
        VStack(spacing: 120) {
            HStack(alignment: .center, spacing: 80) {
                DetailText(title: "The Early Strike", text: "Don't wait. Try to capture goats during the 'drop phase' while they are still being placed on the board. An early lead makes it exponentially harder for the goats to form a complete trap later.")
                DetailImage(imageName: "early_strike_video")
            }
            HStack(alignment: .center, spacing: 80) {
                DetailImage(imageName: "central_command_diagram")
                DetailText(title: "Central Command", text: "Keep your tigers in the central intersections of the board where the lines cross in multiple directions. A tiger in the center has many escape routes, while a tiger on the edge is half-trapped.")
            }
        }
    }
    
    private var mobileTigerContent: some View {
        VStack(spacing: 48) {
            VStack(alignment: .leading, spacing: 20) {
                DetailImage(imageName: "early_strike_video")
                DetailText(title: "The Early Strike", text: "Don't wait. Try to capture goats during the 'drop phase' while they are still being placed on the board.")
            }
            VStack(alignment: .leading, spacing: 20) {
                DetailImage(imageName: "central_command_diagram")
                DetailText(title: "Central Command", text: "Keep your tigers in the central intersections. A tiger in the center has many escape routes.")
            }
        }
    }
    
    private var ipadGoatContent: some View {
        VStack(spacing: 120) {
            HStack(alignment: .center, spacing: 80) {
                DetailText(title: "The Iron Wall", text: "Goats are weak alone but invincible together. Build straight lines (walls) of goats, ensuring there is never an empty space directly behind a goat for a tiger to land on.")
                DetailImage(imageName: "iron_wall_diagram")
            }
            HStack(alignment: .center, spacing: 80) {
                DetailImage(imageName: "corner_trap_video")
                DetailText(title: "The Corner Trap", text: "Use your numbers to systematically push the tigers toward the sharp points of the triangle. Once a tiger is forced into a corner, its movement options are severely limited.")
            }
        }
    }
    
    private var mobileGoatContent: some View {
        VStack(spacing: 48) {
            VStack(alignment: .leading, spacing: 20) {
                DetailImage(imageName: "iron_wall_diagram")
                DetailText(title: "The Iron Wall", text: "Build straight lines (walls) of goats to prevent jumps.")
            }
            VStack(alignment: .leading, spacing: 20) {
                DetailImage(imageName: "corner_trap_video")
                DetailText(title: "The Corner Trap", text: "Push the tigers toward the sharp points of the triangle.")
            }
        }
    }
}
