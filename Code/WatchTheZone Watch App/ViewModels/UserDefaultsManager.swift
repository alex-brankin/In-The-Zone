//
//  UserDefaultsManager.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 06/04/2024.
//
// The UserDefaultsManager class in the WatchTheZone Watch App serves as a dedicated interface for
// managing and storing user-specific settings such as heart rate zones within the device's
// UserDefaults. It simplifies access and modification of these settings by providing properties for
// minimum and maximum thresholds of each zone, which are persistently stored and easily retrievable
// across app sessions.

import Foundation

class UserDefaultsManager {
    
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

}
