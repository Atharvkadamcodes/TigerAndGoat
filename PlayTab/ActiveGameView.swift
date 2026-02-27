import SwiftUI

struct ActiveGameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: NavigationPath
    @Environment(\.dismiss) private var dismiss
    
    // ADDED: State variable to control the restart alert
    @State private var showingRestartAlert = false
    
    let parchment = Color(red: 0.95, green: 0.92, blue: 0.85)
    let bronze = Color(red: 0.45, green: 0.35, blue: 0.20)
    let darkStone = Color(red: 0.15, green: 0.18, blue: 0.15)
    
    var body: some View {
        ZStack {
            // MARK: - MAIN GAME LAYER
            VStack(spacing: 0) {
                // 1. TOP CONTROL BAR
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .foregroundColor(darkStone)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
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
                    
                    // CHANGED: Now triggers the alert instead of instantly restarting
                    Button(action: { showingRestartAlert = true }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(darkStone)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(parchment)
                
                // 2. PLAYER INFO BARS
                PlayerInfoBar(role: viewModel.topPlayerRole, viewModel: viewModel, isTop: true)

                // 3. THE GAME BOARD
                GeometryReader { geometry in
                    let boardSize = min(geometry.size.width, geometry.size.height) * 0.95
                    let pieceSize = boardSize * 0.065
                    let nodeSize = boardSize * 0.035
                    
                    ZStack {
                        // Board Lines
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
                        
                        // Nodes
                        ForEach(viewModel.nodes) { node in
                            let pos = CGPoint(x: node.position.x * boardSize, y: node.position.y * boardSize)
                            Circle().fill(parchment).overlay(Circle().stroke(bronze, lineWidth: 2)).frame(width: nodeSize, height: nodeSize).position(pos)
                            Circle().fill(Color.white.opacity(0.001)).frame(width: 44, height: 44).position(pos)
                                .onTapGesture { viewModel.handleNodeTap(nodeId: node.id) }
                            if viewModel.validMoves.contains(node.id) {
                                Circle().fill(Color.green.opacity(0.5)).frame(width: pieceSize, height: pieceSize).position(pos).allowsHitTesting(false)
                            }
                        }
                        
                        // Pieces
                        ForEach(viewModel.pieces) { piece in
                            if let node = viewModel.nodes.first(where: { $0.id == piece.nodeId }) {
                                let pos = CGPoint(x: node.position.x * boardSize, y: node.position.y * boardSize)
                                
                                // ADDED: Check if this specific piece is trapped
                                let isTrapped = viewModel.isPieceTrapped(piece)
                                
                                // CHANGED: Pass isTrapped to the PieceView
                                PieceView(type: piece.type, isSelected: viewModel.selectedPiece?.id == piece.id, isTrapped: isTrapped, size: pieceSize)
                                    .position(pos).animation(.spring(response: 0.4, dampingFraction: 0.7), value: pos).allowsHitTesting(false)
                            }
                        }
                    }
                    .frame(width: boardSize, height: boardSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .background(LinearGradient(colors: [parchment, Color.white], startPoint: .top, endPoint: .bottom))
                
                PlayerInfoBar(role: viewModel.topPlayerRole == .goat ? .tiger : .goat, viewModel: viewModel, isTop: false)
            }
            .blur(radius: isGameOver ? 8 : 0) // Soft blur for the victory layer
            
            // MARK: - PREMIUM VICTORY POPUP
            if isGameOver {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Animated Winner Icon
                    ZStack {
                        Circle()
                            .fill(viewModel.gameState == .tigerWon ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                            .frame(width: 140, height: 140)
                        
                        Image(viewModel.gameState == .tigerWon ? "tiger_piece" : "goat_piece")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 10)
                    }
                    .scaleEffect(1.1)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5).repeatForever(autoreverses: true), value: isGameOver)

                    VStack(spacing: 12) {
                        Text(viewModel.gameState == .tigerWon ? "THE HUNTERS PREVAIL" : "THE DEFENDERS TRIUMPH")
                            .font(.caption)
                            .fontWeight(.black)
                            .tracking(3)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.gameState == .tigerWon ? "TIGERS WIN!" : "GOATS WIN!")
                            .font(.system(size: 48, weight: .black, design: .serif))
                            .foregroundColor(viewModel.gameState == .tigerWon ? .red : .green)
                    }

                    VStack(spacing: 16) {
                        Button(action: { viewModel.startGame() }) {
                            Text("PLAY AGAIN")
                                .font(.headline).fontWeight(.black)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 60)
                                .background(Capsule().fill(Color.orange))
                                .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                        }
                        
                        Button(action: { path = NavigationPath() }) {
                            Text("BACK TO HOME")
                                .font(.subheadline).fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.vertical, 50)
                .background(RoundedRectangle(cornerRadius: 40).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.white.opacity(0.5), lineWidth: 1))
                .padding(30)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
            }
        }
        .ignoresSafeArea(.all, edges: .leading)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.gameState)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        // ADDED: The confirmation alert
        .alert("Restart Match?", isPresented: $showingRestartAlert) {
            Button("Restart", role: .destructive) {
                viewModel.startGame()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to restart? All current progress will be lost.")
        }
    }

    private var isGameOver: Bool {
        viewModel.gameState == .tigerWon || viewModel.gameState == .goatWon
    }
}

// MARK: - THEMATIC PLAYER INFO BAR
struct PlayerInfoBar: View {
    let role: Player
    @ObservedObject var viewModel: GameViewModel
    let isTop: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let parchment = Color(red: 0.95, green: 0.92, blue: 0.85)
    let bronze = Color(red: 0.45, green: 0.35, blue: 0.20)
    let darkStone = Color(red: 0.15, green: 0.18, blue: 0.15)

    var body: some View {
        HStack(spacing: horizontalSizeClass == .compact ? 12 : 24) {
            // Piece Avatar
            ZStack {
                Circle()
                    .fill(role == .tiger ? Color.orange : Color(red: 0.3, green: 0.5, blue: 0.3))
                    .frame(width: 50, height: 50)
                
                Image(role == .tiger ? "tiger_piece" : "goat_piece")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .clipShape(Circle())
            }
            .overlay(Circle().stroke(bronze.opacity(0.3), lineWidth: 2))
            .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(role == .tiger ? "THE HUNTERS" : "THE DEFENDERS")
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundColor(role == .tiger ? .red : .green)
                
                Text(isTop ? viewModel.topPlayerName : viewModel.bottomPlayerName)
                    .font(.headline)
                    .foregroundColor(darkStone)
            }
            
            Spacer()
            
            // Numerical Scoring
            VStack(alignment: .trailing, spacing: 2) {
                Text(role == .goat ? "STRENGTH" : "KILLS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(bronze.opacity(0.8))
                
                Text(role == .goat ? "\(viewModel.goatsPlaced)/\(viewModel.config.selectedBoard.goatCount)" : "\(viewModel.goatsKilled)/\(viewModel.config.selectedBoard.tigerCount + 2)")
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(role == .tiger ? .red : darkStone)
            }
        }
        .padding(.horizontal)
        .background(parchment.opacity(isTop ? 1 : 0.8))
        .overlay(Rectangle().frame(height: 1).foregroundColor(bronze.opacity(0.2)), alignment: isTop ? .bottom : .top)
    }
}

// MARK: - PREMIUM PIECE VIEW
struct PieceView: View {
    let type: Player
    let isSelected: Bool
    var isTrapped: Bool = false // ADDED: Defaults to false
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(type == .tiger ? Color.orange : Color(red: 0.3, green: 0.5, blue: 0.3))
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.3), radius: size * 0.1, y: size * 0.05)
            
            Image(type == .tiger ? "tiger_piece" : "goat_piece")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.85)
                .clipShape(Circle())
            
            if isSelected {
                Circle()
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(width: size * 1.2)
            } else if isTrapped { // ADDED: Red border for trapped tigers
                Circle()
                    .stroke(Color.red, lineWidth: 3)
                    .frame(width: size * 1.2)
            }
        }
    }
}
