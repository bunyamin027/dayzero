import Foundation
import SwiftData
import SwiftUI

@Model
final class DayEvent {
    var id: UUID
    var title: String
    var targetDate: Date
    var themeColorHex: String
    var iconName: String
    var createdAt: Date
    var isPremium: Bool
    
    // MVP Core Properties
    var notes: String = ""
    var calendarEventId: String?
    
    // Pro Customization
    var fontName: String = "System"
    var timerPreference: Int = 0 
    
    // One-to-Many relationship for Milestones
    @Relationship(deleteRule: .cascade, inverse: \EventTask.event)
    var tasks: [EventTask]? = []
    
    init(title: String, targetDate: Date, themeColorHex: String = "#FFB6C1", iconName: String = "star.fill", isPremium: Bool = false) {
        self.id = UUID()
        self.title = title
        self.targetDate = targetDate
        self.themeColorHex = themeColorHex
        self.iconName = iconName
        self.createdAt = Date()
        self.isPremium = isPremium
    }
    
    @Transient
    var themeColor: Color { Color(hex: themeColorHex) ?? .blue }
}
