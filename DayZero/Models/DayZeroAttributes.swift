import Foundation
import ActivityKit

struct DayZeroAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state (e.g. days remaining, which changes over time, or if we want to update the activity)
        var daysRemaining: Int
    }

    // Fixed non-changing properties about your activity go here
    var eventTitle: String
    var eventIcon: String
    var themeColorHex: String
}
