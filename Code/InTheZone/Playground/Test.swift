//
//  Test.swift
//  InTheZone
//
//  Created by Alex Brankin on 13/04/2024.
//

import SwiftUI
import UserNotifications

struct TestView: View {
    var body: some View {
        VStack {
            Button("Request Notification Permission") {
                requestNotificationPermission()
            }
            Button("Schedule Notification") {
                scheduleNotification()
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Local Notification"
        content.body = "This is a test local notification."
        
        // Set the notification to trigger 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
