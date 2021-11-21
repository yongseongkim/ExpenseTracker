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
    static var systemGray: Color { Color(.systemGray) }
    static var systemGray2: Color { Color(.systemGray2) }
    static var systemGray3: Color { Color(.systemGray3) }
    static var systemGray4: Color { Color(.systemGray4) }
    static var systemGray5: Color { Color(.systemGray5) }
    static var systemGray6: Color { Color(.systemGray6) }
}

extension UIColor {
    static var systemBlack: UIColor { ExpenseTrackerAsset.systemBlack.color }
    static var systemWhite: UIColor { ExpenseTrackerAsset.systemWhite.color }

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
