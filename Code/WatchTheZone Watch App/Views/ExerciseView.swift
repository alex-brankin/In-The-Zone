//
//  ExerciseView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI
import WatchConnectivity

struct ExerciseView: View {
    @Binding var isRecording: Bool

    var body: some View {
        VStack {
            // Display heart rate zones here
            Button(action: {
                // Toggle recording state
                self.isRecording.toggle()

                if !self.isRecording {
                    let sampleData: [String: Any] = [
                        "heartRate": 120, // Sample heart rate
                        // Add more sample data as needed
                    ]

                    if WCSession.default.isReachable {
                        WCSession.default.sendMessage(sampleData, replyHandler: nil, errorHandler: { error in
                            print("Error sending message: \(error.localizedDescription)")
                        })
                    } else {
                        print("iPhone is not reachable")
                    }
                }
            }) {
                Text(self.isRecording ? "Stop Exercise" : "Start Recording")
            }
        }
        .navigationBarTitle("Exercise")
    }
}

struct previewExerciseView: View {
    @State private var isRecording = false

    var body: some View {
        ExerciseView(isRecording: $isRecording)
    }
}
