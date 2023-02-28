import SwiftUI

extension Color {
    private enum Token: String {
        case background
        case onBackgroundPrimary
        case onBackgroundSecondary
        case surface
        case onSurface
        case accent

        var color: Color {
            Color(self.rawValue)
        }
    }

    static let background = Token.background.color
    static let onBackground = Token.onBackgroundPrimary.color
    static let onBackgroundSecondary = Token.onBackgroundSecondary.color
    static let surface = Token.surface.color
    static let onSurface = Token.onSurface.color
    static let accent = Token.accent.color
}
