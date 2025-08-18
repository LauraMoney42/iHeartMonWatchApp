//
//  SettingsView.swift
//  iHeartMon Watch App
//
//  Created by Claude on 8/18/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var heartRateManager: HeartRateManager
    @AppStorage("selectedColorTheme") private var selectedColorTheme = 0
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
    
    var body: some View {
        NavigationStack {
            List {
                // Watch Faces Section
                Section {
                    NavigationLink(destination: WatchFacesView(selectedWatchFace: $selectedWatchFace)) {
                        HStack {
                            Image(systemName: "applewatch")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            Text("Watch Faces")
                        }
                    }
                    
                    NavigationLink(destination: ThemesView(selectedColorTheme: $selectedColorTheme, colorThemes: colorThemes)) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Themes")
                        }
                    }
                    
                    // History Section
                    NavigationLink(destination: HistoryView(heartRateManager: heartRateManager)) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Text("History")
                        }
                    }
                    
                    // About Section
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            Text("About")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Watch Faces View (Direct Preview)
struct WatchFacesView: View {
    @Binding var selectedWatchFace: Int
    
    var body: some View {
        WatchFacePreviewView(selectedWatchFace: $selectedWatchFace)
    }
}

// MARK: - Watch Face Preview View
struct WatchFacePreviewView: View {
    @Binding var selectedWatchFace: Int
    @StateObject private var heartRateManager = HeartRateManager()
    @State private var currentPreviewFace = 0
    @AppStorage("selectedColorTheme") private var selectedColorTheme = 3
    
    var body: some View {
        VStack(spacing: 0) {
            // Face preview with TabView (much larger)
            TabView(selection: $currentPreviewFace) {
                ForEach(0..<5, id: \.self) { index in
                    PreviewFaceView(
                        faceIndex: index,
                        heartRateManager: heartRateManager,
                        selectedColorTheme: selectedColorTheme
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(maxHeight: .infinity)
            
            // Push button to bottom with spacer
            Spacer()
            
            // Smaller select button at bottom
            Button(action: {
                selectedWatchFace = currentPreviewFace
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text("Select")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 0)
        }
        .navigationTitle("Watch Faces")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            currentPreviewFace = selectedWatchFace
        }
    }
}

// MARK: - Preview Face View (simplified version of watch faces)
struct PreviewFaceView: View {
    let faceIndex: Int
    @ObservedObject var heartRateManager: HeartRateManager
    let selectedColorTheme: Int
    
    // Simplified color themes for preview (just need the basic colors)
    private let colorThemes: [ColorTheme] = [
        ColorTheme(name: "Classic", lowColor: .blue, normalColor: .green, elevatedColor: .yellow, highColor: .red, noReadingColor: .gray),
        ColorTheme(name: "Pretty", lowColor: .cyan, normalColor: .purple, elevatedColor: .pink, highColor: .pink, noReadingColor: .gray),
        ColorTheme(name: "Monochrome", lowColor: .white, normalColor: .white, elevatedColor: .white, highColor: .white, noReadingColor: .gray),
        ColorTheme(name: "Rainbow", lowColor: Color(red: 0.0, green: 0.4, blue: 1.0), normalColor: Color(red: 0.0, green: 0.9, blue: 0.0), elevatedColor: Color(red: 1.0, green: 0.6, blue: 0.0), highColor: Color(red: 1.0, green: 0.0, blue: 0.4), noReadingColor: Color(red: 0.6, green: 0.0, blue: 1.0)),
        ColorTheme(name: "Ocean", lowColor: .cyan, normalColor: .mint, elevatedColor: .blue, highColor: .indigo, noReadingColor: .gray)
    ]
    
    private var heartRateColor: Color {
        let heartRate = heartRateManager.currentHeartRate
        let theme = colorThemes[min(selectedColorTheme, colorThemes.count - 1)]
        
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
    
    var body: some View {
        VStack {
            Spacer()
            
            // Face content (larger)
            Group {
                switch faceIndex {
                case 0: classicPreview
                case 1: minimalPreview
                case 2: pastelPreview
                case 3: chunkyPreview
                case 4: numbersOnlyPreview
                default: classicPreview
                }
            }
            
            Spacer()
            
            // Small face name at bottom
            Text(faceName)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.bottom, 4)
        }
    }
    
    private var faceName: String {
        ["Classic", "Minimal", "Pastel", "Chunky", "Numbers Only"][faceIndex]
    }
    
    private var classicPreview: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 80))
                .foregroundColor(heartRateColor)
            
            VStack(spacing: 1) {
                Text("\(heartRateManager.currentHeartRate)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("BPM")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var minimalPreview: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(heartRateColor)
                
                VStack(spacing: 1) {
                    Text("\(heartRateManager.currentHeartRate)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("BPM")
                        .font(.system(size: 6))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Text("Normal - Active")
                .font(.system(size: 10))
                .foregroundColor(heartRateColor)
        }
    }
    
    private var pastelPreview: some View {
        VStack(spacing: 12) {
            Text("\(heartRateManager.currentHeartRate)")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(heartRateColor)
            
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundColor(heartRateColor)
        }
    }
    
    private var chunkyPreview: some View {
        VStack(spacing: 8) {
            Text(currentTimeString)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(heartRateColor)
            
            Text("\(heartRateManager.currentHeartRate)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(heartRateColor)
            
            Image(systemName: "minus")
                .font(.system(size: 12))
                .foregroundColor(heartRateColor)
        }
    }
    
    private var numbersOnlyPreview: some View {
        Text("\(heartRateManager.currentHeartRate)")
            .font(.system(size: 54, weight: .thin))
            .foregroundColor(heartRateColor)
    }
    
    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}


// MARK: - Themes View
struct ThemesView: View {
    @Binding var selectedColorTheme: Int
    let colorThemes: [ColorTheme]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Color Themes")
                    .font(.headline)
                    .padding(.top)
                
                VStack(spacing: 8) {
                    ForEach(0..<colorThemes.count, id: \.self) { index in
                        ThemeSelectionRow(
                            theme: colorThemes[index],
                            isSelected: selectedColorTheme == index,
                            onTap: {
                                selectedColorTheme = index
                            }
                        )
                    }
                }
                .padding(.horizontal, 8)
                
                // Preview of current theme
                VStack(spacing: 8) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        ThemePreviewDot(color: colorThemes[selectedColorTheme].lowColor, label: "Low")
                        ThemePreviewDot(color: colorThemes[selectedColorTheme].normalColor, label: "Normal")
                        ThemePreviewDot(color: colorThemes[selectedColorTheme].elevatedColor, label: "High")
                    }
                }
                .padding(.top)
            }
        }
        .navigationTitle("Themes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Icon/Logo area
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .padding(.top, 20)
                
                Text("iHeartMon")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Heart Rate Monitor")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                VStack(spacing: 12) {
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Monitor your heart rate with beautiful themes and customizable watch faces.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ColorTheme {
    let name: String
    let lowColor: Color
    let normalColor: Color
    let elevatedColor: Color
    let highColor: Color
    let noReadingColor: Color
}

struct ThemeSelectionRow: View {
    let theme: ColorTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(theme.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Circle().fill(theme.lowColor).frame(width: 12, height: 12)
                    Circle().fill(theme.normalColor).frame(width: 12, height: 12)
                    Circle().fill(theme.elevatedColor).frame(width: 12, height: 12)
                    Circle().fill(theme.highColor).frame(width: 12, height: 12)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(isSelected ? 0.3 : 0.15))
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}

struct ThemePreviewDot: View {
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    SettingsView(heartRateManager: HeartRateManager())
}
