//
//  ComplicationController.swift
//  iHeartMon Watch App
//
//  Created by Laura Money on 8/16/25.
//

import SwiftUI
import WidgetKit
import ClockKit

struct ComplicationController: Widget {
    let kind: String = "iHeartMonComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComplicationEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Heart Rate")
        .description("Display your current heart rate")
        .supportedFamilies(supportedFamilies)
    }
    
    private var supportedFamilies: [WidgetFamily] {
        [
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner
        ]
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), heartRate: 72, color: .green)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), heartRate: 72, color: .green)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let heartRateManager = HeartRateManager()
            let heartRate = heartRateManager.currentHeartRate
            let color = getColorForHeartRate(heartRate)
            
            let entry = SimpleEntry(date: Date(), heartRate: heartRate, color: color)
            let nextUpdateDate = Date().addingTimeInterval(60) // Update every minute
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    private func getColorForHeartRate(_ heartRate: Int) -> Color {
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
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let heartRate: Int
    let color: Color
}

struct ComplicationEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularView
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryInline:
            accessoryInlineView
        case .accessoryCorner:
            accessoryCornerView
        @unknown default:
            accessoryCircularView
        }
    }
    
    private var accessoryCircularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(entry.color)
                
                Text("\(entry.heartRate)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("BPM")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var accessoryRectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundColor(entry.color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Heart Rate")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                
                HStack(alignment: .bottom, spacing: 2) {
                    Text("\(entry.heartRate)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("BPM")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
    }
    
    private var accessoryInlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .foregroundColor(entry.color)
            Text("\(entry.heartRate) BPM")
        }
    }
    
    private var accessoryCornerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Image(systemName: "heart.fill")
                .font(.system(size: 12))
                .foregroundColor(entry.color)
            
            Text("\(entry.heartRate)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview(as: .accessoryCircular) {
    ComplicationController()
} timeline: {
    SimpleEntry(date: .now, heartRate: 72, color: .green)
    SimpleEntry(date: .now, heartRate: 95, color: .green)
    SimpleEntry(date: .now, heartRate: 135, color: .yellow)
    SimpleEntry(date: .now, heartRate: 165, color: .red)
}