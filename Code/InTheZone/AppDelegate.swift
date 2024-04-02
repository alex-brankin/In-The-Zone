//
//  AppDelegate.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//

import Foundation
import HealthKit
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        requestHealthKitAuthorization()
        return true
    }

    func requestHealthKitAuthorization() {
        let healthStore = HKHealthStore()
        let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        
        healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
            if !success {
                
            }
        }
    }
}

