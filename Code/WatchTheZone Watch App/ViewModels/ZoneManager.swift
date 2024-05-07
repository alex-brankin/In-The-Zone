//
//  ZoneManager.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 06/04/2024.
//
// The ZoneManager class in the WatchTheZone Watch App provides essential functionality for
// determining and managing heart rate zones during physical activities. It interfaces with
// UserDefaultsManager to access predefined heart rate thresholds for different zones, ranging from
// zone 1 (least intense) to zone 5 (most intense). The class offers methods to dynamically
// determine the current heart rate zone based on a user's real-time heart rate and retrieve minimum
// or maximum boundaries for any given zone. This modular approach facilitates the application's
// ability to provide personalized feedback and guidance based on the user's performance relative to
// their target zones, enhancing the training experience by adapting to different fitness levels and
// goals.

import Foundation

class ZoneManager {
    
    let userDefaultsManager = UserDefaultsManager()
    
    func getCurrentZone(for heartRate: Double) -> Int {
          switch heartRate {
          case (Double(userDefaultsManager.zone1Min) ?? 0)...(Double(userDefaultsManager.zone1Max) ?? 0):
              return 1
          case (Double(userDefaultsManager.zone2Min) ?? 0)...(Double(userDefaultsManager.zone2Max) ?? 0):
              return 2
          case (Double(userDefaultsManager.zone3Min) ?? 0)...(Double(userDefaultsManager.zone3Max) ?? 0):
              return 3
          case (Double(userDefaultsManager.zone4Min) ?? 0)...(Double(userDefaultsManager.zone4Max) ?? 0):
              return 4
          case (Double(userDefaultsManager.zone5Min) ?? 0)...(Double(userDefaultsManager.zone5Max) ?? 0):
              return 5
          default: return 0
          }
      }
      
  func getZoneBoundary(boundary: String, zone: Int) -> Int {
          switch boundary {
          case "min":
              switch zone {
              case 1:
                  return Int(userDefaultsManager.zone1Min) ?? 0
              case 2:
                  return Int(userDefaultsManager.zone2Min) ?? 0
              case 3:
                  return Int(userDefaultsManager.zone3Min) ?? 0
              case 4:
                  return Int(userDefaultsManager.zone4Min) ?? 0
              case 5:
                  return Int(userDefaultsManager.zone5Min) ?? 0
                  
              default:
                  return 0
              }
          case "max":
              switch zone {
              case 1:
                  return Int(userDefaultsManager.zone1Max) ?? 0
              case 2:
                  return Int(userDefaultsManager.zone2Max) ?? 0
              case 3:
                  return Int(userDefaultsManager.zone3Max) ?? 0
              case 4:
                  return Int(userDefaultsManager.zone4Max) ?? 0
              case 5:
                  return Int(userDefaultsManager.zone5Max) ?? 0
              default:
                  return 0
              }
          default:
              return 0
          }
      }

}
