//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The UserData class in Swift is designed to manage user data for a fitness application. It leverages the
// @Published property wrapper for observable properties such as name, age, and dateOfBirth, which auto-save to
// UserDefaults upon changes, ensuring data persistence across app launches. The class also dynamically calculates
// and updates the user's age and maximum heart rate based on the date of birth and automatically configures heart
// rate zones. These zones are used for fitness tracking and are recalculated whenever the user's date of birth
// changes.

import Foundation

class UserData: ObservableObject {
    @Published var name: String {
        didSet {
            print("Setting userName to \(name)")
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
            setZoneValues()
        }
    }
    
    @Published var zone1Min: String {
        didSet {
            UserDefaults.standard.set(zone1Min, forKey: "zone1Min")
        }
    }
    @Published var zone1Max: String {
        didSet {
            UserDefaults.standard.set(zone1Max, forKey: "zone1Max")
        }
    }
    
    @Published var zone2Min: String {
        didSet {
            UserDefaults.standard.set(zone1Min, forKey: "zone1Min")
        }
    }
    @Published var zone2Max: String {
        didSet {
            UserDefaults.standard.set(zone1Max, forKey: "zone1Max")
        }
    }
    
    @Published var zone3Min: String {
        didSet {
            UserDefaults.standard.set(zone1Min, forKey: "zone1Min")
        }
    }
    @Published var zone3Max: String {
        didSet {
            UserDefaults.standard.set(zone1Max, forKey: "zone1Max")
        }
    }
    
    @Published var zone4Min: String {
        didSet {
            UserDefaults.standard.set(zone1Min, forKey: "zone1Min")
        }
    }
    @Published var zone4Max: String {
        didSet {
            UserDefaults.standard.set(zone1Max, forKey: "zone1Max")
        }
    }
    
    @Published var zone5Min: String {
        didSet {
            UserDefaults.standard.set(zone1Min, forKey: "zone1Min")
        }
    }
    @Published var zone5Max: String {
        didSet {
            UserDefaults.standard.set(zone1Max, forKey: "zone1Max")
        }
    }
    

    
    @Published var calculatedAge: Int = 0
    @Published var maxHeartRate: Int
    @Published var calculatedMaxHeartRate: Int = 0 // Constant calculated max heart rate
    
    init() {
        print("init - UserName : \(UserDefaults.standard.string(forKey: "userName") ?? "MISSING") ")
        self.name = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.age = UserDefaults.standard.string(forKey: "userAge") ?? ""
        self.dateOfBirth = UserDefaults.standard.object(forKey: "userDateOfBirth") as? Date ?? Date()
        self.zone1Min = UserDefaults.standard.string(forKey: "zone1Min") ?? "0"
        self.zone1Max = UserDefaults.standard.string(forKey: "zone1Max") ?? "0"
        self.zone2Min = UserDefaults.standard.string(forKey: "zone2Min") ?? "0"
        self.zone2Max = UserDefaults.standard.string(forKey: "zone2Max") ?? "0"
        self.zone3Min = UserDefaults.standard.string(forKey: "zone3Min") ?? "0"
        self.zone3Max = UserDefaults.standard.string(forKey: "zone3Max") ?? "0"
        self.zone4Min = UserDefaults.standard.string(forKey: "zone4Min") ?? "0"
        self.zone4Max = UserDefaults.standard.string(forKey: "zone4Max") ?? "0"
        self.zone5Min = UserDefaults.standard.string(forKey: "zone5Min") ?? "0"
        self.zone5Max = UserDefaults.standard.string(forKey: "zone5Max") ?? "0"

        self.maxHeartRate = 0 // Initialize maxHeartRate with default value
        
        // Calculate age and max heart rate
        calculateAge()
        calculateMaxHeartRate()
        self.maxHeartRate = calculatedMaxHeartRate
        setZoneValues()
        
    }
    
    func setZoneValues() {
        // Calculate and set values for each zone
        
        if self.zone5Max != "0" {
            print("Zone values already exist")
        } else {
            print("Setting heart rate zones")
            self.zone1Min = "0"
            self.zone1Max = String(round(Double(maxHeartRate) * 0.57))
            self.zone2Min = String(round((Double(maxHeartRate) * 0.57) + 1 ))
            self.zone2Max = String(round(Double(maxHeartRate) * 0.63))
            self.zone3Min = String(round((Double(maxHeartRate) * 0.63) + 1 ))
            self.zone3Max = String(round(Double(maxHeartRate) * 0.76))
            self.zone4Min = String(round((Double(maxHeartRate) * 0.76) + 1 ))
            self.zone4Max = String(round(Double(maxHeartRate) * 0.95))
            self.zone5Min = String(round((Double(maxHeartRate) * 0.95) + 1 ))
            self.zone5Max = String(maxHeartRate)
        }
            
            print("Zone 1 Min : \(self.zone1Min))  Max : \(self.zone1Max)")
            print("Zone 2 Min : \(self.zone2Min))  Max : \(self.zone2Max)")
            print("Zone 3 Min : \(self.zone3Min))  Max : \(self.zone3Max)")
            print("Zone 4 Min : \(self.zone4Min))  Max : \(self.zone4Max)")
            print("Zone 5 Min : \(self.zone5Min))  Max : \(self.zone5Max)")


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
    
}
