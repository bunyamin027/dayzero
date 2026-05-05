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
    
    // Determines if this event requires a premium subscription to be active/created
    var isPremium: Bool
    
    // Pro features
    var notes: String = ""
    var mediaFileNames: [String] = []
    var timerPreference: Int = 0 // 0: Auto, 1: Days Only, 2: Timer Always
    
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
    var themeColor: Color {
        Color(hex: themeColorHex) ?? .blue
    }
}
