//
//  Category.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/27.
//

import Foundation

enum Category: String, CaseIterable {
    case meal
    case shopping
    case transportation
    case communication
    case hospital
    case gift
    case education
    case beauty
    case entertainment
    case living
    case travel
    case etc
}

extension Category {
    static func from(raw: String?) -> Category {
        return Category(rawValue: raw ?? "") ?? .etc
    }

    var displayName: String {
        switch self {
        case .meal:
            return "식비"
        case .shopping:
            return "쇼핑"
        case .transportation:
            return "교통"
        case .communication:
            return "통신"
        case .hospital:
            return "의료 • 건강"
        case .gift:
            return "선물"
        case .education:
            return "교육"
        case .beauty:
            return "미용"
        case .entertainment:
            return "취미 • 여가"
        case .living:
            return "생활"
        case .travel:
            return "여행"
        case .etc:
            return "기타"
        }
    }

    var symbol: SFSymbol {
        switch self {
        case .meal:
            return SFSymbol.wake
        case .shopping:
            return SFSymbol.cart
        case .transportation:
            return SFSymbol.bus
        case .communication:
            return SFSymbol.phone
        case .hospital:
            return SFSymbol.cross
        case .gift:
            return SFSymbol.gift
        case .education:
            return SFSymbol.graduationcap
        case .beauty:
            return SFSymbol.scissors
        case .entertainment:
            return SFSymbol.gamecontroller
        case .living:
            return SFSymbol.house
        case .travel:
            return SFSymbol.airplaneCircle
        case .etc:
            return SFSymbol.ellipsisCircle
        }
    }
}

extension Category: Identifiable {
    var id: String { self.rawValue }
}
