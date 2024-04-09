//
//  ExerciseView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI

struct ExerciseView: View {
    @Binding var isRecording: Bool

    var body: some View {
        VStack {
            // Display heart rate zones here
            Text("Exercise Screen")
            Button(action: {
                // Toggle recording state
                self.isRecording.toggle()
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
