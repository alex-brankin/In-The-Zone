//
//  WatchTheZone
//
//  Created by Alex Brankin on 13/03/2024.
//

import SwiftUI

struct StartView: View {

    @State private var selection: Tab = .zone
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection){
                
                HistoryView().navigationBarTitle("History")
                    .tag(Tab.history)
                SelectZoneView().navigationBarHidden(true)
                    .tag(Tab.zone)
                SettingsView()
                    .tag(Tab.settings)
            }.navigationTitle(selection.title)
            .navigationBarBackButtonHidden(true)
        }.navigationBarBackButtonHidden(true)
    }
}

enum Tab {
    case history, zone, settings
    
    var title: String {
        switch self {
        case .history: return "History"
        case .zone: return ""
        case .settings: return "Settings"
        }
    }
}
struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(WorkoutManager())
    }
}
