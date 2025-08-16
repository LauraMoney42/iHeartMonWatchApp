//
//  ContentView.swift
//  iHeartMon
//
//  Created by Laura Money on 8/16/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "applewatch")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("iHeartMon")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Apple Watch App")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Open the iHeartMon app on your Apple Watch to monitor your heart rate in real-time.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}