//
//  SessionPagingView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 15/04/2024.
//
// The SessionPagingView in the WatchTheZone Watch App is a multifunctional interface designed to
// enhance user engagement during workout sessions. It employs a TabView to facilitate switching
// between different views: ControlsView for managing the workout, MetricsView for displaying
// real-time data pertinent to the selected workout zone, and NowPlayingView for media control,
// enhancing the workout experience with entertainment options. The view cleverly uses environment
// settings and conditions, such as reducing luminance and dynamically adjusting navigation controls
// based on the app's state. Notably, the view hides the navigation bar in the NowPlayingView for a
// more immersive media experience and automatically switches to the MetricsView when the workout
// starts or if the display settings change due to environmental luminance conditions.

import SwiftUI
import WatchKit

struct SessionPagingView: View {
    var targetZone: Int
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var workoutUIManager: WorkoutUIManager
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
       // .navigationTitle(workoutManager.selectedWorkout?.name ?? "")
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
