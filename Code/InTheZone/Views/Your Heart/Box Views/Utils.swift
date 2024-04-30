//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//

import SwiftUI

enum TimeRange {
    case last7Days
    case last30Days
    case last12Months
}

struct TimeRangePicker: View {
    @Binding var value: TimeRange

    var body: some View {
        Picker(selection: $value.animation(.easeInOut), label: EmptyView()) {
            Text("7 Days").tag(TimeRange.last7Days)
            Text("30 Days").tag(TimeRange.last30Days)
            Text("12 Months").tag(TimeRange.last12Months)
        }
        .pickerStyle(.segmented)
    }
}
