//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//

import SwiftUI
import WatchKit

struct SessionPagingView: View {
    var targetZone: Int
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selection: Tab = .metrics
    
    enum Tab {
        case controls, metrics, nowPlaying
    }
    
    
    var body: some View {
        TabView(selection: $selection){
            ControlsView().tag(Tab.controls)
            MetricsView(targetZone: targetZone).tag(Tab.metrics)
            NowPlayingView().tag(Tab.nowPlaying)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(selection == .nowPlaying)
        .onChange(of: workoutManager.running) {
                displayMetricsView()
            }
        .tabViewStyle(
                PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic)
            )
            .onChange(of: isLuminanceReduced) { 
                displayMetricsView()
            }
        }

        private func displayMetricsView() {
            withAnimation {
                selection = .metrics
            }
    }
}

struct PagingView_Previews: PreviewProvider {
    static var previews: some View {
        SessionPagingView(targetZone: 3).environmentObject(WorkoutManager())
    }
}
