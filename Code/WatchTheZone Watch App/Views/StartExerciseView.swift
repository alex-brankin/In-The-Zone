//
//  StartExerciseView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 09/04/2024.
//

import SwiftUI

struct ImageButton: View {
    let action: () -> Void
    let image: String

    var body: some View {
        Button(action: action) {
            Image(image) // Use the provided image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(0) // Hide the button
    }
}


struct StartExerciseView: View {
    @Binding var isRecording: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ExerciseView(isRecording: $isRecording)) {
                    ZStack {
                        ImageButton(action: {
                            // Action to perform when the button is tapped
                            print("Button tapped")
                        }, image: "start image")
                        Image("start image") // Image overlay
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                    }
                }
            }
            
        }
    }
}

struct StartExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        StartExerciseView(isRecording: .constant(false))
    }
}
