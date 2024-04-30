//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI

struct HRPulse: View {
    var body: some View {
      VStack {
        TimelineView(.animation) { timeline in
          Canvas { context, size in
            let offset = calculateOffset(withDate: timeline.date, size: size)
            let gradient = Gradient(colors: [.red, .red.opacity(0.0)])
            let startPoint = CGPoint(x: 0.0, y: size.height / 2)
            let endPoint = CGPoint(x: offset, y: size.height / 2)
            var path = Path()
            path.move(to: .init(x: 0.0,
                                y: size.height / 2))
            path.addLine(to: .init(x: size.width / 4,
                                   y: size.height / 2))
            path.addLine(to: .init(x: size.width / 2,
                                   y: size.height * 2 / 3))
            path.addLine(to: .init(x: size.width * 3 / 5,
                                   y: size.height * 1 / 3))
            path.addLine(to: .init(x: size.width * 3 / 4,
                                   y: size.height * 1 / 2))
            path.addLine(to: .init(x: size.width,
                                   y: size.height / 2))
            
            context.stroke(path,
                           with: .linearGradient(gradient,
                                                 startPoint: startPoint,
                                                 endPoint: endPoint),
                           style: .init(lineWidth: 5,
                                        lineCap: .round,
                                        lineJoin: .round))
          }
        }
      }
      
    }
  
  private func calculateOffset(withDate timelineDate: Date, size: CGSize) -> CGFloat {
    let interval = tan(timelineDate.timeIntervalSinceReferenceDate * 2.5)
    return interval * size.width
  }
}

#Preview {
    HRPulse()
}
