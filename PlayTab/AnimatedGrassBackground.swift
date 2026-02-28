import SwiftUI


struct AnimatedGrassBackground: View {
    let parchment = Color(red: 0.95, green: 0.92, blue: 0.85)
    let skyOrange = Color(red: 0.98, green: 0.75, blue: 0.45)
    
    var body: some View {
        GeometryReader { geo in
            let isIPad = geo.size.width > 600
            
            
            let grassHeight = isIPad ? 280.0 : 200.0
            let rockWidth = geo.size.width * 0.75
            let rockHeight = isIPad ? 300.0 : 200.0
            let tigerSize = isIPad ? 140.0 : 90.0
            
            ZStack {
                
                LinearGradient(
                    colors: [skyOrange, parchment],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                
                Circle()
                    .fill(Color(red: 1.0, green: 0.3, blue: 0.1).opacity(0.8))
                    .frame(width: isIPad ? 180 : 120)
                    .position(x: geo.size.width * 0.3, y: geo.size.height * 0.25)
                    .blur(radius: 10)
                
                
                ZStack(alignment: .topLeading) {
                    PrideRockShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.4, green: 0.38, blue: 0.35), Color(red: 0.2, green: 0.18, blue: 0.15)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.4), radius: 20, x: -10, y: 10)
                    
                    
                                        Image("tigerlanding")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: tigerSize, height: tigerSize)
                                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
                                            // Increased X (moves right) and increased Y (moves down the slope)
                                            .offset(x: isIPad ? 10 : 5, y: isIPad ? -65 : -40)
                }
                .frame(width: rockWidth, height: rockHeight)
                
                .position(x: geo.size.width - (rockWidth / 2) + 20,
                          y: geo.size.height - grassHeight - (rockHeight / 2) + 60)
                
                
                VStack {
                    Spacer()
                    BottomGrassField()
                        .frame(height: grassHeight)
                }
                .ignoresSafeArea()
                
                
                let goatSizeLg = isIPad ? 110.0 : 70.0
                let goatSizeSm = isIPad ? 80.0 : 50.0
                
                GrazingGoat(size: goatSizeLg)
                    .position(x: geo.size.width * 0.15, y: geo.size.height - grassHeight * 0.7)
                
                GrazingGoat(size: goatSizeSm)
                    .position(x: geo.size.width * 0.4, y: geo.size.height - grassHeight * 0.85)
                
                GrazingGoat(size: goatSizeLg * 1.1)
                    .position(x: geo.size.width * 0.65, y: geo.size.height - grassHeight * 0.3)
                
                GrazingGoat(size: goatSizeSm)
                    .position(x: geo.size.width * 0.85, y: geo.size.height - grassHeight * 0.6)
            }
        }
        .ignoresSafeArea()
    }
}


struct GrazingGoat: View {
    let size: CGFloat
    @State private var isGrazing = false
    
    let animationDuration = Double.random(in: 1.5...3.0)
    let delay = Double.random(in: 0...2.0)
    
    var body: some View {
        Image("goatlanding")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
            .rotationEffect(.degrees(isGrazing ? -8 : 0), anchor: .bottomTrailing)
            .offset(y: isGrazing ? size * 0.15 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(
                        .easeInOut(duration: animationDuration)
                        .repeatForever(autoreverses: true)
                    ) {
                        isGrazing.toggle()
                    }
                }
            }
    }
}


struct PrideRockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 60))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + 40, y: rect.minY + 50))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 60, y: rect.maxY),
            control: CGPoint(x: rect.midX + 20, y: rect.maxY - 80)
        )
        path.closeSubpath()
        return path
    }
}


struct BottomGrassField: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.45, blue: 0.15),
                    Color(red: 0.10, green: 0.25, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            GeometryReader { geo in
                let rowCount = 5
                let colCount = Int(geo.size.width / 15) + 2
                
                ZStack(alignment: .topLeading) {
                    ForEach(0..<rowCount, id: \.self) { row in
                        let normalizedRow = CGFloat(row) / CGFloat(rowCount - 1)
                        let depthScale = 0.5 + (normalizedRow * 1.5)
                        
                        let yBase = geo.size.height * 0.2 + (geo.size.height * 0.7 * normalizedRow)
                        
                        ForEach(0..<colCount, id: \.self) { col in
                            let randomSeed = (row * 7 + col * 13) % 100
                            let randomSeed2 = (row * 11 + col * 17) % 100
                            
                            let height = CGFloat(35 + (randomSeed % 25)) * depthScale
                            let width = CGFloat(6 + (randomSeed2 % 4)) * depthScale
                            let sway = Double(4 + (randomSeed % 8))
                            let duration = Double(1.5 + Double(randomSeed2 % 10) * 0.1)
                            
                            let baseGreen = 0.25 + (Double(normalizedRow) * 0.35)
                            let bladeColor = Color(
                                red: 0.15 + (Double(randomSeed % 10) * 0.01),
                                green: baseGreen + (Double(randomSeed % 10) * 0.01),
                                blue: 0.10
                            )
                            
                            let xPos = (geo.size.width / CGFloat(colCount - 1)) * CGFloat(col)
                            
                            let xJitter = CGFloat((randomSeed % 20) - 10)
                            let yJitter = CGFloat((randomSeed2 % 20) - 10)
                            
                            SwayingGrassBlade(
                                color: bladeColor,
                                height: height,
                                width: width,
                                swayAmount: sway,
                                animationDuration: duration
                            )
                            .position(x: xPos + xJitter, y: yBase + yJitter)
                        }
                    }
                }
            }
        }
    }
}


struct SwayingGrassBlade: View {
    @State private var isSwaying = false
    let color: Color; let height: CGFloat; let width: CGFloat
    let swayAmount: Double; let animationDuration: Double
    let initialDelay = Double.random(in: 0...1.5)
    
    var body: some View {
        SharpGrassBladeShape()
            .fill(color)
            .frame(width: width, height: height)
            .rotationEffect(.degrees(isSwaying ? swayAmount : -swayAmount), anchor: .bottom)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
                    withAnimation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                        isSwaying.toggle()
                    }
                }
            }
    }
}


struct SharpGrassBladeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX + (rect.width * 0.25), y: rect.midY * 1.2))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY), control: CGPoint(x: rect.maxX - (rect.width * 0.25), y: rect.midY * 1.2))
        path.closeSubpath()
        return path
    }
}
