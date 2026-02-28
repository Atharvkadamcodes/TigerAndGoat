import SwiftUI

struct HowToPlayDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.92, blue: 0.84).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .compact ? 50 : 100) {
                    
                
                    if horizontalSizeClass == .compact {
                        VStack(spacing: 40) {
                            
                         
                            VStack(spacing: 32) {
                                VStack(alignment: .center, spacing: 16) {
                                    CircularDetailImage(imageName: "tiger_piece")
                                    DetailText(title: "The Hunters", text: "Depending on the board variation you choose, you will command a small elite force of 1, 3, or 5 Tigers. Your ultimate objective is to hunt down and capture enough goats to secure dominance over the board.")
                                }
                                
                                VStack(alignment: .center, spacing: 16) {
                                    CircularDetailImage(imageName: "goat_piece")
                                    DetailText(title: "The Defenders", text: "You command a larger herd, typically 15 goats (when facing 3 tigers). You start with no pieces on the board and must carefully place them one by one during the 'drop phase'. Your objective is to survive and build a trap.")
                                }
                            }
                            
                            Divider().padding(.vertical, 10)
                            
                       
                            VStack(spacing: 40) {
                             
                                VStack(alignment: .center, spacing: 20) {
                                    TabView {
                                        VideoPlayerView(videoName: "tiger1", videoExtension: "mp4")
                                        VideoPlayerView(videoName: "tiger2", videoExtension: "mp4")
                                    }
                                    .tabViewStyle(.page(indexDisplayMode: .always))
                                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                                    .frame(width: 240, height: 360)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(radius: 8)
                                    
                                    DetailText(title: "Tiger Mechanics", text: "Tigers can move one step along any connected line to an adjacent empty point. To capture, a Tiger must jump over a single Goat in a straight line, landing on an empty point immediately behind it. The captured goat is removed from the game.")
                                }
                                
                              
                                VStack(alignment: .center, spacing: 20) {
                                    VideoPlayerView(videoName: "video2", videoExtension: "mp4")
                                        .frame(width: 240, height: 360)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(radius: 8)
                                    
                                    DetailText(title: "Goat Mechanics", text: "Once all goats are placed on the board, they can move one step along a connected line to an adjacent empty point. Goats cannot jump or capture. Your only weapon is unity: you must coordinate your herd to block the Tigers' paths and trap them so they cannot make a legal move.")
                                }
                            }
                        }
                    }
             
                    else {
                        VStack(spacing: 120) {
                            
                            // Row 1
                            HStack(alignment: .center, spacing: 80) {
                                DetailText(title: "The Hunters", text: "Depending on the board variation you choose, you will command a small elite force of 1, 3, or 5 Tigers. Your ultimate objective is to hunt down and capture enough goats to secure dominance over the board.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                CircularDetailImage(imageName: "tiger_piece")
                            }
                            
                            // Row 2
                            HStack(alignment: .center, spacing: 80) {
                                CircularDetailImage(imageName: "goat_piece")
                                DetailText(title: "The Defenders", text: "You command a larger herd, typically 15 goats (when facing 3 tigers). You start with no pieces on the board and must carefully place them one by one during the 'drop phase'. Your objective is to survive and build a trap.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Divider().padding(.vertical, 20)
                            
                            // Row 3: Tiger Video Carousel Right
                            HStack(alignment: .center, spacing: 80) {
                                DetailText(title: "Tiger Mechanics", text: "Tigers can move one step along any connected line to an adjacent empty point. To capture, a Tiger must jump over a single Goat in a straight line, landing on an empty point immediately behind it. The captured goat is removed from the game.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TabView {
                                    VideoPlayerView(videoName: "tiger1", videoExtension: "mp4")
                                    VideoPlayerView(videoName: "tiger2", videoExtension: "mp4")
                                }
                                .tabViewStyle(.page(indexDisplayMode: .always))
                                .indexViewStyle(.page(backgroundDisplayMode: .always))
                                .frame(width: 320, height: 480)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 10)
                            }
                            
                 
                            HStack(alignment: .center, spacing: 80) {
                                VideoPlayerView(videoName: "video2", videoExtension: "mp4")
                                    .frame(width: 320, height: 480)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(radius: 10)
                                
                                DetailText(title: "Goat Mechanics", text: "Once all goats are placed on the board, they can move one step along a connected line to an adjacent empty point. Goats cannot jump or capture. Your only weapon is unity: you must coordinate your herd to block the Tigers' paths and trap them so they cannot make a legal move.")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalSizeClass == .compact ? 24 : 80)
                .padding(.vertical, horizontalSizeClass == .compact ? 24 : 60)
            }
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct CircularDetailImage: View {
    var imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .padding(30)
            .frame(width: 300, height: 300)
            .background(Color.teal.opacity(0.1))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.teal.opacity(0.3), lineWidth: 3))
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}
