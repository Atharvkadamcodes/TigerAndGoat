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
    @Published var config = GameConfiguration()
    
    private var undoStack: [GameStateSnapshot] = []
    private let hapticSuccess = UINotificationFeedbackGenerator()
    private let hapticImpact = UIImpactFeedbackGenerator(style: .heavy)
    private var aiTask: Task<Void, Never>?

    // MARK: - Thematic Naming Logic
    var topPlayerName: String {
        if config.mode == .multiplayer {
            return topPlayerRole == .tiger ? "Tiger" : "Goat"
        } else {
            return config.playerRoleVsAI == .goat ? "Computer (Tiger)" : "Computer (Goat)"
        }
    }
    
    var bottomPlayerName: String {
        if config.mode == .multiplayer {
            let bottomRole: Player = topPlayerRole == .tiger ? .goat : .tiger
            return bottomRole == .tiger ? "Tiger" : "Goat"
        } else {
            let myRoleStr = config.playerRoleVsAI == .tiger ? "Tiger" : "Goat"
            return "You (\(myRoleStr))"
        }
    }

    var topPlayerRole: Player {
        config.mode == .multiplayer ? (config.p1Role == .goat ? .goat : .tiger) : (config.playerRoleVsAI == .goat ? .tiger : .goat)
    }
    
    private var isAITurn: Bool {
        config.mode == .vsComputer && currentPlayer != (config.playerRoleVsAI == .tiger ? .tiger : .goat)
    }
    
    // MARK: - Lifecycle
    func startGame() {
        undoStack.removeAll()
        goatsPlaced = 0; goatsKilled = 0; currentPlayer = .goat; gameState = .placingGoats; selectedPiece = nil; validMoves = []
        setupSelectedBoard()
        if isAITurn { checkAITurn() }
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
    
    // MARK: - Board Setup Logic
    private func setupSelectedBoard() {
        switch config.selectedBoard {
        case .simple: setupSimpleBoard()
        case .standard: setupStandardBoard()
        case .complex: setupComplexBoard()
        }
    }

    private func setupSimpleBoard() {
        nodes = [
            BoardNode(id: 0, position: CGPoint(x: 0.5, y: 0.15), edges: [Edge(to: 1, jumpNode: 4), Edge(to: 2, jumpNode: 5), Edge(to: 3, jumpNode: 6)]),
            BoardNode(id: 1, position: CGPoint(x: 0.35, y: 0.40), edges: [Edge(to: 0, jumpNode: nil), Edge(to: 2, jumpNode: 3), Edge(to: 4, jumpNode: 7)]),
            BoardNode(id: 2, position: CGPoint(x: 0.5, y: 0.40), edges: [Edge(to: 0, jumpNode: nil), Edge(to: 1, jumpNode: nil), Edge(to: 3, jumpNode: nil), Edge(to: 5, jumpNode: 8)]),
            BoardNode(id: 3, position: CGPoint(x: 0.65, y: 0.40), edges: [Edge(to: 0, jumpNode: nil), Edge(to: 2, jumpNode: 1), Edge(to: 6, jumpNode: 9)]),
            BoardNode(id: 4, position: CGPoint(x: 0.20, y: 0.65), edges: [Edge(to: 1, jumpNode: 0), Edge(to: 5, jumpNode: 6), Edge(to: 7, jumpNode: nil)]),
            BoardNode(id: 5, position: CGPoint(x: 0.5, y: 0.65), edges: [Edge(to: 2, jumpNode: 0), Edge(to: 4, jumpNode: nil), Edge(to: 6, jumpNode: nil), Edge(to: 8, jumpNode: nil)]),
            BoardNode(id: 6, position: CGPoint(x: 0.80, y: 0.65), edges: [Edge(to: 3, jumpNode: 0), Edge(to: 5, jumpNode: 4), Edge(to: 9, jumpNode: nil)]),
            BoardNode(id: 7, position: CGPoint(x: 0.05, y: 0.90), edges: [Edge(to: 4, jumpNode: 1), Edge(to: 8, jumpNode: 9)]),
            BoardNode(id: 8, position: CGPoint(x: 0.5, y: 0.90), edges: [Edge(to: 7, jumpNode: nil), Edge(to: 5, jumpNode: 2), Edge(to: 9, jumpNode: nil)]),
            BoardNode(id: 9, position: CGPoint(x: 0.95, y: 0.90), edges: [Edge(to: 8, jumpNode: 7), Edge(to: 6, jumpNode: 3)])
        ]
        pieces = [Piece(type: .tiger, nodeId: 0)]
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

    private func setupComplexBoard() {
        var generatedNodes: [BoardNode] = []
        let rows = 5, cols = 5
        let xSpacing = 0.8 / CGFloat(cols - 1), ySpacing = 0.8 / CGFloat(rows - 1)
        for r in 0..<rows {
            for c in 0..<cols {
                let id = r * cols + c
                let x = 0.1 + CGFloat(c) * xSpacing, y = 0.1 + CGFloat(r) * ySpacing
                var edges: [Edge] = []
                func getNodeId(_ tR: Int, _ tC: Int) -> Int? {
                    (tR >= 0 && tR < rows && tC >= 0 && tC < cols) ? tR * cols + tC : nil
                }
                let directions = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)]
                for (dr, dc) in directions {
                    if (abs(dr) == 1 && abs(dc) == 1) && (r + c) % 2 != 0 { continue }
                    if let adjId = getNodeId(r + dr, c + dc) {
                        edges.append(Edge(to: adjId, jumpNode: getNodeId(r + (dr * 2), c + (dc * 2))))
                    }
                }
                generatedNodes.append(BoardNode(id: id, position: CGPoint(x: x, y: y), edges: edges))
            }
        }
        nodes = generatedNodes
        pieces = [Piece(type: .tiger, nodeId: 0), Piece(type: .tiger, nodeId: 4), Piece(type: .tiger, nodeId: 20), Piece(type: .tiger, nodeId: 24)]
    }
    
    // MARK: - Game Interactions
    func handleNodeTap(nodeId: Int) {
        guard !isAITurn || config.mode == .multiplayer else { return }
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
        checkWinConditions()
        checkAITurn()
    }
    
    private func selectPiece(at nodeId: Int) {
        guard let piece = pieces.first(where: { $0.nodeId == nodeId }), piece.type == currentPlayer else {
            selectedPiece = nil; validMoves = []; return
        }
        selectedPiece = piece
        validMoves = getValidMoves(for: piece)
    }
    
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
        hapticImpact.impactOccurred()
    }
    
    private func checkWinConditions() {
        if goatsKilled >= config.selectedBoard.tigerCount + 2 {
            triggerEndGame(winner: .tigerWon); return
        }
        
        // CHANGED: Goats can win by trapping tigers even during the placing phase!
        if gameState == .playing || gameState == .placingGoats {
            let tigers = pieces.filter { $0.type == .tiger }
            let totalAvailableTigerMoves = tigers.reduce(0) { count, piece in
                count + getValidMoves(for: piece).count
            }
            if totalAvailableTigerMoves == 0 { triggerEndGame(winner: .goatWon) }
        }
    }

    // ADDED: Helper to check if a specific piece has zero moves (for the red border)
    func isPieceTrapped(_ piece: Piece) -> Bool {
        guard piece.type == .tiger else { return false }
        return getValidMoves(for: piece).isEmpty
    }

    private func triggerEndGame(winner: GameState) {
        gameState = winner
        hapticSuccess.notificationOccurred(.success)
        SoundManager.shared.playSound(named: winner == .tigerWon ? "tiger_win" : "goat_win")
        aiTask?.cancel()
    }

    // MARK: - AI decision Engine
    private func checkAITurn() {
        if isAITurn && (gameState == .playing || gameState == .placingGoats) {
            aiTask?.cancel()
            aiTask = Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled { await executeAIMove() }
            }
        }
    }
    
    private func executeAIMove() async {
        if gameState == .placingGoats && currentPlayer == .goat { placeGoatAsAI() } else { movePieceAsAI() }
    }
    
    private func placeGoatAsAI() {
        let emptyNodes = nodes.filter { node in !pieces.contains(where: { $0.nodeId == node.id }) }
        if let randomEmptyNode = emptyNodes.randomElement() { placeGoat(at: randomEmptyNode.id) }
    }
    
    private func movePieceAsAI() {
        let aiPieces = pieces.filter { $0.type == currentPlayer }
        var allMoves: [(piece: Piece, target: Int)] = []
        for p in aiPieces { for m in getValidMoves(for: p) { allMoves.append((p, m)) } }
        guard !allMoves.isEmpty else { return }
        let chosen = allMoves.randomElement()!
        executeMove(piece: chosen.piece, to: chosen.target)
    }
}
