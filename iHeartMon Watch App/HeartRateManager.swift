//
//  HeartRateManager.swift
//  iHeartMon Watch App
//
//  Created by Laura Money on 8/16/25.
//

import Foundation
import HealthKit
import WatchKit

class HeartRateManager: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    @Published var currentHeartRate: Int = 0
    @Published var heartRateHistory: [HeartRateReading] = []
    @Published var isAuthorized = false
    @Published var isMonitoring = false
    @Published var heartRateDelta: Int = 0
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var significantChanges: [SignificantChange] = []
    
    private let maxHistoryDuration: TimeInterval = 3600 // 60 minutes
    private var previousHeartRate: Int = 0
    private var baselineHeartRate: Int = 0
    private var lastAlertTime = Date()
    
    // Alert thresholds
    private let minorChangeThreshold = 30  // Alert for 30 bpm change
    private let majorChangeThreshold = 50  // Alert for 50 bpm change
    private let alertCooldown: TimeInterval = 30 // Don't repeat alerts for 30 seconds
    
    struct HeartRateReading: Identifiable {
        let id = UUID()
        let heartRate: Int
        let timestamp: Date
        
        var color: String {
            if heartRate < 80 {
                return "blue"
            } else if heartRate >= 80 && heartRate <= 120 {
                return "green"
            } else if heartRate > 120 && heartRate <= 150 {
                return "yellow"
            } else {
                return "red"
            }
        }
    }
    
    struct SignificantChange: Identifiable {
        let id = UUID()
        let timestamp: Date
        let fromRate: Int
        let toRate: Int
        let delta: Int
        let isMajor: Bool // true if 50+ bpm change
        
        var description: String {
            "\(delta > 0 ? "↑" : "↓") \(abs(delta)) BPM"
        }
    }
    
    override init() {
        super.init()
        requestAuthorization()
        
        #if DEBUG && targetEnvironment(simulator)
        // Add test data for simulator testing
        addTestData()
        #endif
    }
    
    #if DEBUG
    private var simulationTimer: Timer?
    
    private func addTestData() {
        let testRates = [72, 85, 93, 110, 125, 145, 160, 135, 95, 78]
        for (index, rate) in testRates.enumerated() {
            let reading = HeartRateReading(
                heartRate: rate, 
                timestamp: Date().addingTimeInterval(-Double(index * 60))
            )
            heartRateHistory.append(reading)
        }
        currentHeartRate = testRates.first ?? 72
        
        // Simulate changing heart rate every 5 seconds for testing color themes
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let randomRate = Int.random(in: 60...180)
            DispatchQueue.main.async {
                self.updateHeartRate(randomRate)
                let reading = HeartRateReading(heartRate: randomRate, timestamp: Date())
                self.heartRateHistory.append(reading)
                self.cleanupHistory()
            }
        }
    }
    
    deinit {
        simulationTimer?.invalidate()
    }
    #endif
    
    func requestAuthorization() {
        let typesToRead: Set = [heartRateQuantityType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.startMonitoring()
                }
            }
        }
    }
    
    func startMonitoring() {
        guard isAuthorized, !isMonitoring else { return }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-maxHistoryDuration),
            end: nil,
            options: .strictStartDate
        )
        
        heartRateQuery = HKAnchoredObjectQuery(
            type: heartRateQuantityType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        heartRateQuery?.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        if let query = heartRateQuery {
            healthStore.execute(query)
            isMonitoring = true
        }
        
        // Start workout session for continuous heart rate monitoring
        startWorkoutSession()
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        if let query = heartRateQuery {
            healthStore.stop(query)
        }
        
        stopWorkoutSession()
        isMonitoring = false
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for sample in heartRateSamples {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = Int(sample.quantity.doubleValue(for: heartRateUnit))
                
                let reading = HeartRateReading(heartRate: heartRate, timestamp: sample.endDate)
                
                // Update current heart rate
                if sample.endDate > Date().addingTimeInterval(-10) {
                    self.updateHeartRate(heartRate)
                }
                
                // Add to history
                self.heartRateHistory.append(reading)
            }
            
            // Clean up old history entries
            self.cleanupHistory()
        }
    }
    
    private func updateHeartRate(_ newRate: Int) {
        // Store previous rate
        if currentHeartRate > 0 {
            previousHeartRate = currentHeartRate
        }
        
        // Update current rate
        currentHeartRate = newRate
        
        // Set baseline if not set
        if baselineHeartRate == 0 && newRate > 0 {
            baselineHeartRate = newRate
        }
        
        // Calculate delta from previous reading
        if previousHeartRate > 0 {
            heartRateDelta = newRate - previousHeartRate
            
            // Check for significant changes
            checkForSignificantChange(newRate)
        }
    }
    
    private func checkForSignificantChange(_ currentRate: Int) {
        let absoluteDelta = abs(heartRateDelta)
        
        // Record significant changes (30+ bpm)
        if absoluteDelta >= minorChangeThreshold {
            let change = SignificantChange(
                timestamp: Date(),
                fromRate: previousHeartRate,
                toRate: currentRate,
                delta: heartRateDelta,
                isMajor: absoluteDelta >= majorChangeThreshold
            )
            significantChanges.append(change)
            
            // Keep only last 50 changes
            if significantChanges.count > 50 {
                significantChanges.removeFirst()
            }
        }
        
        // Don't alert too frequently
        guard Date().timeIntervalSince(lastAlertTime) > alertCooldown else { return }
        
        if absoluteDelta >= majorChangeThreshold {
            // Major change (50+ bpm)
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            timeFormatter.locale = Locale.current
            let timestamp = timeFormatter.string(from: Date())
            
            triggerAlert(
                message: "Heart Rate Change\n\(heartRateDelta > 0 ? "+" : "")\(heartRateDelta) BPM at \(timestamp)",
                severity: .major
            )
        } else if absoluteDelta >= minorChangeThreshold {
            // Minor change (30+ bpm)
            triggerAlert(
                message: "HR Change: \(heartRateDelta > 0 ? "+" : "")\(heartRateDelta) BPM",
                severity: .minor
            )
        }
    }
    
    private func triggerAlert(message: String, severity: AlertSeverity) {
        alertMessage = message
        showAlert = true
        lastAlertTime = Date()
        
        // Haptic feedback
        switch severity {
        case .minor:
            WKInterfaceDevice.current().play(.notification)
            // Auto-dismiss minor alerts after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.showAlert = false
            }
        case .major:
            WKInterfaceDevice.current().play(.retry)
            // Major alerts stay until user dismisses
        }
    }
    
    func dismissAlert() {
        showAlert = false
    }
    
    enum AlertSeverity {
        case minor
        case major
    }
    
    private func cleanupHistory() {
        let cutoffDate = Date().addingTimeInterval(-maxHistoryDuration)
        heartRateHistory = heartRateHistory.filter { $0.timestamp > cutoffDate }
    }
    
    // MARK: - Workout Session Management
    
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
    private func startWorkoutSession() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            workoutSession?.delegate = self
            workoutBuilder?.delegate = self
            
            let startDate = Date()
            workoutSession?.startActivity(with: startDate)
            workoutBuilder?.beginCollection(withStart: startDate) { success, error in
                if !success {
                    print("Failed to begin workout collection: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } catch {
            print("Failed to start workout session: \(error.localizedDescription)")
        }
    }
    
    private func stopWorkoutSession() {
        workoutSession?.end()
        workoutBuilder?.endCollection(withEnd: Date()) { success, error in
            self.workoutBuilder?.finishWorkout { workout, error in
                DispatchQueue.main.async {
                    self.workoutSession = nil
                    self.workoutBuilder = nil
                }
            }
        }
    }
    
    // MARK: - Complication Support
    
    func getLatestHeartRateForComplication() -> Int {
        return currentHeartRate
    }
    
    func getHeartRateColor() -> String {
        if currentHeartRate < 80 {
            return "blue"
        } else if currentHeartRate >= 80 && currentHeartRate <= 120 {
            return "green"
        } else if currentHeartRate > 120 && currentHeartRate <= 150 {
            return "yellow"
        } else {
            return "red"
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

extension HeartRateManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Handle state changes if needed
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension HeartRateManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events if needed
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        // Data collection handled by the anchored object query
    }
}
