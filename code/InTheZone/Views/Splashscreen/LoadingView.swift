//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

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
