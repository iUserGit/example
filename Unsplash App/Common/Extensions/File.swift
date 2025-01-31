//
//  File.swift
//  Unsplash App
//
//  Created by Serg on 30/01/2025.
//


public extension UIColor {
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat? = 1) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: alpha ?? 1)
    }

    convenience init(hex:String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    static func namedInMainBundle(_ named: String) -> UIColor {
        guard let color = UIColor(named: named, in: Bundle.main, compatibleWith: nil) else {
            fatalError("Can't find color with name \(named) in bundle \(Bundle.main)")
        }
        return color
    }

    var image: UIImage? {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    var inverted: UIColor {
        var alpha: CGFloat = 1.0

        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }

        var white: CGFloat = 0.0
        if getWhite(&white, alpha: &alpha) {
            return UIColor(white: 1.0 - white, alpha: alpha)
        }

        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
        }

        return self
    }

    func interpolate(with other: UIColor, percent: CGFloat) -> UIColor? {
        return UIColor.interpolate(betweenColor: self, and: other, percent: percent)
    }

    static func interpolate(betweenColor colorA: UIColor,
                            and colorB: UIColor,
                            percent: CGFloat) -> UIColor? {
        var redA: CGFloat = 0.0
        var greenA: CGFloat = 0.0
        var blueA: CGFloat = 0.0
        var alphaA: CGFloat = 0.0
        guard colorA.getRed(&redA, green: &greenA, blue: &blueA, alpha: &alphaA) else {
            return nil
        }

        var redB: CGFloat = 0.0
        var greenB: CGFloat = 0.0
        var blueB: CGFloat = 0.0
        var alphaB: CGFloat = 0.0
        guard colorB.getRed(&redB, green: &greenB, blue: &blueB, alpha: &alphaB) else {
            return nil
        }

        let iRed = CGFloat(redA + percent * (redB - redA))
        let iBlue = CGFloat(blueA + percent * (blueB - blueA))
        let iGreen = CGFloat(greenA + percent * (greenB - greenA))
        let iAlpha = CGFloat(alphaA + percent * (alphaB - alphaA))

        return UIColor(red: iRed, green: iGreen, blue: iBlue, alpha: iAlpha)
    }

    func lighterColor() -> UIColor {
        guard self == UIColor.clear else {
            return self
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let newR = r + 0.1
        let newG = g + 0.1
        let newB = b + 0.1

        return UIColor(red: min(newR, 1.0), green: min(newG, 1.0), blue: min(newB, 1.0), alpha: 1)//min(newA + 0.2, 1.0))
    }

    func darkerColor(diff: CGFloat = 0.1) -> UIColor {
        guard self == UIColor.clear else {
            return self
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let newR = r - diff
        let newG = g - diff
        let newB = b - diff
        
        return UIColor(red: max(newR, 0.0), green: max(newG, 0.0), blue: max(newB, 0.0), alpha: 1)// max(newA, 0.0))
    }
}
