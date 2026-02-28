import SwiftUI

struct PlayTabView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var navigationPath = NavigationPath()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let darkStone = Color(red: 0.15, green: 0.18, blue: 0.15)
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AnimatedGrassBackground()
                
                VStack(spacing: (horizontalSizeClass == .compact ? 40 : 80)) {
                    // Responsive Header
                    Text("Tiger And Goat")
                        .font(.system(size: horizontalSizeClass == .compact ? 42 : 64, weight: .heavy, design: .serif))
                        .foregroundColor(darkStone)
                        .padding(.top, horizontalSizeClass == .compact ? 60 : 100)
                    
                    VStack(spacing: 20) {
                        Button {
                            navigationPath.append("MultiplayerSetup")
                        } label: {
                            GameModeRowView(title: "Multiplayer", subtitle: "Play locally with a friend", iconName: "person.2.fill", iconColor: .blue)
                        }
                        .buttonStyle(AppStoreCardButtonStyle())
                        
                        Button {
                            navigationPath.append("ComputerSetup")
                        } label: {
                            GameModeRowView(title: "VS Computer", subtitle: "Challenge the Bot", iconName: "cpu.fill", iconColor: .orange)
                        }
                        .buttonStyle(AppStoreCardButtonStyle())
                    }
                    .frame(maxWidth: horizontalSizeClass == .compact ? 400 : 500)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(.all, edges: .leading) // <-- ADDED HERE
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "MultiplayerSetup": MultiplayerSetupView(viewModel: viewModel, path: $navigationPath)
                case "ComputerSetup": ComputerSetupView(viewModel: viewModel, path: $navigationPath)
                case "ActiveGame": ActiveGameView(viewModel: viewModel, path: $navigationPath)
                default: EmptyView()
                }
            }
        }
    }
}

// MARK: - Setup Screens
struct MultiplayerSetupView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: NavigationPath
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            AnimatedGrassBackground()
            ScrollView {
                VStack(spacing: (horizontalSizeClass == .compact ? 24 : 40)) {
                    VStack(spacing: 32) {
                        GridSelectionView(selectedBoard: $viewModel.config.selectedBoard) // Board at Top
                        
                        Divider()
                        
                        Toggle(isOn: $viewModel.config.allowUndo) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Allow 'Take Move Back'")
                                    .font(horizontalSizeClass == .compact ? .headline : .title2)
                                Text("Players can undo their last move")
                                    .font(horizontalSizeClass == .compact ? .caption : .headline) // Modified: .body -> .headline
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding().background(Color.white.opacity(0.5)).cornerRadius(16)
                        
                        Button(action: {
                            viewModel.config.mode = .multiplayer
                            viewModel.startGame()
                            path.append("ActiveGame")
                        }) {
                            Text("START MATCH")
                                .font(horizontalSizeClass == .compact ? .headline : .title2)
                                .fontWeight(.black).foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 60)
                                .background(Capsule().fill(Color.orange))
                        }
                    }
                    .padding(horizontalSizeClass == .compact ? 20 : 40)
                    .background(.regularMaterial).cornerRadius(32)
                    .frame(maxWidth: horizontalSizeClass == .compact ? .infinity : 700)
                    .padding(.horizontal, 24).padding(.top, 40)
                }
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(.all, edges: .leading) // <-- ADDED HERE
    }
}

struct ComputerSetupView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: NavigationPath
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            AnimatedGrassBackground()
            ScrollView {
                VStack(spacing: (horizontalSizeClass == .compact ? 24 : 40)) {
                    VStack(spacing: 32) {
                        GridSelectionView(selectedBoard: $viewModel.config.selectedBoard) // Board at Top
                        
                        Divider()
                        
                        // Side Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose Your Side")
                                .font(horizontalSizeClass == .compact ? .headline : .system(size: 28, weight: .bold))
                            HStack(spacing: 20) {
                                RoleButton(title: "Tiger", role: .tiger, isSelected: viewModel.config.playerRoleVsAI == .tiger) {
                                    viewModel.config.playerRoleVsAI = .tiger
                                }
                                RoleButton(title: "Goat", role: .goat, isSelected: viewModel.config.playerRoleVsAI == .goat) {
                                    viewModel.config.playerRoleVsAI = .goat
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Difficulty Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Difficulty")
                                .font(horizontalSizeClass == .compact ? .headline : .system(size: 28, weight: .bold))
                            Picker("Difficulty", selection: $viewModel.config.difficulty) {
                                ForEach(Difficulty.allCases) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Divider()
                        
                        Toggle(isOn: $viewModel.config.allowUndo) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Allow 'Take Move Back'")
                                    .font(horizontalSizeClass == .compact ? .headline : .title2)
                                Text("Recommended for new players")
                                    .font(horizontalSizeClass == .compact ? .caption : .headline) // Modified: .body -> .headline
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding().background(Color.white.opacity(0.5)).cornerRadius(16)
                        
                        Button(action: {
                            viewModel.config.mode = .vsComputer
                            viewModel.startGame()
                            path.append("ActiveGame")
                        }) {
                            Text("CHALLENGE BOT")
                                .font(horizontalSizeClass == .compact ? .headline : .title2)
                                .fontWeight(.black).foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 60)
                                .background(Capsule().fill(Color.orange))
                        }
                    }
                    .padding(horizontalSizeClass == .compact ? 20 : 40)
                    .background(.regularMaterial).cornerRadius(32)
                    .frame(maxWidth: horizontalSizeClass == .compact ? .infinity : 700)
                    .padding(.horizontal, 24).padding(.top, 40)
                }
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(.all, edges: .leading) // <-- ADDED HERE
    }
}

// MARK: - Grid Components
struct GridSelectionView: View {
    @Binding var selectedBoard: BoardType
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .compact ? 20 : 30) {
            Text("Select Board")
                .font(horizontalSizeClass == .compact ? .headline : .system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, horizontalSizeClass == .compact ? 24 : 0)

            if horizontalSizeClass == .compact {
                // iPhone: Horizontal Paging with Dots
                TabView(selection: $selectedBoard) {
                    ForEach(BoardType.allCases) { board in
                        BoardSelectionCard(board: board, isSelected: selectedBoard == board)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                            .tag(board)
                    }
                }
                .frame(height: 320) // Adjusted height for images
                .tabViewStyle(.page(indexDisplayMode: .always))
            } else {
                // iPad: Side-by-Side Grid
                HStack(spacing: 24) {
                    ForEach(BoardType.allCases) { board in
                        BoardSelectionCard(board: board, isSelected: selectedBoard == board)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedBoard = board
                                }
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Board Selection Card with Image Support
struct BoardSelectionCard: View {
    let board: BoardType
    let isSelected: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(spacing: 12) {
            // 1. The Grid Image
            Image(board.imageName) // Matches imageName in GameModels.swift
                .resizable()
                .scaledToFit()
                .frame(height: horizontalSizeClass == .compact ? 150 : 220) // Taller for iPad
                .padding(10)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
            
            // 2. The Board Info
            VStack(spacing: 6) {
                Text(board.rawValue.components(separatedBy: " (")[0])
                    .font(horizontalSizeClass == .compact ? .headline : .system(size: 30, weight: .bold)) // Modified: 26 -> 30
                
                Text("\(board.tigerCount) Tigers • \(board.goatCount) Goats")
                    .font(horizontalSizeClass == .compact ? .caption : .headline) // Modified: .body -> .headline
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.white.opacity(0.6))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 4)
        )
        .shadow(color: .black.opacity(isSelected ? 0.1 : 0.05), radius: 15)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Helper Views
struct RoleButton: View {
    let title: String; let role: PlayerSide; let isSelected: Bool; let action: () -> Void
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(role == .tiger ? "tiger_piece" : "goat_piece").resizable().scaledToFit().frame(width: horizontalSizeClass == .compact ? 50 : 80)
                Text(title).font(horizontalSizeClass == .compact ? .subheadline : .title2).fontWeight(.bold) // Modified: .title3 -> .title2
            }
            .frame(maxWidth: .infinity).padding(.vertical, horizontalSizeClass == .compact ? 16 : 32)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.4)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3))
        }.buttonStyle(.plain)
    }
}

struct GameModeRowView: View {
    let title: String; let subtitle: String; let iconName: String; let iconColor: Color
    var body: some View {
        HStack(spacing: 20) {
            ZStack { Circle().fill(iconColor.opacity(0.2)).frame(width: 60, height: 60)
                Image(systemName: iconName).font(.title2).fontWeight(.bold).foregroundColor(iconColor) }
            VStack(alignment: .leading, spacing: 4) { Text(title).font(.title3).fontWeight(.bold).foregroundColor(.primary)
                Text(subtitle).font(.subheadline).foregroundColor(.secondary) }
            Spacer()
            Image(systemName: "chevron.right").font(.title3).fontWeight(.semibold).foregroundColor(Color.secondary.opacity(0.5))
        }.padding(16).background(.regularMaterial).clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct AppStoreCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
