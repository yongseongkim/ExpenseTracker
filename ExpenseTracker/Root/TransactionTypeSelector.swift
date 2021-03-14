//
//  TransactionTypeSelector.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/27.
//

import SwiftUI

struct TransactionTypeSelector: View {
    @Binding var isExpense: Bool

    var body: some View {
        HStack(spacing: 0) {
            Image(symbol: .plus)
                .foregroundColor(isExpense ? Color.systemBlack : Color.systemWhite)
                .frame(width: 44, height: 44)
                .background(isExpense ? Color.systemWhite.opacity(0) : Color.systemBlack)
                .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                .onTapGesture { isExpense.toggle() }
            Color.black.frame(width: 1)
            Image(symbol: .minus)
                .foregroundColor(isExpense ? Color.systemWhite : Color.systemBlack)
                .frame(width: 44, height: 44)
                .background(isExpense ? Color.systemBlack : Color.systemWhite.opacity(0))
                .cornerRadius(10, corners: [.topRight, .bottomRight])
                .onTapGesture { isExpense.toggle() }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.systemBlack, lineWidth: 1)
        )
    }
}

struct TransactionTypeSelector_Previews: PreviewProvider {
    static var previews: some View {
        TransactionTypeSelector(isExpense: .constant(false))
    }
}
