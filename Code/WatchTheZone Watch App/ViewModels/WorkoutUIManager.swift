//
//  WorkoutUIManager.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 10/04/2024.
//
// The WorkoutUIManager class in the WatchTheZone Watch App serves as a utility class designed to
// assist with the visualization and formatting of workout data during fitness activities. It
// calculates the pace of a workout based on elapsed time and distance, providing a formatted string
// that represents the pace in minutes and seconds per kilometer or indicates if the user is not
// moving. Additionally, the class assigns specific colours to different workout intensity zones,
// enhancing visual feedback in the UI. It also formats the distance covered during a workout into a
// readable string, adjusting the units and representation based on the length of the workout and
// the preferred distance unit (kilometers or miles). This class encapsulates functionality that
// directly supports displaying dynamic workout data in the user interface, making it easier to
// provide clear and actionable information to the user during physical activities.

import Foundation
import SwiftUI


class WorkoutUIManager: NSObject, ObservableObject{
    
func getPace(elapsedTime: TimeInterval, distance: Double) -> String {
        var pace: String = ""
        let elapsedTime = elapsedTime
        let secondsPerKm = (elapsedTime) / (distance / 1000)
        if secondsPerKm.isFinite {
            let minutes = Int(secondsPerKm) / 60
            let seconds = Int(secondsPerKm) % 60
            pace = String(format: "%02d\"%02d ", minutes, seconds)
        }
        else { pace = "Not Moving" }
        return pace
    }
    
    func zoneColor(for zone: Int) -> Color {
        let color: Color
        switch zone {
        case 1:
            color = .blue
        case 2:
            color = .green
        case 3:
            color = .yellow
        case 4:
            color = .orange
        case 5:
            color = .red
        default:
            color = .blue
        }
        return color
    }
    
    
    func getFormattedDistance(distance: Double) -> String{
        let distanceUnit = "kilometers"
        var returnString: String = ""
        if String(distanceUnit) == "miles"
        {
            returnString = String(format: "%.2f miles", ((distance / 1000) * 0.621371 ))
        }
        if String(distanceUnit) == "kilometers"
        {
            if distance < 50 {
                returnString = String(format: "%.0f metres", distance.rounded())
            } else {
                returnString = String(format: "%.2f kilometres", (distance / 1000))
            }
        }
        return returnString
        
    }
    
}
