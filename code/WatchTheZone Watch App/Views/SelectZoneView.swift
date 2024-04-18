//
//  SelectZoneView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 16/04/2024.
//

import SwiftUI

struct SelectZoneView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedZone: Int?

    var body: some View {

            List {
                ForEach(1..<6) { zoneIndex in
                    NavigationLink(destination: ActivityView(targetZone: zoneIndex)) {
                        GeometryReader { geometry in
                            Text("Zone \(zoneIndex)")
                                .modifier(MyButtonStyle(color: colorForZone(zoneIndex)))
                                .frame(width: geometry.size.width, height: geometry.size.height) // Match size of NavigationLink
                        }
                    }.modifier(MyButtonStyle(color: colorForZone(zoneIndex)))
                       // .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

            }
            .listStyle(CarouselListStyle())
            .padding()
            //.navigationTitle("Select Zone")
        }
 
    func colorForZone(_ zone: Int) -> Color {
        switch zone {
        case 1:
            return .blue
        case 2:
            return .green
        case 3:
            return .yellow
        case 4:
            return .orange
        case 5:
            return .red
        default:
            return .clear
        }
    }
}

struct MyButtonStyle: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .background(color)
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(25)
    }
}

struct SelectZoneView_Previews: PreviewProvider {
    static var previews: some View {
        SelectZoneView()
    }
}
