import SwiftUI

enum Theme {
    static let modernPastels = ["#FFB6C1", "#AEC6CF", "#B39EB5", "#FFD1DC", "#FDFD96"]
    static let darkAcademia = ["#2C3E50", "#4A4E69", "#9A8C98", "#C9ADA7", "#F2E9E4"]
    static let neon = ["#FF00FF", "#00FFFF", "#00FF00", "#FFFF00", "#FF0000"]
    
    static let premiumFonts = [
        "System",
        "AvenirNext-Bold",
        "Georgia-Bold",
        "Courier-Bold",
        "MarkerFelt-Wide",
        "Noteworthy-Bold"
    ]
}

// Hex Color Extension
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
