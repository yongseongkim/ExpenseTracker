//
//  UIColor+Extension.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/14.
//

import SwiftUI
import UIKit

extension Color {
    static var systemBlack: Color { Color(.systemBlack) }
    static var systemWhite: Color { Color(.systemWhite) }
}

extension UIColor {
    static var systemBlack: UIColor { UIColor(named: "systemBlack")! }
    static var systemWhite: UIColor { UIColor(named: "systemWhite")! }

    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }

    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }
}
