//
//  HeartRateView.swift
//  iHeartMon Watch App
//
//  Created by Laura Money on 8/16/25.
//

import SwiftUI

struct HeartRateView: View {
    @StateObject private var heartRateManager = HeartRateManager()
    @State private var pulseAnimation = false
    
    @AppStorage("selectedColorTheme") private var selectedColorTheme = 3
    @AppStorage("selectedWatchFace") private var selectedWatchFace = 0
    
    private let colorThemes: [ColorTheme] = [
        ColorTheme(
            name: "Classic",
            lowColor: .blue,
            normalColor: .green,
            elevatedColor: .yellow,
            highColor: .red,
            noReadingColor: .gray
        ),
        ColorTheme(
            name: "Pretty",
            lowColor: .cyan,
            normalColor: .purple,
            elevatedColor: .pink,
            highColor: .pink,
            noReadingColor: .gray
        ),
        ColorTheme(
            name: "Monochrome",
            lowColor: .white,
            normalColor: .white,
            elevatedColor: .white,
            highColor: .white,
            noReadingColor: .gray
        ),
        ColorTheme(
            name: "Rainbow",
            lowColor: Color(red: 0.0, green: 0.4, blue: 1.0),    // Vibrant blue
            normalColor: Color(red: 0.0, green: 0.9, blue: 0.0), // Vibrant green  
            elevatedColor: Color(red: 1.0, green: 0.6, blue: 0.0), // Vibrant orange
            highColor: Color(red: 1.0, green: 0.0, blue: 0.4),   // Vibrant red-pink
            noReadingColor: Color(red: 0.6, green: 0.0, blue: 1.0) // Vibrant purple
        ),
        ColorTheme(
            name: "Ocean",
            lowColor: .cyan,
            normalColor: .mint,
            elevatedColor: .blue,
            highColor: .indigo,
            noReadingColor: .gray
        ),
        ColorTheme(
            name: "Pastel Rainbow",
            lowColor: Color(red: 0.8, green: 0.9, blue: 1.0),      // Soft blue
            normalColor: Color(red: 0.85, green: 0.95, blue: 0.8), // Soft green
            elevatedColor: Color(red: 1.0, green: 0.9, blue: 0.7), // Soft yellow
            highColor: Color(red: 1.0, green: 0.8, blue: 0.85),    // Soft pink
            noReadingColor: Color(red: 0.9, green: 0.85, blue: 1.0) // Soft purple
        ),
        ColorTheme(
            name: "Pastel",
            lowColor: Color(red: 0.8, green: 0.95, blue: 1.0),     // Soft cyan (like Pretty's cyan)
            normalColor: Color(red: 0.9, green: 0.8, blue: 1.0),   // Soft purple (like Pretty's purple)
            elevatedColor: Color(red: 1.0, green: 0.85, blue: 0.9), // Soft pink (like Pretty's pink)
            highColor: Color(red: 1.0, green: 0.85, blue: 0.9),    // Soft pink (like Pretty's pink)
            noReadingColor: Color(red: 0.85, green: 0.85, blue: 0.85) // Soft gray
        ),
        ColorTheme(
            name: "Pinks",
            lowColor: Color(red: 1.0, green: 0.9, blue: 0.95),     // Very light pink (like Ocean's cyan)
            normalColor: Color(red: 1.0, green: 0.75, blue: 0.9),  // Light pink (like Ocean's mint)
            elevatedColor: Color(red: 1.0, green: 0.6, blue: 0.8), // Medium pink (like Ocean's blue)
            highColor: Color(red: 0.9, green: 0.4, blue: 0.7),     // Deep pink (like Ocean's indigo)
            noReadingColor: Color(red: 0.85, green: 0.85, blue: 0.85) // Soft gray
        ),
        ColorTheme(
            name: "Forest",
            lowColor: Color(red: 0.8, green: 1.0, blue: 0.8),      // Light mint green
            normalColor: Color(red: 0.6, green: 0.9, blue: 0.6),   // Fresh green
            elevatedColor: Color(red: 0.4, green: 0.8, blue: 0.4), // Forest green
            highColor: Color(red: 0.2, green: 0.6, blue: 0.2),     // Deep forest
            noReadingColor: Color(red: 0.85, green: 0.85, blue: 0.85) // Soft gray
        ),
        ColorTheme(
            name: "Fire",
            lowColor: Color(red: 1.0, green: 0.9, blue: 0.7),      // Warm yellow
            normalColor: Color(red: 1.0, green: 0.7, blue: 0.4),   // Orange
            elevatedColor: Color(red: 1.0, green: 0.4, blue: 0.2), // Red-orange
            highColor: Color(red: 0.8, green: 0.2, blue: 0.1),     // Deep red
            noReadingColor: Color(red: 0.85, green: 0.85, blue: 0.85) // Soft gray
        ),
        ColorTheme(
            name: "Sunshine",
            lowColor: Color(red: 1.0, green: 1.0, blue: 0.8),      // Pale yellow
            normalColor: Color(red: 1.0, green: 1.0, blue: 0.6),   // Light yellow
            elevatedColor: Color(red: 1.0, green: 0.9, blue: 0.3), // Bright yellow
            highColor: Color(red: 1.0, green: 0.8, blue: 0.0),     // Golden yellow
            noReadingColor: Color(red: 0.85, green: 0.85, blue: 0.85) // Soft gray
        ),
        ColorTheme(
            name: "Midnight",
            lowColor: Color(red: 0.7, green: 0.8, blue: 1.0),      // Light blue
            normalColor: Color(red: 0.5, green: 0.6, blue: 0.9),   // Medium blue
            elevatedColor: Color(red: 0.3, green: 0.4, blue: 0.7), // Dark blue
            highColor: Color(red: 0.1, green: 0.2, blue: 0.5),     // Deep navy
            noReadingColor: Color(red: 0.85, green: 0.85, blue: 0.85) // Soft gray
        ),
        ColorTheme(
            name: "Sunset",
            lowColor: Color(red: 1.0, green: 0.9, blue: 0.8),      // Cream
            normalColor: Color(red: 1.0, green: 0.7, blue: 0.6),   // Peach
            elevatedColor: Color(red: 1.0, green: 0.5, blue: 0.4), // Coral
            highColor: Color(red: 0.9, green: 0.3, blue: 0.5),     // Pink-red
            noReadingColor: Color(red: 0.85, green: 0.85, blue: 0.85) // Soft gray
        )
    ]
    
    enum Theme: CaseIterable {
        case classic
        case minimal
        case pastel
        case chunky
        case numbersOnly
        
        var name: String {
            switch self {
            case .classic: return "Classic"
            case .minimal: return "Minimal"
            case .pastel: return "Pastel"
            case .chunky: return "Chunky"
            case .numbersOnly: return "Numbers Only"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Show selected watch face only
                Group {
                    switch selectedWatchFace {
                    case 0:
                        classicThemeView
                    case 1:
                        minimalThemeView
                    case 2:
                        pastelThemeView
                    case 3:
                        chunkyThemeView
                    case 4:
                        numbersOnlyThemeView
                    default:
                        classicThemeView
                    }
                }
            }
            .navigationTitle("iHeartMon")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                // Settings icon positioned on the left (where history icon was)
                VStack {
                    HStack {
                        // Settings icon (left - moved from right)
                        NavigationLink(destination: SettingsView(heartRateManager: heartRateManager)) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, 16)
                        .padding(.top, -25)
                        
                        Spacer()
                    }
                    Spacer()
                }
                , alignment: .top
            )
            .onAppear {
                pulseAnimation = true
            }
            .overlay(
                // Alert overlay
                Group {
                    if heartRateManager.showAlert {
                        ZStack {
                            // Dim background for major alerts
                            if heartRateManager.alertMessage.contains("Major") {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        heartRateManager.dismissAlert()
                                    }
                            }
                            
                            VStack {
                                VStack(spacing: 8) {
                                    // Warning icon for major alerts
                                    if heartRateManager.alertMessage.contains("Heart Rate Change") {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    Text(heartRateManager.alertMessage)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    // Tap to dismiss text for major alerts
                                    if heartRateManager.alertMessage.contains("Heart Rate Change") {
                                        Text("Tap to dismiss")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(.top, 2)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(heartRateManager.alertMessage.contains("Heart Rate Change") ? 
                                              Color.red : Color.orange.opacity(0.9))
                                )
                                .onTapGesture {
                                    heartRateManager.dismissAlert()
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding(.top, 40)
                        }
                    }
                }
            )
            .animation(.easeInOut(duration: 0.3), value: heartRateManager.showAlert)
        }
    }
    
    private var heartRateColor: Color {
        let heartRate = heartRateManager.currentHeartRate
        let theme = colorThemes[selectedColorTheme]
        
        if heartRate == 0 {
            return theme.noReadingColor
        } else if heartRate < 80 {
            return theme.lowColor
        } else if heartRate >= 80 && heartRate <= 120 {
            return theme.normalColor
        } else if heartRate > 120 && heartRate <= 150 {
            return theme.elevatedColor
        } else {
            return theme.highColor
        }
    }
    
    private var isRainbowTheme: Bool {
        return selectedColorTheme == 3 // Rainbow theme index
    }
    
    private var isPastelRainbowTheme: Bool {
        return selectedColorTheme == 5 // Pastel Rainbow theme index
    }
    
    private var rainbowGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 1.0, green: 0.0, blue: 0.0),   // Red
                Color(red: 1.0, green: 0.5, blue: 0.0),   // Orange  
                Color(red: 1.0, green: 1.0, blue: 0.0),   // Yellow
                Color(red: 0.0, green: 1.0, blue: 0.0),   // Green
                Color(red: 0.0, green: 0.0, blue: 1.0),   // Blue
                Color(red: 0.5, green: 0.0, blue: 1.0)    // Purple
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var pastelRainbowGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.9, green: 0.85, blue: 1.0),  // Soft purple
                Color(red: 0.8, green: 0.9, blue: 1.0),   // Soft blue
                Color(red: 0.85, green: 0.95, blue: 0.8), // Soft green
                Color(red: 1.0, green: 0.9, blue: 0.7),   // Soft yellow
                Color(red: 1.0, green: 0.85, blue: 0.8),  // Soft orange
                Color(red: 1.0, green: 0.8, blue: 0.85)   // Soft pink
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var pastelHeartRateColor: Color {
        return heartRateColor // Now just use the same theme-based color
    }
    
    private var heartRateTextColor: Color {
        let theme = colorThemes[selectedColorTheme]
        
        // For light-colored themes, use black text for better visibility
        if selectedColorTheme == 2 || selectedColorTheme == 3 || selectedColorTheme == 5 || selectedColorTheme == 6 || selectedColorTheme == 7 || selectedColorTheme == 8 || selectedColorTheme == 9 || selectedColorTheme == 10 || selectedColorTheme == 12 { 
            // Monochrome, Rainbow, Pastel Rainbow, Pastel, Pinks, Forest, Fire, Sunshine, Sunset
            return .black
        } else {
            return .white // Default white text for dark themes (Classic, Pretty, Ocean, Midnight)
        }
    }
    
    private var heartBeatDuration: Double {
        let heartRate = heartRateManager.currentHeartRate
        
        if heartRate > 0 {
            return 60.0 / Double(heartRate)
        } else {
            return 1.0
        }
    }
    
    // MARK: - Theme Views
    
    private var classicThemeView: some View {
        ZStack {
            // Classic theme - current design
            ZStack {
                if isRainbowTheme {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 140))
                        .foregroundStyle(rainbowGradient)
                        .modifier(PulseEffect())
                } else if isPastelRainbowTheme {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 140))
                        .foregroundStyle(pastelRainbowGradient)
                        .modifier(PulseEffect())
                } else {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 140))
                        .foregroundColor(heartRateColor)
                        .modifier(PulseEffect())
                }
                
                VStack(spacing: 2) {
                    Text("\(heartRateManager.currentHeartRate)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(heartRateTextColor)
                    
                    Text("BPM")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(heartRateTextColor.opacity(0.8))
                }
            }
            .offset(y: 15)
            
            // Delta indicator
            if abs(heartRateManager.heartRateDelta) >= 30 {
                VStack(spacing: 2) {
                    Text("\(heartRateManager.heartRateDelta > 0 ? "↑" : "↓")")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(heartRateManager.heartRateDelta > 0 ? .red : .green)
                    Text("\(abs(heartRateManager.heartRateDelta))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .offset(x: 85, y: -20)
            }
        }
    }
    
    private var minimalThemeView: some View {
        ZStack {
            VStack(spacing: 15) {
                // Medium heart with numbers inside
                ZStack {
                    if isRainbowTheme {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(rainbowGradient)
                            .modifier(PulseEffect())
                    } else if isPastelRainbowTheme {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(pastelRainbowGradient)
                            .modifier(PulseEffect())
                    } else {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 100))
                            .foregroundColor(heartRateColor)
                            .modifier(PulseEffect())
                    }
                    
                    VStack(spacing: 2) {
                        Text("\(heartRateManager.currentHeartRate)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(heartRateTextColor)
                        
                        Text("BPM")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(heartRateTextColor.opacity(0.8))
                    }
                }
                
                // Status text below
                Text(heartRateStatus)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(heartRateColor)
                    .multilineTextAlignment(.center)
            }
            
            // Delta indicator to the right
            if abs(heartRateManager.heartRateDelta) >= 30 {
                VStack(spacing: 2) {
                    Text("\(heartRateManager.heartRateDelta > 0 ? "↑" : "↓")")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(heartRateManager.heartRateDelta > 0 ? .red : .green)
                    Text("\(abs(heartRateManager.heartRateDelta))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .offset(x: 65, y: -20)
            }
        }
    }
    
    private var pastelThemeView: some View {
        VStack(spacing: 20) {
            // Pastel - Apple-style soft colors
            if isRainbowTheme {
                Text("\(heartRateManager.currentHeartRate)")
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .foregroundStyle(rainbowGradient)
            } else if isPastelRainbowTheme {
                Text("\(heartRateManager.currentHeartRate)")
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .foregroundStyle(pastelRainbowGradient)
            } else {
                Text("\(heartRateManager.currentHeartRate)")
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .foregroundColor(pastelHeartRateColor)
            }
            
            if isRainbowTheme {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(rainbowGradient)
                    .modifier(PulseEffect())
            } else if isPastelRainbowTheme {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(pastelRainbowGradient)
                    .modifier(PulseEffect())
            } else {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(pastelHeartRateColor)
                    .modifier(PulseEffect())
            }
        }
    }
    
    private var chunkyThemeView: some View {
        VStack(spacing: 12) {
            // Time at top (chunky style)
            if isRainbowTheme {
                Text(currentTimeString)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(rainbowGradient)
            } else if isPastelRainbowTheme {
                Text(currentTimeString)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(pastelRainbowGradient)
            } else {
                Text(currentTimeString)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundColor(pastelHeartRateColor)
            }
            
            // Large heart rate without circle
            VStack(spacing: 4) {
                if isRainbowTheme {
                    Text("\(heartRateManager.currentHeartRate)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(rainbowGradient)
                } else if isPastelRainbowTheme {
                    Text("\(heartRateManager.currentHeartRate)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(pastelRainbowGradient)
                } else {
                    Text("\(heartRateManager.currentHeartRate)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(pastelHeartRateColor)
                }
                    
                    // Trend arrows
                    HStack(spacing: 4) {
                        if heartRateManager.heartRateDelta > 10 {
                            if isRainbowTheme {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(rainbowGradient)
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(rainbowGradient)
                            } else {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(pastelHeartRateColor)
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(pastelHeartRateColor)
                            }
                        } else if heartRateManager.heartRateDelta > 0 {
                            if isRainbowTheme {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(rainbowGradient)
                            } else {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(pastelHeartRateColor)
                            }
                        } else if heartRateManager.heartRateDelta < -10 {
                            if isRainbowTheme {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(rainbowGradient)
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(rainbowGradient)
                            } else {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(pastelHeartRateColor)
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(pastelHeartRateColor)
                            }
                        } else if heartRateManager.heartRateDelta < 0 {
                            if isRainbowTheme {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(rainbowGradient)
                            } else {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(pastelHeartRateColor)
                            }
                        } else {
                            if isRainbowTheme {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(rainbowGradient)
                            } else {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(pastelHeartRateColor)
                            }
                        }
                    }
            }
        }
    }
    
    private var numbersOnlyThemeView: some View {
        VStack {
            // Large numbers only - no heart, no BPM, just numbers
            if isRainbowTheme {
                Text("\(heartRateManager.currentHeartRate)")
                    .font(.system(size: 90, weight: .thin, design: .rounded))
                    .foregroundStyle(rainbowGradient)
            } else if isPastelRainbowTheme {
                Text("\(heartRateManager.currentHeartRate)")
                    .font(.system(size: 90, weight: .thin, design: .rounded))
                    .foregroundStyle(pastelRainbowGradient)
            } else {
                Text("\(heartRateManager.currentHeartRate)")
                    .font(.system(size: 90, weight: .thin, design: .rounded))
                    .foregroundColor(pastelHeartRateColor)
            }
        }
    }
    
    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    
    
    
    private var heartRateStatus: String {
        let heartRate = heartRateManager.currentHeartRate
        
        if heartRate == 0 {
            return "Measuring..."
        } else if heartRate < 60 {
            return "Low - Resting"
        } else if heartRate >= 60 && heartRate < 80 {
            return "Normal - Resting"
        } else if heartRate >= 80 && heartRate <= 120 {
            return "Normal - Active"
        } else if heartRate > 120 && heartRate <= 150 {
            return "Elevated"
        } else if heartRate > 150 && heartRate <= 180 {
            return "High - Exercise"
        } else {
            return "Very High"
        }
    }
}

struct PulseEffect: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            }
    }
}


#Preview {
    HeartRateView()
}
