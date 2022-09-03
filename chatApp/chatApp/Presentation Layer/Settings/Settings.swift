import Foundation
import UIKit

class Settings {
    
    enum Theme {
        case classic
        case day
        case night
    }
    
    struct ThemeColors {
        var buttonColor: UIColor
        var backgroundColor: UIColor
        var incomingMessageColor: UIColor
        var outgoingMessageColor: UIColor
        var textColor: UIColor
        var sectionBarColor: UIColor
        var conversationOnlineCellColor: UIColor
        var conversationHistoryCellColor: UIColor
        var settingsBackgroundColor: UIColor
    }
    
    static var appTheme: Theme {
        get { return currentTheme }
        set {
            self.currentTheme = newValue
            switch currentTheme {
            case Theme.classic:
                currentColors = classicColors
            case Theme.day:
                currentColors = dayColors
            case Theme.night:
                currentColors = nightColors
            }
        }
    }
    private static let classicColors: ThemeColors = ThemeColors(
        buttonColor: .systemBlue,
        backgroundColor: .white,
        incomingMessageColor: .systemGray4,
        outgoingMessageColor: UIColor(red: 129 / 256,
                                      green: 232 / 256,
                                      blue: 252 / 256,
                                      alpha: 1),
        textColor: .black,
        sectionBarColor: .systemGray6,
        conversationOnlineCellColor: UIColor(red: 193 / 256,
                                             green: 253 / 256,
                                             blue: 255 / 256,
                                             alpha: 0.55),
        conversationHistoryCellColor: .white,
        settingsBackgroundColor: UIColor(red: 137 / 256,
                                         green: 207 / 256,
                                         blue: 240 / 256,
                                         alpha: 1))
    
    private static let dayColors: ThemeColors = ThemeColors(
        buttonColor: UIColor(red: 0,
                             green: 142 / 256,
                             blue: 56 / 256,
                             alpha: 1),
        backgroundColor: .white,
        incomingMessageColor: .systemGray5,
        outgoingMessageColor: UIColor(red: 214 / 256,
                                      green: 249 / 256,
                                      blue: 192 / 256,
                                      alpha: 1),
        textColor: .black,
        sectionBarColor: .systemGray6,
        conversationOnlineCellColor: UIColor(red: 217 / 256,
                                             green: 235 / 256,
                                             blue: 213 / 256,
                                             alpha: 0.6),
        conversationHistoryCellColor: .white,
        settingsBackgroundColor: UIColor(red: 169 / 256,
                                         green: 194 / 256,
                                         blue: 164 / 256,
                                         alpha: 1))
    
    private static let nightColors: ThemeColors = ThemeColors(
        buttonColor: .white,
        backgroundColor: UIColor(red: 31 / 256,
                                 green: 31 / 256,
                                 blue: 31 / 256,
                                 alpha: 1),
        incomingMessageColor: UIColor(red: 0.18,
                                      green: 0.18,
                                      blue: 0.18,
                                      alpha: 1),
        outgoingMessageColor: .gray,
        textColor: .white,
        sectionBarColor: .systemGray2,
        conversationOnlineCellColor: UIColor(red: 31 / 256,
                                             green: 31 / 256,
                                             blue: 31 / 256,
                                             alpha: 1),
        conversationHistoryCellColor: UIColor(red: 0.24,
                                              green: 0.24,
                                              blue: 0.24,
                                              alpha: 1),
        settingsBackgroundColor: UIColor(red: 46 / 256,
                                         green: 28 / 256,
                                         blue: 68 / 256,
                                         alpha: 1))
    
    private static var currentTheme: Theme = Theme.day
    public private(set) static var currentColors: ThemeColors = dayColors
    public static let profilePictureColor = UIColor(red: 0.211,
                                                    green: 0.215,
                                                    blue: 0.219,
                                                    alpha: 1)
    
    public static let buttonBackgroundColor = UIColor(red: 246 / 256,
                                                       green: 246 / 256,
                                                       blue: 246 / 256,
                                                       alpha: 1)
    
    private static let userDefaults = UserDefaults.standard
    private static let UDKey: String = "appTheme"
    
    static func saveTheme(theme: Theme) {
        var themeString: String
        switch theme {
        case .classic: themeString = "classic"
        case .day: themeString = "day"
        case .night: themeString = "night"
        }
        userDefaults.set(themeString, forKey: UDKey)
    }
    
    static func loadTheme() -> Theme? {       
        let themeString = userDefaults.object(forKey: UDKey) as? String
        var theme: Theme
        switch themeString {
        case "classic": theme = .classic
        case "day": theme = .day
        case "night": theme = .night
        default: return nil
        }
        return theme
    }
}
