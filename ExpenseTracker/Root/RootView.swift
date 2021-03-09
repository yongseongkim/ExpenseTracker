//
//  RootView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/07.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        MonthlyGridView(
            year: 2021,
            month: 3,
            emptyView: { Color.white },
            itemView: { _ in Color.blue }
        )
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
