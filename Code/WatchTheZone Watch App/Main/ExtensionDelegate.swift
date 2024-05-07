//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//
// The ExtensionDelegate class in the WatchTheZone Watch App acts as the main delegate for the watch
// extension, managing critical initialization and configuration tasks. It interfaces with
// UserDefaults to manage user-specific settings such as heart rate zones and maximum heart rate,
// ensuring these preferences are stored and retrievable across sessions. Additionally, it
// initializes and manages a SyncService to handle data synchronization tasks, responding to
// incoming data by updating local settings and logging activity for debugging purposes. This setup
// ensures the app functions smoothly with up-to-date user configurations directly on the watch.


import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    var syncService = SyncService()
    
    var maxHeartRate: String {
        get {
            UserDefaults.standard.string(forKey: "maxHeartRate") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "maxHeartRate")
        }
    }
    
    var zone1Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone1Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone1Min")
        }
    }
    
    var zone1Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone1Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone1Max")
        }
    }
    
    var zone2Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone2Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone2Min")
        }
    }
    
    var zone2Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone2Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone2Max")
        }
    }
    
    var zone3Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone3Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone3Min")
        }
    }
    
    var zone3Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone3Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone3Max")
        }
    }
    
    var zone4Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone4Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone4Min")
        }
    }
    
    var zone4Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone4Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone4Max")
        }
    }
    
    var zone5Min: String {
        get {
            UserDefaults.standard.string(forKey: "zone5Min") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone5Min")
        }
    }
    
    var zone5Max: String {
        get {
            UserDefaults.standard.string(forKey: "zone5Max") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "zone5Max")
        }
    }
    
    func applicationDidFinishLaunching() {
        // Activate the WCSession
        
        syncService.connect()
        print("synService running")
        
        // Set up dataReceived handler
        syncService.dataReceived = { [weak self] key, value in

            switch key {
                case "maxHeartRate": self?.maxHeartRate = value as? String ?? ""
                case "zone1Min": self?.zone1Min = value as? String ?? ""
                case "zone1Max": self?.zone1Max = value as? String ?? ""
                case "zone2Min": self?.zone2Min = value as? String ?? ""
                case "zone2Max": self?.zone2Max = value as? String ?? ""
                case "zone3Min": self?.zone3Min = value as? String ?? ""
                case "zone3Max": self?.zone3Max = value as? String ?? ""
                case "zone4Min": self?.zone4Min = value as? String ?? ""
                case "zone4Max": self?.zone4Max = value as? String ?? ""
                case "zone5Min": self?.zone5Min = value as? String ?? ""
                case "zone5Max": self?.zone5Max = value as? String ?? ""
                default: break
            }
            print("\(key): \(value)")
        }
    }
}
