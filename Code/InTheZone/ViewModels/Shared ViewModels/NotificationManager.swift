//
//  NotificationManager.swift
//  InTheZone
//
//  Created by Alex Brankin on 2/05/2024.
//
// The NotificationManager class is a comprehensive manager in Swift that integrates HealthKit and UserNotifications
// to monitor and manage health data within an iOS app. Upon initialization, it sets itself as the notification
// center delegate, requests HealthKit authorization for workout data, and configures notification permissions. It
// employs an HKObserverQuery to listen for new workout data based on specific criteria and automatically triggers
// local notifications upon data updates. Additionally, the class ensures that notifications can present alerts, play
// sounds, and update badges when the app is in the foreground.

import SwiftUI
import HealthKit
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    private var healthStore = HKHealthStore()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self  // Set the notification center delegate
        requestHealthKitAuthorization()
        requestNotificationPermission()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .sound, .badge])
        }
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let typesToRead: Set = [HKObjectType.workoutType()]
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                self.setUpObserverQuery()
            } else {
                print("Authorization failed")
            }
        }
    }
    
    private func setUpObserverQuery() {
        let brandMetadataKey = "Brand"
        let predicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyWorkoutBrandName, allowedValues: ["InTheZone"])

        let observerQuery = HKObserverQuery(sampleType: HKObjectType.workoutType(), predicate: predicate) { _, completionHandler, _ in
            self.triggerLocalNotification()
            completionHandler()
        }
        
        self.healthStore.execute(observerQuery)
        self.healthStore.enableBackgroundDelivery(for: HKObjectType.workoutType(), frequency: .immediate, withCompletion: { success, error in
            if let error = error {
                print("Failed to enable background delivery: \(error.localizedDescription)")
            } else if success {
                print("Observer query successfully registered and background delivery enabled.")
            } else {
                print("Failed to enable background delivery with unknown error.")
            }
        })
    }

    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    private func triggerLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "In The Zone"
        content.body = "A new workout is ready for you to review."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
}

struct NotificationManager_Previews: PreviewProvider {
    static var previews: some View {
        Text("HealthKit Manager")
            .onAppear {
                let NotificationManager = NotificationManager()
                print("HealthKit Manager initialized")
            }
    }
}
