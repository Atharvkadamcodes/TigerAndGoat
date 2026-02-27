import SwiftUI

struct ActiveGameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: NavigationPath
    
    // Allows us to dismiss this view and go back
    @Environment(\.dismiss) private var dismiss
    
    let parchment = Color(red: 0.95, green: 0.92, blue: 0.85)
    let bronze = Color(red: 0.45, green: 0.35, blue: 0.20)
    let darkStone = Color(red: 0.15, green: 0.18, blue: 0.15)
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. TOP CONTROL BAR (Updated Circular Back Button)
            HStack {
                Button(action: {
                    dismiss() // Goes back to the setup menu
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(darkStone)
                        .frame(width: 44, height: 44) // Makes it a perfect square
                        .background(Color.white.opacity(0.7)) // Soft background
                        .clipShape(Circle()) // Clips it into a perfect circle
                }
                
                Spacer()
                
                if viewModel.config.allowUndo {
                    Button(action: viewModel.undoLastMove) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(darkStone)
                    }
                    .padding(.trailing, 10)
                }
                
                Button(action: viewModel.startGame) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(darkStone)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(parchment)
            
            // 2. Top Player Info
            PlayerInfoBar(name: viewModel.topPlayerName, role: viewModel.topPlayerRole, viewModel: viewModel, isTop: true)

            // 3. The Game Board Arena
            GeometryReader { geometry in
                let boardSize = min(geometry.size.width, geometry.size.height) * 0.95
                let pieceSize = boardSize * 0.065
                let nodeSize = boardSize * 0.035
                let tapTargetSize = boardSize * 0.10
                
                ZStack {
                    Path { path in
                        for node in viewModel.nodes {
                            let start = CGPoint(x: node.position.x * boardSize, y: node.position.y * boardSize)
                            for edge in node.edges {
                                if let targetNode = viewModel.nodes.first(where: { $0.id == edge.to }) {
                                    let end = CGPoint(x: targetNode.position.x * boardSize, y: targetNode.position.y * boardSize)
                                    path.move(to: start); path.addLine(to: end)
                                }
                            }
                        }
                    }.stroke(bronze, lineWidth: 3.0)
                    
                    ForEach(viewModel.nodes) { node in
                        let pos = CGPoint(x: node.position.x * boardSize, y: node.position.y * boardSize)
                        Circle().fill(parchment).overlay(Circle().stroke(bronze, lineWidth: 2)).frame(width: nodeSize, height: nodeSize).position(pos)
                        Circle().fill(Color.white.opacity(0.001)).frame(width: tapTargetSize, height: tapTargetSize).position(pos)
                            .onTapGesture { viewModel.handleNodeTap(nodeId: node.id) }
                        if viewModel.validMoves.contains(node.id) {
                            Circle().fill(Color.green.opacity(0.5)).frame(width: pieceSize, height: pieceSize).position(pos).allowsHitTesting(false)
                        }
                    }
                    
                    ForEach(viewModel.pieces) { piece in
                        if let node = viewModel.nodes.first(where: { $0.id == piece.nodeId }) {
                            let pos = CGPoint(x: node.position.x * boardSize, y: node.position.y * boardSize)
                            PieceView(type: piece.type, isSelected: viewModel.selectedPiece?.id == piece.id, size: pieceSize)
                                .position(pos).animation(.spring(response: 0.4, dampingFraction: 0.7), value: pos).allowsHitTesting(false)
                        }
                    }
                }
                .frame(width: boardSize, height: boardSize)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .background(LinearGradient(colors: [parchment, Color.white], startPoint: .top, endPoint: .bottom))
            
            // 4. Bottom Player Info
            PlayerInfoBar(name: viewModel.bottomPlayerName, role: viewModel.topPlayerRole == .goat ? .tiger : .goat, viewModel: viewModel, isTop: false)
        }
        .navigationBarBackButtonHidden(true) // Hides the default Apple back button gracefully
        .toolbar(.hidden, for: .navigationBar) // Ensures no empty white space at the top
        .overlay(
            Group {
                if viewModel.gameState == .tigerWon || viewModel.gameState == .goatWon {
                    VStack {
                        Text(viewModel.gameState == .tigerWon ? "TIGERS WIN!" : "GOATS WIN!")
                            .font(.largeTitle).fontWeight(.black).foregroundColor(viewModel.gameState == .tigerWon ? .red : .green)
                        Button("Play Again", action: viewModel.startGame).padding().background(Color.blue).foregroundColor(.white).cornerRadius(10)
                    }
                    .padding(40).background(.ultraThinMaterial).cornerRadius(20)
                }
            }
        )
    }
}

// MARK: - Subviews (These are the missing pieces!)
struct PlayerInfoBar: View {
    let name: String; let role: Player; @ObservedObject var viewModel: GameViewModel; let isTop: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name).font(.headline).foregroundColor(viewModel.currentPlayer == role ? .blue : .black)
                Text(role == .goat ? "Defender" : "Predator").font(.caption).foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing) {
                if role == .goat {
                    Text("Goats: \(viewModel.goatsPlaced)/\(viewModel.config.selectedBoard.goatCount)")
                } else {
                    Text("Killed: \(viewModel.goatsKilled)/\(viewModel.config.selectedBoard.tigerCount + 2)")
                        .foregroundColor(.red)
                }
            }.font(.subheadline).fontWeight(.bold)
        }
        .padding()
        .background(Color(red: 0.95, green: 0.92, blue: 0.85).opacity(isTop ? 1 : 0.8))
        .overlay(Rectangle().frame(height: 2).foregroundColor(Color.black.opacity(0.1)), alignment: isTop ? .bottom : .top)
    }
}

struct PieceView: View {
    let type: Player; let isSelected: Bool; let size: CGFloat
    var body: some View {
        ZStack {
            Circle().fill(type == .tiger ? Color.orange : Color(red: 0.3, green: 0.5, blue: 0.3))
                .frame(width: size, height: size).shadow(color: .black.opacity(0.3), radius: size * 0.1, x: 0, y: size * 0.08)
            Image(type == .tiger ? "tiger_piece" : "goat_piece").resizable().scaledToFit()
                .frame(width: size * 0.85, height: size * 0.85).clipShape(Circle())
            if isSelected {
                Circle().stroke(Color.blue, lineWidth: max(2, size * 0.08)).frame(width: size * 1.2, height: size * 1.2)
            }
        }
    }
}
