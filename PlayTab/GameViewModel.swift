import SwiftUI
import AVFoundation

@MainActor
class GameViewModel: ObservableObject {
    @Published var nodes: [BoardNode] = []
    @Published var pieces: [Piece] = []
    @Published var currentPlayer: Player = .goat
    @Published var gameState: GameState = .placingGoats
    @Published var goatsPlaced = 0
    @Published var goatsKilled = 0
    @Published var selectedPiece: Piece? = nil
    @Published var validMoves: [Int] = []
    
    private var undoStack: [GameStateSnapshot] = []
    @Published var config = GameConfiguration()
    
    var topPlayerName: String {
        config.mode == .multiplayer ? config.p1Name : (config.playerRoleVsAI == .goat ? "Computer (Tiger)" : "Computer (Goat)")
    }
    var bottomPlayerName: String {
        config.mode == .multiplayer ? config.p2Name : "You"
    }
    var topPlayerRole: Player {
        config.mode == .multiplayer ? (config.p1Role == .goat ? .goat : .tiger) : (config.playerRoleVsAI == .goat ? .tiger : .goat)
    }
    
    private let haptic = UIImpactFeedbackGenerator(style: .heavy)
    private var aiTask: Task<Void, Never>?
    private var isAITurn: Bool {
        config.mode == .vsComputer && currentPlayer != (config.playerRoleVsAI == .tiger ? .tiger : .goat)
    }
    
    // MARK: - Lifecycle
    func startGame() {
        undoStack.removeAll()
        goatsPlaced = 0; goatsKilled = 0; currentPlayer = .goat; gameState = .placingGoats; selectedPiece = nil; validMoves = []
        setupSelectedBoard()
        if config.mode == .vsComputer && config.playerRoleVsAI == .tiger { checkAITurn() }
    }
    
    func undoLastMove() {
        guard config.allowUndo, let lastState = undoStack.popLast() else { return }
        aiTask?.cancel()
        self.pieces = lastState.pieces; self.currentPlayer = lastState.currentPlayer; self.gameState = lastState.gameState
        self.goatsPlaced = lastState.goatsPlaced; self.goatsKilled = lastState.goatsKilled; self.selectedPiece = nil; self.validMoves = []
    }
    
    private func saveStateForUndo() {
        if config.allowUndo {
            let snapshot = GameStateSnapshot(pieces: pieces, currentPlayer: currentPlayer, gameState: gameState, goatsPlaced: goatsPlaced, goatsKilled: goatsKilled)
            undoStack.append(snapshot)
            if undoStack.count > 20 { undoStack.removeFirst() }
        }
    }
    
    // MARK: - Board Setup
    private func setupSelectedBoard() {
        switch config.selectedBoard {
        case .simple: setupSimpleBoard()
        case .standard: setupStandardBoard()
        case .complex: setupComplexBoard()
        }
    }

    private func setupSimpleBoard() {
        nodes = [
            BoardNode(id: 0, position: CGPoint(x:0.5, y:0.2), edges: [Edge(to:1, jumpNode: nil), Edge(to:2, jumpNode: nil), Edge(to:3, jumpNode: nil)]),
            BoardNode(id: 1, position: CGPoint(x:0.3, y:0.5), edges: [Edge(to:0, jumpNode: nil), Edge(to:3, jumpNode: nil), Edge(to:4, jumpNode: nil)]),
            BoardNode(id: 2, position: CGPoint(x:0.7, y:0.5), edges: [Edge(to:0, jumpNode: nil), Edge(to:3, jumpNode: nil), Edge(to:5, jumpNode: nil)]),
            BoardNode(id: 3, position: CGPoint(x:0.5, y:0.5), edges: [Edge(to:0, jumpNode: nil), Edge(to:1, jumpNode: nil), Edge(to:2, jumpNode: nil), Edge(to:4, jumpNode: nil), Edge(to:5, jumpNode: nil)]),
            BoardNode(id: 4, position: CGPoint(x:0.5, y:0.8), edges: [Edge(to:1, jumpNode: nil), Edge(to:3, jumpNode: nil)]),
            BoardNode(id: 5, position: CGPoint(x:0.7, y:0.8), edges: [Edge(to:2, jumpNode: nil), Edge(to:3, jumpNode: nil)])
        ]
        pieces = [Piece(type: .tiger, nodeId: 0)]
    }
    
    // MARK: - LARGE BOARD (5 Tigers, 20 Goats)
    // MARK: - LARGE BOARD (4 Tigers, 20 Goats - 5x5 Grid)
        private func setupComplexBoard() {
            var generatedNodes: [BoardNode] = []
            let rows = 5
            let cols = 5
            
            // Dynamically spacing the grid across the screen to make a perfect square
            let xSpacing = 0.8 / CGFloat(cols - 1) // Spreads from X: 0.1 to 0.9
            // Calculate Y spacing to keep it visually square based on the screen aspect ratio
            let ySpacing = 0.6 / CGFloat(rows - 1) // Spreads from Y: 0.2 to 0.8

            for r in 0..<rows {
                for c in 0..<cols {
                    let id = r * cols + c
                    let x = 0.1 + CGFloat(c) * xSpacing
                    let y = 0.2 + CGFloat(r) * ySpacing
                    var edges: [Edge] = []

                    // Helper function: Checks if a row/col exists and returns its ID
                    func getNodeId(_ targetRow: Int, _ targetCol: Int) -> Int? {
                        if targetRow >= 0 && targetRow < rows && targetCol >= 0 && targetCol < cols {
                            return targetRow * cols + targetCol
                        }
                        return nil
                    }

                    // All 8 possible move directions (Up, Down, Left, Right + 4 Diagonals)
                    let directions = [
                        (-1, 0), (1, 0), (0, -1), (0, 1),
                        (-1, -1), (-1, 1), (1, -1), (1, 1)
                    ]

                    // Traditional rule: Diagonals are only active on alternating "even" intersections
                    let hasDiagonals = (r + c) % 2 == 0

                    for (dr, dc) in directions {
                        let isDiagonal = abs(dr) == 1 && abs(dc) == 1
                        
                        // Skip diagonal connections if this specific node shouldn't have them
                        if isDiagonal && !hasDiagonals { continue }

                        // If an adjacent node exists in this direction, map the edge and check for a jump!
                        if let adjId = getNodeId(r + dr, c + dc) {
                            let jumpId = getNodeId(r + (dr * 2), c + (dc * 2))
                            edges.append(Edge(to: adjId, jumpNode: jumpId))
                        }
                    }
                    
                    generatedNodes.append(BoardNode(id: id, position: CGPoint(x: x, y: y), edges: edges))
                }
            }
            
            nodes = generatedNodes
            
            // Place the 4 Tigers exactly in the corners of the 5x5 grid
            pieces = [
                Piece(type: .tiger, nodeId: 0),   // Top Left corner (r:0, c:0)
                Piece(type: .tiger, nodeId: 4),   // Top Right corner (r:0, c:4)
                Piece(type: .tiger, nodeId: 20),  // Bottom Left corner (r:4, c:0)
                Piece(type: .tiger, nodeId: 24)   // Bottom Right corner (r:4, c:4)
            ]
        }

    private func setupStandardBoard() {
        nodes = [
            BoardNode(id: 0, position: CGPoint(x: 0.50, y: 0.10), edges: [Edge(to: 1, jumpNode: 6), Edge(to: 2, jumpNode: 7), Edge(to: 3, jumpNode: 8), Edge(to: 4, jumpNode: 9)]),
            BoardNode(id: 1, position: CGPoint(x: 0.395, y: 0.26), edges: [Edge(to: 0, jumpNode: nil), Edge(to: 2, jumpNode: 3), Edge(to: 6, jumpNode: 12)]),
            BoardNode(id: 2, position: CGPoint(x: 0.465, y: 0.26), edges: [Edge(to: 0, jumpNode: nil), Edge(to: 1, jumpNode: nil), Edge(to: 3, jumpNode: 4), Edge(to: 7, jumpNode: 13)]),
            BoardNode(id: 3, position: CGPoint(x: 0.535, y: 0.26), edges: [Edge(to: 0, jumpNode: nil), Edge(to: 2, jumpNode: 1), Edge(to: 4, jumpNode: nil), Edge(to: 8, jumpNode: 14)]),
            BoardNode(id: 4, position: CGPoint(x: 0.605, y: 0.26), edges: [Edge(to: 0, jumpNode: nil), Edge(to: 3, jumpNode: 2), Edge(to: 9, jumpNode: 15)]),
            BoardNode(id: 5, position: CGPoint(x: 0.15, y: 0.42), edges: [Edge(to: 6, jumpNode: 7), Edge(to: 11, jumpNode: 17)]),
            BoardNode(id: 6, position: CGPoint(x: 0.29, y: 0.42), edges: [Edge(to: 5, jumpNode: nil), Edge(to: 7, jumpNode: 8), Edge(to: 1, jumpNode: 0), Edge(to: 12, jumpNode: 18)]),
            BoardNode(id: 7, position: CGPoint(x: 0.43, y: 0.42), edges: [Edge(to: 6, jumpNode: 5), Edge(to: 8, jumpNode: 9), Edge(to: 2, jumpNode: 0), Edge(to: 13, jumpNode: 19)]),
            BoardNode(id: 8, position: CGPoint(x: 0.57, y: 0.42), edges: [Edge(to: 7, jumpNode: 6), Edge(to: 9, jumpNode: 10), Edge(to: 3, jumpNode: 0), Edge(to: 14, jumpNode: 20)]),
            BoardNode(id: 9, position: CGPoint(x: 0.71, y: 0.42), edges: [Edge(to: 8, jumpNode: 7), Edge(to: 10, jumpNode: nil), Edge(to: 4, jumpNode: 0), Edge(to: 15, jumpNode: 21)]),
            BoardNode(id: 10, position: CGPoint(x: 0.85, y: 0.42), edges: [Edge(to: 9, jumpNode: 8), Edge(to: 16, jumpNode: 22)]),
            BoardNode(id: 11, position: CGPoint(x: 0.15, y: 0.58), edges: [Edge(to: 12, jumpNode: 13), Edge(to: 5, jumpNode: nil), Edge(to: 17, jumpNode: nil)]),
            BoardNode(id: 12, position: CGPoint(x: 0.29, y: 0.58), edges: [Edge(to: 11, jumpNode: nil), Edge(to: 13, jumpNode: 14), Edge(to: 6, jumpNode: 1), Edge(to: 18, jumpNode: 23)]),
            BoardNode(id: 13, position: CGPoint(x: 0.43, y: 0.58), edges: [Edge(to: 12, jumpNode: 11), Edge(to: 14, jumpNode: 15), Edge(to: 7, jumpNode: 2), Edge(to: 19, jumpNode: 24)]),
            BoardNode(id: 14, position: CGPoint(x: 0.57, y: 0.58), edges: [Edge(to: 13, jumpNode: 12), Edge(to: 15, jumpNode: 16), Edge(to: 8, jumpNode: 3), Edge(to: 20, jumpNode: 25)]),
            BoardNode(id: 15, position: CGPoint(x: 0.71, y: 0.58), edges: [Edge(to: 14, jumpNode: 13), Edge(to: 16, jumpNode: nil), Edge(to: 9, jumpNode: 4), Edge(to: 21, jumpNode: 26)]),
            BoardNode(id: 16, position: CGPoint(x: 0.85, y: 0.58), edges: [Edge(to: 15, jumpNode: 14), Edge(to: 10, jumpNode: nil), Edge(to: 22, jumpNode: nil)]),
            BoardNode(id: 17, position: CGPoint(x: 0.15, y: 0.74), edges: [Edge(to: 18, jumpNode: 19), Edge(to: 11, jumpNode: 5)]),
            BoardNode(id: 18, position: CGPoint(x: 0.29, y: 0.74), edges: [Edge(to: 17, jumpNode: nil), Edge(to: 19, jumpNode: 20), Edge(to: 12, jumpNode: 6), Edge(to: 23, jumpNode: nil)]),
            BoardNode(id: 19, position: CGPoint(x: 0.43, y: 0.74), edges: [Edge(to: 18, jumpNode: 17), Edge(to: 20, jumpNode: 21), Edge(to: 13, jumpNode: 7), Edge(to: 24, jumpNode: nil)]),
            BoardNode(id: 20, position: CGPoint(x: 0.57, y: 0.74), edges: [Edge(to: 19, jumpNode: 18), Edge(to: 21, jumpNode: 22), Edge(to: 14, jumpNode: 8), Edge(to: 25, jumpNode: nil)]),
            BoardNode(id: 21, position: CGPoint(x: 0.71, y: 0.74), edges: [Edge(to: 20, jumpNode: 19), Edge(to: 22, jumpNode: nil), Edge(to: 15, jumpNode: 9), Edge(to: 26, jumpNode: nil)]),
            BoardNode(id: 22, position: CGPoint(x: 0.85, y: 0.74), edges: [Edge(to: 21, jumpNode: 20), Edge(to: 16, jumpNode: 10)]),
            BoardNode(id: 23, position: CGPoint(x: 0.29, y: 0.90), edges: [Edge(to: 24, jumpNode: 25), Edge(to: 18, jumpNode: 12)]),
            BoardNode(id: 24, position: CGPoint(x: 0.43, y: 0.90), edges: [Edge(to: 23, jumpNode: nil), Edge(to: 25, jumpNode: 26), Edge(to: 19, jumpNode: 13)]),
            BoardNode(id: 25, position: CGPoint(x: 0.57, y: 0.90), edges: [Edge(to: 24, jumpNode: 23), Edge(to: 26, jumpNode: nil), Edge(to: 20, jumpNode: 14)]),
            BoardNode(id: 26, position: CGPoint(x: 0.71, y: 0.90), edges: [Edge(to: 25, jumpNode: 24), Edge(to: 21, jumpNode: 15)])
        ]
        pieces = [Piece(type: .tiger, nodeId: 0), Piece(type: .tiger, nodeId: 2), Piece(type: .tiger, nodeId: 3)]
    }
    
    // MARK: - Interaction Logic
    func handleNodeTap(nodeId: Int) {
        guard !isAITurn || config.mode == .multiplayer else { return }
        _executeNodeTap(nodeId: nodeId)
    }
    
    private func _executeNodeTap(nodeId: Int) {
        if gameState == .placingGoats && currentPlayer == .goat { placeGoat(at: nodeId) }
        else if validMoves.contains(nodeId), let piece = selectedPiece { executeMove(piece: piece, to: nodeId) }
        else { selectPiece(at: nodeId) }
    }
    
    private func placeGoat(at nodeId: Int) {
        guard !pieces.contains(where: { $0.nodeId == nodeId }) else { return }
        saveStateForUndo()
        pieces.append(Piece(type: .goat, nodeId: nodeId))
        goatsPlaced += 1
        if goatsPlaced >= config.selectedBoard.goatCount { gameState = .playing }
        currentPlayer = .tiger
        checkAITurn()
    }
    
    private func selectPiece(at nodeId: Int) {
        guard let piece = pieces.first(where: { $0.nodeId == nodeId }), piece.type == currentPlayer else {
            selectedPiece = nil; validMoves = []; return
        }
        selectedPiece = piece; calculateValidMoves(for: piece)
    }
    
    private func calculateValidMoves(for piece: Piece) { validMoves = getValidMoves(for: piece) }
    
    private func getValidMoves(for piece: Piece) -> [Int] {
        guard let node = nodes.first(where: { $0.id == piece.nodeId }) else { return [] }
        var moves: [Int] = []
        for edge in node.edges {
            let isTargetEmpty = !pieces.contains(where: { $0.nodeId == edge.to })
            if isTargetEmpty { moves.append(edge.to) }
            else if piece.type == .tiger {
                if let jumpNode = edge.jumpNode, let jumpedPiece = pieces.first(where: { $0.nodeId == edge.to }), jumpedPiece.type == .goat, !pieces.contains(where: { $0.nodeId == jumpNode }) {
                    moves.append(jumpNode)
                }
            }
        }
        return moves
    }
    
    private func executeMove(piece: Piece, to targetNodeId: Int) {
        if let index = pieces.firstIndex(of: piece) {
            saveStateForUndo()
            if piece.type == .tiger { checkForCapture(from: piece.nodeId, to: targetNodeId) }
            pieces[index].nodeId = targetNodeId
            selectedPiece = nil; validMoves = []
            currentPlayer = currentPlayer == .tiger ? .goat : .tiger
            checkWinConditions()
            checkAITurn()
        }
    }
    
    private func checkForCapture(from startId: Int, to endId: Int) {
        guard let startNode = nodes.first(where: { $0.id == startId }), let edge = startNode.edges.first(where: { $0.jumpNode == endId }) else { return }
        pieces.removeAll { $0.nodeId == edge.to && $0.type == .goat }
        goatsKilled += 1
        haptic.impactOccurred()
    }
    
    private func checkWinConditions() {
        if goatsKilled >= config.selectedBoard.tigerCount + 2 { gameState = .tigerWon }
    }
    
    // MARK: - AI Logic
    private func checkAITurn() {
        if isAITurn && (gameState == .playing || gameState == .placingGoats) {
            aiTask?.cancel()
            aiTask = Task { try? await Task.sleep(nanoseconds: 1_000_000_000); if !Task.isCancelled { await executeAIMove() } }
        }
    }
    
    private func executeAIMove() async {
        if gameState == .placingGoats && currentPlayer == .goat { placeGoatAsAI() } else { movePieceAsAI() }
    }
    
    private func placeGoatAsAI() {
            let emptyNodes = nodes.filter { node in !pieces.contains(where: { $0.nodeId == node.id }) }
            guard let randomEmptyNode = emptyNodes.randomElement() else { return }
            
            // FIX: Tell the game engine to place the goat directly, bypassing UI clicks
            placeGoat(at: randomEmptyNode.id)
        }
        
        private func movePieceAsAI() {
            let aiPieces = pieces.filter { $0.type == currentPlayer }
            var allPossibleMoves: [(piece: Piece, target: Int)] = []
            for piece in aiPieces {
                let moves = getValidMoves(for: piece)
                for move in moves { allPossibleMoves.append((piece, move)) }
            }
            guard !allPossibleMoves.isEmpty else { return }
            
            let chosenMove: (piece: Piece, target: Int)
            switch config.difficulty {
            case .easy: chosenMove = allPossibleMoves.randomElement()!
            case .medium:
                if currentPlayer == .tiger, let captureMove = findCaptureMove(in: allPossibleMoves) { chosenMove = captureMove }
                else { chosenMove = allPossibleMoves.randomElement()! }
            case .hard: chosenMove = allPossibleMoves.randomElement()! // Placeholder for Minimax
            }
            
            // FIX: Execute the move directly into the math engine!
            executeMove(piece: chosenMove.piece, to: chosenMove.target)
        }
    
    private func findCaptureMove(in moves: [(piece: Piece, target: Int)]) -> (piece: Piece, target: Int)? {
        for move in moves {
            if let startNode = nodes.first(where: { $0.id == move.piece.nodeId }), let _ = startNode.edges.first(where: { $0.jumpNode == move.target }) { return move }
        }
        return nil
    }
}
