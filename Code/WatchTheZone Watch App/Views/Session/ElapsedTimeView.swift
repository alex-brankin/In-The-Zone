//
//  ElapsedTimeView.swift
//  WatchTheZone Watch App
//
//  Created by Alex Brankin on 15/04/2024.
//
// The ElapsedTimeView in the WatchTheZone Watch App provides a concise display of elapsed time
// during workouts, formatted to show minutes, seconds, and optionally subseconds. This SwiftUI view
// leverages a custom ElapsedTimeFormatter to dynamically format the time based on whether
// subseconds are shown, responding to changes with SwiftUI's .onChange modifier. The view serves as
// a functional component within fitness applications, offering real-time feedback on the duration
// of a user's physical activity.

import SwiftUI

struct ElapsedTimeView: View {
    var elapsedTime: TimeInterval = 0
    var showSubseconds: Bool = true
    @State private var timeFormatter = ElapsedTimeFormatter()

    var body: some View {
        Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
            .fontWeight(.semibold)
            .onChange(of: showSubseconds) {
                timeFormatter.showSubseconds = $0
            }
    }
}

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubseconds = true

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        if showSubseconds {
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }
}

#Preview {
    ElapsedTimeView()
}
