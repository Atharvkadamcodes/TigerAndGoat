import SwiftUI

struct PlayTabView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var navigationPath = NavigationPath()
    
    let parchment = Color(red: 0.95, green: 0.92, blue: 0.85)
    let darkStone = Color(red: 0.15, green: 0.18, blue: 0.15)
    let bronze = Color(red: 0.45, green: 0.35, blue: 0.20)
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                parchment.ignoresSafeArea()
                VStack(spacing: 50) {
                    Text("Aadu Puli Aatam").font(.custom("Georgia", size: 40)).fontWeight(.bold).foregroundColor(darkStone)
                        .padding(.top, 60)
                    
                    VStack(spacing: 25) {
                        Button { navigationPath.append("MultiplayerSetup") } label: {
                            MenuButtonView(title: "Multiplayer", icon: "person.2.fill", color: bronze)
                        }
                        
                        Button { navigationPath.append("ComputerSetup") } label: {
                            MenuButtonView(title: "Vs Computer", icon: "cpu.fill", color: darkStone)
                        }
                    }
                    .padding(.horizontal, 30)
                    Spacer()
                }
            }
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

struct MenuButtonView: View {
    let title: String; let icon: String; let color: Color
    var body: some View {
        HStack {
            Image(systemName: icon).font(.title).frame(width: 50)
            Text(title).font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding().foregroundColor(.white).background(color).cornerRadius(16).shadow(radius: 5)
    }
}

struct GridSelectionView: View {
    @Binding var selectedBoard: BoardType
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Board").font(.headline).padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(BoardType.allCases) { board in
                        VStack {
                            Image(board.imageName)
                                .resizable().scaledToFit().frame(height: 120)
                                .background(Color.gray.opacity(0.2)).cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedBoard == board ? Color.blue : Color.clear, lineWidth: 3))
                            Text(board.rawValue).font(.caption).fontWeight(.semibold)
                        }
                        .onTapGesture { selectedBoard = board }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct MultiplayerSetupView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: NavigationPath
    let parchment = Color(red: 0.95, green: 0.92, blue: 0.85)
    
    var body: some View {
        ZStack {
            parchment.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 25) {
                    GridSelectionView(selectedBoard: $viewModel.config.selectedBoard)
                    
                    GroupBox(label: Text("Player Names")) {
                        TextField("Player 1 (Top)", text: $viewModel.config.p1Name).textFieldStyle(.roundedBorder)
                        TextField("Player 2 (Bottom)", text: $viewModel.config.p2Name).textFieldStyle(.roundedBorder)
                    }
                    
                    GroupBox(label: Text("\(viewModel.config.p1Name) Plays As")) {
                        Picker("Role", selection: $viewModel.config.p1Role) {
                            Text("Goat (Defender)").tag(PlayerSide.goat)
                            Text("Tiger (Predator)").tag(PlayerSide.tiger)
                        }.pickerStyle(.segmented)
                    }
                    
                    Toggle("Allow 'Take Move Back'", isOn: $viewModel.config.allowUndo)
                        .padding().background(Color.white.opacity(0.5)).cornerRadius(12)
                    
                    Button(action: {
                        viewModel.config.mode = .multiplayer
                        viewModel.startGame()
                        path.append("ActiveGame")
                    }) {
                        Text("Start Multiplayer Game").font(.headline).foregroundColor(.white).padding()
                            .frame(maxWidth: .infinity).background(Color(red: 0.45, green: 0.35, blue: 0.20)).cornerRadius(12)
                    }
                }.padding()
            }
        }
        .navigationTitle("Multiplayer Setup")
    }
}

struct ComputerSetupView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: NavigationPath
    let parchment = Color(red: 0.95, green: 0.92, blue: 0.85)
    
    var body: some View {
        ZStack {
            parchment.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 25) {
                    GridSelectionView(selectedBoard: $viewModel.config.selectedBoard)
                    
                    VStack(alignment: .leading) {
                        Text("Play As").font(.headline).padding(.leading)
                        HStack(spacing: 20) {
                            RoleSelectButton(role: .goat, icon: "goat_piece", selectedRole: $viewModel.config.playerRoleVsAI)
                            RoleSelectButton(role: .tiger, icon: "tiger_piece", selectedRole: $viewModel.config.playerRoleVsAI)
                        }.padding(.horizontal)
                    }
                    
                    GroupBox(label: Text("Difficulty")) {
                        Picker("Difficulty", selection: $viewModel.config.difficulty) {
                            ForEach(Difficulty.allCases) { Text($0.rawValue).tag($0) }
                        }.pickerStyle(.segmented)
                    }
                    
                    Toggle("Allow 'Take Move Back'", isOn: $viewModel.config.allowUndo)
                        .padding().background(Color.white.opacity(0.5)).cornerRadius(12)
                    
                    Button(action: {
                        viewModel.config.mode = .vsComputer
                        viewModel.startGame()
                        path.append("ActiveGame")
                    }) {
                        Text("Start Game vs AI").font(.headline).foregroundColor(.white).padding()
                            .frame(maxWidth: .infinity).background(Color(red: 0.15, green: 0.18, blue: 0.15)).cornerRadius(12)
                    }
                }.padding()
            }
        }
        .navigationTitle("Computer Setup")
    }
}

struct RoleSelectButton: View {
    let role: PlayerSide; let icon: String; @Binding var selectedRole: PlayerSide
    var body: some View {
        VStack {
            Image(icon).resizable().scaledToFit().frame(width: 60, height: 60)
                .padding(10)
                .background(selectedRole == role ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedRole == role ? Color.blue : Color.clear, lineWidth: 2))
            Text(role == .goat ? "Goat" : "Tiger").font(.caption)
        }.onTapGesture { selectedRole = role }
    }
}
