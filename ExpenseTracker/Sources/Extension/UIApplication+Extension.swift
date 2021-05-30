//
//  UIApplication+Extension.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/04/25.
//

import UIKit

extension UIApplication {
    static func hideKeyboard() {
        shared.windows
            .filter { $0.isKeyWindow }
            .forEach { $0.endEditing(true) }
    }
}
