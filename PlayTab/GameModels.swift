//
//  Player.swift
//  Tiger And Goat
//
//  Created by SDC-USER on 27/02/26.
//


import SwiftUI

// MARK: - Core Game Math Models
enum Player { case tiger, goat }
enum GameState { case placingGoats, playing, tigerWon, goatWon }

struct Piece: Identifiable, Equatable {
    let id = UUID()
    var type: Player
    var nodeId: Int
}

struct Edge {
    let to: Int
    let jumpNode: Int?
}

struct BoardNode: Identifiable {
    let id: Int
    let position: CGPoint
    let edges: [Edge]
}

// MARK: - Setup & Configuration Models
enum BoardType: String, CaseIterable, Identifiable {
    case simple = "Small (1 Tiger, 5 Goats)"
    case standard = "Medium (3 Tigers, 15 Goats)"
    case complex = "Large (4 Tigers, 20 Goats)" // Updated to 4 Tigers
    
    var id: String { self.rawValue }
    
    var tigerCount: Int {
        switch self { case .simple: return 1; case .standard: return 3; case .complex: return 4 } // Updated to 4
    }
    
    var goatCount: Int {
        switch self { case .simple: return 5; case .standard: return 15; case .complex: return 20 }
    }
    
    var imageName: String {
        switch self {
        case .simple: return "grid_simple"
        case .standard: return "grid_standard"
        case .complex: return "grid_complex"
        }
    }
}


enum GameMode { case multiplayer, vsComputer }
enum PlayerSide { case tiger, goat }
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"; case medium = "Medium"; case hard = "Hard"
    var id: String { rawValue }
}

struct GameConfiguration {
    var mode: GameMode = .multiplayer
    var selectedBoard: BoardType = .standard
    var p1Name: String = "Player 1"
    var p2Name: String = "Player 2"
    var p1Role: PlayerSide = .goat
    var playerRoleVsAI: PlayerSide = .goat
    var difficulty: Difficulty = .medium
    var allowUndo: Bool = false
}

struct GameStateSnapshot {
    let pieces: [Piece]
    let currentPlayer: Player
    let gameState: GameState
    let goatsPlaced: Int
    let goatsKilled: Int
}
