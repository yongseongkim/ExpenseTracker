//
//  KotlinCompatible.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/10.
//

import Foundation

protocol KotlinCompatible {}

extension KotlinCompatible {
    func apply(_ block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
}
