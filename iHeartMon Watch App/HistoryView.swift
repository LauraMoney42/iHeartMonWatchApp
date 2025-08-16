//
//  HistoryView.swift
//  iHeartMon Watch App
//
//  Created by Laura Money on 8/16/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var heartRateManager: HeartRateManager
    @State private var selectedTimeRange = TimeRange.tenMinutes
    
    enum TimeRange: String, CaseIterable {
        case fiveMinutes = "5 min"
        case tenMinutes = "10 min"
        case thirtyMinutes = "30 min"
        case sixtyMinutes = "60 min"
        
        var duration: TimeInterval {
            switch self {
            case .fiveMinutes: return 300
            case .tenMinutes: return 600
            case .thirtyMinutes: return 1800
            case .sixtyMinutes: return 3600
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)
                .padding(.horizontal)
                
                // Current Stats
                VStack(spacing: 10) {
                    HStack(spacing: 20) {
                        StatView(title: "Current", value: "\(heartRateManager.currentHeartRate)", color: currentColor)
                        StatView(title: "Average", value: "\(averageHeartRate)", color: .orange)
                    }
                    
                    HStack(spacing: 20) {
                        StatView(title: "Min", value: "\(minHeartRate)", color: .blue)
                        StatView(title: "Max", value: "\(maxHeartRate)", color: .red)
                    }
                }
                .padding(.horizontal)
                
                // Heart Rate Chart (Simplified for watchOS)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Readings")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if !filteredHistory.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(filteredHistory.suffix(10)) { reading in
                                    VStack(spacing: 4) {
                                        Text("\(reading.heartRate)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(colorForHeartRate(reading.heartRate))
                                        
                                        Text(formatTime(reading.timestamp))
                                            .font(.system(size: 8))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(6)
                                    .background(colorForHeartRate(reading.heartRate).opacity(0.2))
                                    .cornerRadius(6)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "heart")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            
                            Text("No data available")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Significant Changes (30+ BPM)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Significant Changes (30+ BPM)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if heartRateManager.significantChanges.isEmpty {
                        Text("No significant changes recorded")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.vertical, 10)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(heartRateManager.significantChanges.reversed()) { change in
                                    HStack {
                                        Circle()
                                            .fill(change.isMajor ? Color.red : Color.orange)
                                            .frame(width: 8, height: 8)
                                        
                                        Text(formatTime(change.timestamp))
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text("\(change.fromRate)→\(change.toRate)")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text(change.description)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(change.delta > 0 ? .red : .green)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 100)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Zone Distribution
                VStack(alignment: .leading, spacing: 8) {
                    Text("Zone Distribution")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ForEach(zoneDistribution, id: \.zone) { distribution in
                        HStack {
                            Circle()
                                .fill(distribution.color)
                                .frame(width: 10, height: 10)
                            
                            Text(distribution.zone)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(distribution.percentage)%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var filteredHistory: [HeartRateManager.HeartRateReading] {
        let cutoffDate = Date().addingTimeInterval(-selectedTimeRange.duration)
        return heartRateManager.heartRateHistory.filter { $0.timestamp > cutoffDate }
    }
    
    private var averageHeartRate: Int {
        guard !filteredHistory.isEmpty else { return 0 }
        let sum = filteredHistory.reduce(0) { $0 + $1.heartRate }
        return sum / filteredHistory.count
    }
    
    private var minHeartRate: Int {
        filteredHistory.min(by: { $0.heartRate < $1.heartRate })?.heartRate ?? 0
    }
    
    private var maxHeartRate: Int {
        filteredHistory.max(by: { $0.heartRate < $1.heartRate })?.heartRate ?? 0
    }
    
    private var chartYDomain: ClosedRange<Int> {
        let minValue = max(40, (minHeartRate - 10))
        let maxValue = min(200, (maxHeartRate + 10))
        return minValue...maxValue
    }
    
    private var currentColor: Color {
        colorForHeartRate(heartRateManager.currentHeartRate)
    }
    
    private func colorForHeartRate(_ heartRate: Int) -> Color {
        if heartRate < 80 {
            return .blue
        } else if heartRate >= 80 && heartRate <= 120 {
            return .green
        } else if heartRate > 120 && heartRate <= 150 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private var zoneDistribution: [(zone: String, color: Color, percentage: Int)] {
        guard !filteredHistory.isEmpty else {
            return [
                (zone: "Rest (<80)", color: .blue, percentage: 0),
                (zone: "Normal (80-120)", color: .green, percentage: 0),
                (zone: "Elevated (120-150)", color: .yellow, percentage: 0),
                (zone: "High (>150)", color: .red, percentage: 0)
            ]
        }
        
        let total = filteredHistory.count
        let restCount = filteredHistory.filter { $0.heartRate < 80 }.count
        let normalCount = filteredHistory.filter { $0.heartRate >= 80 && $0.heartRate <= 120 }.count
        let elevatedCount = filteredHistory.filter { $0.heartRate > 120 && $0.heartRate <= 150 }.count
        let highCount = filteredHistory.filter { $0.heartRate > 150 }.count
        
        return [
            (zone: "Rest (<80)", color: .blue, percentage: (restCount * 100) / total),
            (zone: "Normal (80-120)", color: .green, percentage: (normalCount * 100) / total),
            (zone: "Elevated (120-150)", color: .yellow, percentage: (elevatedCount * 100) / total),
            (zone: "High (>150)", color: .red, percentage: (highCount * 100) / total)
        ]
    }
}

struct StatView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}