import Foundation
import UIKit

struct ColorScheme {
    let background: UIColor
    let backgroundSecondary: UIColor
    let backgroundTertiary: UIColor
    let border: UIColor
    let selectionHighlight: UIColor
    let refreshControl: UIColor
    let textPrimary: UIColor
    let textSecondary: UIColor
}

class Colors {
    static let current = Colors()

    private let light = ColorScheme(
        background: .white,
        backgroundSecondary: .gray,
        backgroundTertiary: .darkGray,
        border: UIColor.black.withAlphaComponent(0.05),
        selectionHighlight: UIColor.black.withAlphaComponent(0.03),
        refreshControl: UIColor.black.withAlphaComponent(0.4),
        textPrimary: .black,
        textSecondary: UIColor.black.withAlphaComponent(0.4)
    )

    private let dark = ColorScheme(
        background: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
        backgroundSecondary: UIColor.white.withAlphaComponent(0.1),
        backgroundTertiary: UIColor.white.withAlphaComponent(0.15),
        border: UIColor.white.withAlphaComponent(0.08),
        selectionHighlight: UIColor.white.withAlphaComponent(0.04),
        refreshControl: UIColor.white.withAlphaComponent(0.4),
        textPrimary: .white,
        textSecondary: .gray
    )

    var background: UIColor {
        return colors().background
    }

    var backgroundSecondary: UIColor {
        return colors().backgroundSecondary
    }

    var backgroundTertiary: UIColor {
        return colors().backgroundTertiary
    }

    var border: UIColor {
        return colors().border
    }

    var selectionHighlight: UIColor {
        return colors().selectionHighlight
    }

    var refreshControl: UIColor {
        return colors().refreshControl
    }

    var textPrimary: UIColor {
        return colors().textPrimary
    }

    var textSecondary: UIColor {
        return colors().textSecondary
    }

    private func colors() -> ColorScheme {
        if UserSettings.darkMode() {
            return dark
        } else {
            return light
        }
    }
}
