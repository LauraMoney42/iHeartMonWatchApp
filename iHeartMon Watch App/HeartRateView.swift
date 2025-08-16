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
    @State private var currentTheme = 0
    
    enum Theme: CaseIterable {
        case classic
        case minimal
        case simple
        case numeric
        
        var name: String {
            switch self {
            case .classic: return "Classic"
            case .minimal: return "Minimal"
            case .simple: return "Simple"
            case .numeric: return "Numeric"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Swipeable theme views
                TabView(selection: $currentTheme) {
                    classicThemeView
                        .tag(0)
                    
                    minimalThemeView
                        .tag(1)
                    
                    simpleThemeView
                        .tag(2)
                    
                    numericThemeView
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle())
                
                // History button - Top left corner (always visible)
                VStack {
                    HStack {
                        NavigationLink(destination: HistoryView(heartRateManager: heartRateManager)) {
                            Image(systemName: "clock")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, 0)
                        .padding(.top, -20)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .navigationTitle("iHeartMon")
            .navigationBarTitleDisplayMode(.inline)
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
        
        if heartRate == 0 {
            return .gray
        } else if heartRate < 80 {
            return .blue
        } else if heartRate >= 80 && heartRate <= 120 {
            return .green
        } else if heartRate > 120 && heartRate <= 150 {
            return .yellow
        } else {
            return .red
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
                Image(systemName: "heart.fill")
                    .font(.system(size: 140))
                    .foregroundColor(heartRateColor)
                    .modifier(PulseEffect())
                
                VStack(spacing: 2) {
                    Text("\(heartRateManager.currentHeartRate)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("BPM")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
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
                    Image(systemName: "heart.fill")
                        .font(.system(size: 100))
                        .foregroundColor(heartRateColor)
                        .modifier(PulseEffect())
                    
                    VStack(spacing: 2) {
                        Text("\(heartRateManager.currentHeartRate)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("BPM")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
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
    
    private var simpleThemeView: some View {
        VStack(spacing: 20) {
            // Simple - just the large number
            Text("\(heartRateManager.currentHeartRate)")
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .foregroundColor(heartRateColor)
            
            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundColor(heartRateColor)
                .modifier(PulseEffect())
        }
    }
    
    private var numericThemeView: some View {
        VStack(spacing: 15) {
            // Numeric - digital display style
            HStack(spacing: 4) {
                ForEach(Array(String(format: "%03d", heartRateManager.currentHeartRate)), id: \.self) { digit in
                    Text(String(digit))
                        .font(.system(size: 48, weight: .heavy, design: .monospaced))
                        .foregroundColor(heartRateColor)
                        .frame(width: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
            }
            
            HStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(heartRateColor)
                    .modifier(PulseEffect())
                
                Text("BPM")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }
            
            if abs(heartRateManager.heartRateDelta) != 0 {
                Text("\(heartRateManager.heartRateDelta > 0 ? "+" : "")\(heartRateManager.heartRateDelta)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(heartRateManager.heartRateDelta > 0 ? .red : .green)
            }
        }
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
