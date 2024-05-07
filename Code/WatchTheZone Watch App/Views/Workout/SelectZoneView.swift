//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//
// The SelectZoneView in the WatchTheZone app allows users to select one of five workout intensity
// zones through a user-friendly interface. Presented in a carousel-style list, each zone is
// represented as a color-coded navigation link that leads to a corresponding ActivityView for more
// detailed interaction. The colours range from blue for the lightest intensity to red for the
// highest. This view leverages SwiftUI's NavigationLink and custom modifiers for styling, ensuring
// an engaging and accessible selection process for users planning their workouts.

import SwiftUI

struct SelectZoneView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutUIManager: WorkoutUIManager
    @State private var selectedZone: Int?

    var body: some View {

            List {
                ForEach(1..<6) { zoneIndex in
                    NavigationLink(destination: ActivityView(targetZone: zoneIndex)) {
                        GeometryReader { geometry in
                            Text("Zone \(zoneIndex)")
                                .modifier(MyButtonStyle(color: colorForZone(zoneIndex)))
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }.modifier(MyButtonStyle(color: colorForZone(zoneIndex)))
                }.listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())

            
            .listStyle(CarouselListStyle())
            .padding(.top, 0)
            
        }
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
