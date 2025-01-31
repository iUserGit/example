import UIKit
import RxSwift

public extension NSNotification.Name {
    static let colorSchemeWasChanged: NSNotification.Name = .init("color_scheme_was_changed")
}

public enum ColorScheme {
    private enum Keys: String {
        case lightModeEnabled = "isLightModeEmabled"
        case ligntMode = "lightMode"
    }
        
    public private(set) static var current: ColorScheme = {
        return  UserDefaults.standard.bool(forKey: Keys.lightModeEnabled.rawValue) ? .light : .dark
    }()
    
    public static func update(colorScheme: ColorScheme) {
        guard ColorScheme.current != colorScheme else { return }
        ColorScheme.current = colorScheme
        
        switch colorScheme {
        case .light:
            UserDefaults.standard.set(true, forKey: Keys.lightModeEnabled.rawValue)
        case .dark:
            UserDefaults.standard.set(false, forKey: Keys.lightModeEnabled.rawValue)
        }
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .colorSchemeWasChanged, object: nil)
    }
    
    case light
    case dark
    
    public var alertStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    public var preferredStatusBarStyle: UIStatusBarStyle {
        switch self {
        case .light:
            return .darkContent
        case .dark:
            return .lightContent
        }
    }
    
    public var keyboardAppearance: UIKeyboardAppearance {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    public func colorSchemeName() -> String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        }
    }

    private var palette: PaletteProtocol {
        switch self {
        case .light:
            return AquaBluePalette()
        case .dark:
            return DarkPalette()
        }
    }
    
    public var loadingBackground: UIColor {
        UIColor.black.withAlphaComponent(0.3)
    }
    
    public var background: UIColor {
        palette.background
    }
    public var border: UIColor {
        palette.border
    }
    public var text: UIColor {
        palette.text
    }
    public var active: UIColor {
        palette.active
    }
    public var inactive: UIColor {
        palette.inactive
    }
    public var dark: UIColor {
        palette.dark
    }

    public var warning: UIColor {
        .red
    }
}


private protocol PaletteProtocol {
    var background: UIColor { get }
    var border: UIColor { get }
    var text: UIColor { get }
    var active: UIColor { get }
    var inactive: UIColor { get }
    var dark: UIColor { get }
}


struct AquaBluePalette: PaletteProtocol {
    var background: UIColor {
        UIColor(hex: Palette.AquaBlue.light.rawValue)
    }
    
    var border: UIColor {
        UIColor(hex: Palette.AquaBlue.pastel.rawValue)
    }
    
    var text: UIColor {
        UIColor(hex: "000000")
    }
    
    var active: UIColor {
        UIColor(hex: Palette.AquaBlue.saturated.rawValue)
    }
    
    var inactive: UIColor {
        UIColor(hex: Palette.AquaBlue.pastel.rawValue)
    }
    
    var dark: UIColor {
        UIColor(hex: Palette.AquaBlue.dark.rawValue)
    }
}

struct DarkPalette: PaletteProtocol {
    var background: UIColor {
        UIColor(hex: Palette.Dark.light.rawValue)
    }
    
    var border: UIColor {
        UIColor(hex: Palette.Dark.pastel.rawValue)
    }
    
    var text: UIColor {
        UIColor(hex: "ffffff")
    }
    
    var active: UIColor {
        UIColor(hex: Palette.Dark.saturated.rawValue)
    }
    
    var inactive: UIColor {
        UIColor(hex: Palette.Dark.pastel.rawValue)
    }
    
    var dark: UIColor {
        UIColor(hex: Palette.Dark.dark.rawValue)
    }
}

fileprivate enum Palette {
    enum AquaBlue: String {
        case light = "e5f8ff"
        case pastel = "c5eaf7"
        case saturated = "2183a6"
        case dark = "1d4250"
    }
    
    enum Dark: String {
        case light = "2C2C2C"
        case pastel = "4E4E4E"
        case saturated = "00CCCC"
        case dark = "162126"
    }
}
