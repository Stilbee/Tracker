//
//  UIColor+extension.swift
//  Tracker
//
//  Created by Alibi Mailan
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
            return
        }
        
        let length = hexSanitized.count
        switch length {
        case 6: // RGB (e.g., "FF0000")
            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        case 8: // ARGB (e.g., "80FF0000")
            let alpha = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            let red = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x000000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        default:
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }
    
    func rgbaComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else {
                return nil
            }
            return (r, g, b, a)
        }

        func isEqualToColor(_ color: UIColor) -> Bool {
            guard let c1 = self.rgbaComponents(),
                  let c2 = color.rgbaComponents() else {
                return false
            }
            return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b && c1.a == c2.a
        }
}
