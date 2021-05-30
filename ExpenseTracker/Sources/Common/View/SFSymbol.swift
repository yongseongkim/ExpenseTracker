//
//  SFSymbol.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/14.
//

import SwiftUI

enum SFSymbol: String {
    case checkmark = "checkmark"
    case xmark = "xmark"
    case xmarkCircle = "xmark.circle"
    case xmarkCircleFill = "xmark.circle.fill"
    case plus = "plus"
    case plusCircle = "pluc.circle"
    case plusCircleFill = "pluc.circle.fill"
    case minus = "minus"
    case minusCircle = "minus.circle"
    case minusCircleFill = "minus.circle.fill"

    // Transportation
    case bus = "bus"
    case busFill = "bus.fill"
    case tram = "tram"
    case tramFill = "tram.fill"
    // Education
    case graduationcap = "graduationcap"
    case graduationcapFill = "graduationcap.fill"
    // Hospital
    case cross = "cross"
    case crossFill = "cross.fill"
    case crossCase = "cross.case"
    case crossCaseFill = "cross.case.fill"
    case pills = "pills"
    case pillsFill = "pills.fill"
    // Communication
    case phone = "phone"
    case phoneFill = "phone.fill"
    case phoneCircle = "phone.circle"
    case phoneCircleFill = "phone.circle.fill"
    // Shopping
    case cart = "cart"
    case cartFill = "cart.fill"
    // Gift
    case gift = "gift"
    case giftFill = "gift.fill"
    // Meal
    case wake = "wake"
    // Beauty
    case scissors = "scissors"
    // Entertainment
    case gamecontroller = "gamecontroller"
    case gamecontrollerFill = "gamecontroller.fill"
    // Living
    case house = "house"
    case houseFill = "house.fill"
    // ETC
    case ellipsisCircle = "ellipsis.circle"
}

extension Image {
    init(symbol: SFSymbol) {
        self.init(systemName: symbol.rawValue)
    }
}
