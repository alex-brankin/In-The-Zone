//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The SettingsManager class manages user settings related to step
// counts and notifications, interfacing with HealthKit and UserNotifications frameworks. It provides functionality
// to fetch and handle step count data from HealthKit, request user permissions for notifications, and send
// notifications based on step goals. 

import Foundation
import HealthKit
import UserNotifications

class SettingsManager: ObservableObject {
    @Published var stepCount: Double?
    @Published var error: CustomError?
    
    private var healthKitManager = HealthKitManager()
    
    func fetchStepCount() {
        healthKitManager.fetchStepCount { stepCount, _, error in
            self.stepCount = stepCount
            if let error = error {
                self.error = CustomError(error: error)
            } else {
                self.error = nil
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
                self.scheduleStepGoalNotifications()
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
                self.error = CustomError(error: error)
            }
        }
    }
    
    func scheduleStepGoalNotifications() {

    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func compareStepCountWithGoal(_ stepCount: Double, goal: Double) {
        if stepCount >= goal {
            sendNotification(title: "Step Goal Achieved", body: "Congratulations! You have achieved your step goal.")
        } else if stepCount >= goal * 0.5 {
            sendNotification(title: "Halfway to Step Goal", body: "You are halfway towards your step goal.")
        }
    }
    
    func isValidStepGoal(_ input: String) -> Bool {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: input) != nil
    }
    
    func isValidHeartRate(_ input: String) -> Bool {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: input) != nil
    }
}

struct CustomError: Error, Equatable {
    let error: Error
    
    static func == (lhs: CustomError, rhs: CustomError) -> Bool {
        return lhs.error.localizedDescription == rhs.error.localizedDescription
    }
}
