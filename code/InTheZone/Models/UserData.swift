//
//  UserData.swift
//  InTheZone
//
//  Created by Alex Brankin on 19/04/2024.
//

import Foundation

//https://www.healthline.com/health/heart-health/heart-rate-zones-workout#heart-rate-zones

class UserData: ObservableObject {
    @Published var name: String {
        didSet {
            UserDefaults.standard.set(name, forKey: "userName")
        }
    }
    
    @Published var age: String {
        willSet {
            if newValue != age { // Check if the new value is different from the current value
                calculateMaxHeartRate()
            }
        }
        didSet {
            UserDefaults.standard.set(age, forKey: "userAge")
            calculateAge()
        }
    }

    
    @Published var dateOfBirth: Date {
        didSet {
            UserDefaults.standard.set(dateOfBirth, forKey: "userDateOfBirth")
            calculateAge()
            calculateMaxHeartRate()
        }
    }
    
    @Published var calculatedAge: Int = 0
    @Published var maxHeartRate: Int
    @Published var calculatedMaxHeartRate: Int = 0 // Constant calculated max heart rate
    
    init() {
        self.name = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.age = UserDefaults.standard.string(forKey: "userAge") ?? ""
        self.dateOfBirth = UserDefaults.standard.object(forKey: "userDateOfBirth") as? Date ?? Date()
        self.maxHeartRate = 0 // Initialize maxHeartRate with default value
        
        // Calculate age and max heart rate
        calculateAge()
        calculateMaxHeartRate()
        self.maxHeartRate = calculatedMaxHeartRate
        
        
    }

    
    func calculateAge() {
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        self.calculatedAge = ageComponents.year ?? 0
        print("Calculated age: \(calculatedAge)") // Print calculated age
    }
    
    func calculateMaxHeartRate() {
        self.calculatedMaxHeartRate = 220 - calculatedAge // Calculate max heart rate based on calculated age
        print("Calculated max heart rate: \(calculatedMaxHeartRate)") // Print calculated max heart rate
    }
    
    func calculateWorkoutZones() -> [String: ClosedRange<Double>] {
            let maxHeartRatePercentage = Double(calculatedMaxHeartRate) / 100.0
            
            let zone1 = 0.0...0.57 * maxHeartRatePercentage
            let zone2 = 0.57 * maxHeartRatePercentage...0.63 * maxHeartRatePercentage
            let zone3 = 0.64 * maxHeartRatePercentage...0.76 * maxHeartRatePercentage
            let zone4 = 0.77 * maxHeartRatePercentage...0.95 * maxHeartRatePercentage
            let zone5 = 0.96 * maxHeartRatePercentage...1.0
            
            let zones = [
                "Zone 1 (Very Light)": zone1,
                "Zone 2 (Light)": zone2,
                "Zone 3 (Vigorous)": zone3,
                "Zone 4 (High)": zone4,
                "Zone 5 (Maximal)": zone5
            ]
            
            return zones
        }
    }
