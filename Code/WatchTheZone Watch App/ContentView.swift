//
//  ContentView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 02/04/2024.
//

import SwiftUI

struct ImageButton: View {
    let action: () -> Void
    let image: String

    var body: some View {
        Button(action: action) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

struct ContentView: View {
    var body: some View {
        ImageButton(action: {
            // Action to perform when the button is tapped
            print("Button tapped")
        }, image: "start image")
    }
}


#Preview {
    ContentView()
}
