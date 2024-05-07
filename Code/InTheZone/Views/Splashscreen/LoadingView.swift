//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The LoadingView in SwiftUI presents a visually appealing loading screen for the "In The Zone" app, featuring an
// animated background, a title, and a standard progress indicator. This screen occupies the entire device display,
// offering users a stylish transition as the app loads necessary data and processes.

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            // Background with HRPulse animation
            HRPulse()
                .opacity(0.6)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Text("In The Zone")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                
                ProgressView()
                    
                
                Spacer()
            }
        }
       
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
