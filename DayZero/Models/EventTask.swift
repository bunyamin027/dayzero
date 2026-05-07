import Foundation
import SwiftData

@Model
final class EventTask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var event: DayEvent?
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
    }
}
