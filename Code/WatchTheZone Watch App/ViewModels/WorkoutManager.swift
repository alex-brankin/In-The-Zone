//
//  WorkoutManager.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 15/04/2024.
//
// The WorkoutManager class in the WatchTheZone Watch App acts as the central coordinator for
// managing fitness activities. It handles the setup and monitoring of workout sessions using
// HealthKit, including initiating workouts based on user-selected activity types and managing the
// workout session states through its integration with HKWorkoutSession and HKLiveWorkoutBuilder.
// The class also tracks real-time data such as heart rate, energy burned, and distance, updating
// these metrics dynamically during a workout. Additionally, it provides functionality to pause,
// resume, and end workouts, managing the workout lifecycle and responding to changes in workout
// state with appropriate UI updates. It utilizes environmental objects for zone management and user
// settings to enhance the workout experience with personalized settings and feedback mechanisms.

import Foundation
import HealthKit
import WatchKit
import SwiftUI
import Combine



class WorkoutManager: NSObject, ObservableObject {
    
    private var healthStore: HKHealthStore {
        HealthStoreManager.shared.healthStore
    }
    
    var selectedWorkout: HKWorkoutActivityType?
    {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            startWorkout(workoutType: selectedWorkout)
        }
    }
    
    var targetZone: Int = 0
    
    let workoutUIManager = WorkoutUIManager()
    let zoneManager = ZoneManager()
    let userDefaultsManager = UserDefaultsManager()
    //  let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor
        
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            
            return
        }
        
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        
        session?.delegate = self
        builder?.delegate = self
        
        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            self.hapticTimer(start: true)
            
        }
        addWorkoutMetadata()
        
    }
    
    func addWorkoutMetadata() {
        print("In the function")
        let brand = "InTheZone"
        guard let builder = self.builder else {
            print("Builder is nil at metadata addition time.")
            return
        }
        
        let metadata: [String: String] = [
            HKMetadataKeyWorkoutBrandName: brand,
            "targetZone": String(targetZone),
            "zone1Min": String(userDefaultsManager.zone1Min),
            "zone1Max": String(userDefaultsManager.zone1Max),
            "zone2Min": String(userDefaultsManager.zone2Min),
            "zone2Max": String(userDefaultsManager.zone2Max),
            "zone3Min": String(userDefaultsManager.zone3Min),
            "zone3Max": String(userDefaultsManager.zone3Max),
            "zone4Min": String(userDefaultsManager.zone4Min),
            "zone4Max": String(userDefaultsManager.zone4Max),
            "zone5Min": String(userDefaultsManager.zone5Min),
            "zone5Max": String(userDefaultsManager.zone5Max)
        ]
        
        builder.addMetadata(metadata) { (success, error) in
            if let error = error {
                print("Error saving metadata: \(error.localizedDescription)")
            } else {
                print("Metadata saved successfully: \(success)")
                print(metadata)
            }
        }
    }
    
    // State Control
    
    // The workout session state.
    @Published var running = false
    
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
    
    func togglePause() {
        if running == true {
            pause()
        } else {
            resume()
        }
    }
    
    func endWorkout() {
        print("Ending workout")
        self.hapticTimer(start: false)
        session?.end()
        resetWorkout()
    }
    // Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?
    @Published var pace: String = ""
    @Published var currentZone: Int = 0
    @Published var onTarget: Bool = false
    @Published var formattedDistance: String = ""
    @Published var currentZoneMin: Int = 0
    @Published var currentZoneMax: Int = 0
    //Published var targetZone: Int = 0
    @Published var targetZoneMin: Int = 0
    @Published var targetZoneMax: Int = 0
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        DispatchQueue.main.async {[self] in
            
            let safeElapsedTime = builder?.elapsedTime ?? 0
            self.pace = workoutUIManager.getPace(elapsedTime: safeElapsedTime, distance: self.distance)
            self.currentZone = zoneManager.getCurrentZone(for: self.heartRate)
            self.onTarget = isOnTarget()
            self.formattedDistance = workoutUIManager.getFormattedDistance(distance: self.distance)
            self.currentZoneMin = zoneManager.getZoneBoundary(boundary: "min", zone: self.currentZone)
            self.currentZoneMax = zoneManager.getZoneBoundary(boundary: "max", zone: self.currentZone)
            self.targetZoneMin = zoneManager.getZoneBoundary(boundary: "min", zone: self.targetZone)
            self.targetZoneMax = zoneManager.getZoneBoundary(boundary: "max", zone: self.targetZone)
            
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }
    
    func resetWorkout() {
        print("Resetting workout")
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
        pace = ""
        currentZone = 0
        onTarget = false
        formattedDistance = ""
        currentZoneMin = 0
        currentZoneMax = 0
        targetZoneMin = 0
        targetZoneMax = 0
    
    }
    
    private func isOnTarget() -> Bool {
        if targetZone == self.currentZone
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    private var timer: Timer?    
    private func hapticTimer(start: Bool) {
        let hapticFeedbackEnabled: Bool = true
        let hapticFrequencyMinutes: Double = 1
        let hapticDelayMinutes: Double = 2
        
        // Manage the last feedback time
        var lastHapticFeedbackTime = Date()
        
        if start {
            // Dispatch the timer to a background queue
            DispatchQueue.global(qos: .background).async {
                self.timer = Timer(timeInterval: hapticFrequencyMinutes * 60, repeats: true) { _ in
                    DispatchQueue.main.async {
                        // Check the elapsed time on the main thread if needed
                        if self.builder!.elapsedTime.rounded() >= (hapticDelayMinutes * 60) {
                            if !self.onTarget && Date().timeIntervalSince(lastHapticFeedbackTime) >= (hapticFrequencyMinutes * 60) {
                                if hapticFeedbackEnabled {
                                    WKInterfaceDevice.current().play(.stop)
                                    lastHapticFeedbackTime = Date()
                                }
                            }
                        }
                    }
                }
                // Add the timer to the current run loop
                RunLoop.current.add(self.timer!, forMode: .common)
                RunLoop.current.run()
            }
        }  else {
            // Stop the timer
            timer?.invalidate()
            timer = nil
        }
    }
}



// HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {

    }
}
// HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}
