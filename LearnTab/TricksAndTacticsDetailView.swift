import SwiftUI

struct TricksAndTacticsDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.92, blue: 0.84).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .compact ? 50 : 100) {
                    
             
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
                    
             
                    Group {
                        if horizontalSizeClass == .compact {
                            mobileTigerContent
                        } else {
                            ipadTigerContent
                        }
                    }

                 
                    Divider()
                        .padding(.vertical, 40)
                    
                  
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
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
 
    
    private var ipadTigerContent: some View {
        VStack(spacing: 120) {
            HStack(alignment: .center, spacing: 80) {
                DetailText(title: "The Early Strike", text: "Don't wait. Try to capture goats during the 'drop phase' while they are still being placed on the board. An early lead makes it exponentially harder for the goats to form a complete trap later.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VideoPlayerView(videoName: "tiger2", videoExtension: "mp4")
                    .frame(width: 320, height: 480)
                    .clipShape(RoundedRectangle(cornerRadius: 12)) 
                    .shadow(radius: 10)
            }
            HStack(alignment: .center, spacing: 80) {
                VideoPlayerView(videoName: "video3", videoExtension: "mp4")
                    .frame(width: 320, height: 480)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 10)
                
                DetailText(title: "Central Command", text: "Keep your tigers in the central intersections of the board where the lines cross in multiple directions. A tiger in the center has many escape routes, while a tiger on the edge is half-trapped.")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var mobileTigerContent: some View {
        VStack(spacing: 48) {
            VStack(alignment: .center, spacing: 20) {
                VideoPlayerView(videoName: "tiger2", videoExtension: "mp4")
                    .frame(width: 240, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
                
                DetailText(title: "The Early Strike", text: "Don't wait. Try to capture goats during the 'drop phase' while they are still being placed on the board.")
            }
            VStack(alignment: .center, spacing: 20) {
                VideoPlayerView(videoName: "video3", videoExtension: "mp4")
                    .frame(width: 240, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
                
                DetailText(title: "Central Command", text: "Keep your tigers in the central intersections. A tiger in the center has many escape routes.")
            }
        }
    }
    
    private var ipadGoatContent: some View {
        VStack(spacing: 120) {
            HStack(alignment: .center, spacing: 80) {
                DetailText(title: "The Iron Wall", text: "Goats are weak alone but invincible together. Build straight lines (walls) of goats, ensuring there is never an empty space directly behind a goat for a tiger to land on.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VideoPlayerView(videoName: "video4", videoExtension: "mp4")
                    .frame(width: 320, height: 480)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 10)
            }
            HStack(alignment: .center, spacing: 80) {
                VideoPlayerView(videoName: "video1", videoExtension: "mp4")
                    .frame(width: 320, height: 480)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 10)
                
                DetailText(title: "The Corner Trap", text: "Use your numbers to systematically push the tigers toward the sharp points of the triangle. Once a tiger is forced into a corner, its movement options are severely limited.")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var mobileGoatContent: some View {
        VStack(spacing: 48) {
            VStack(alignment: .center, spacing: 20) {
                VideoPlayerView(videoName: "video4", videoExtension: "mp4")
                    .frame(width: 240, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
                
                DetailText(title: "The Iron Wall", text: "Build straight lines (walls) of goats to prevent jumps.")
            }
            VStack(alignment: .center, spacing: 20) {
                VideoPlayerView(videoName: "video1", videoExtension: "mp4")
                    .frame(width: 240, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
                
                DetailText(title: "The Corner Trap", text: "Push the tigers toward the sharp points of the triangle.")
            }
        }
    }
}
