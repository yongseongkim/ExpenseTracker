//
//  RootFloatingButtonView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/11/15.
//

import SwiftUI

struct RootFloatingButtonView: View {
    @ObservedObject var model: RootView.ViewModel

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(symbol: .plus)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(22)
                    .onTapGesture {
                        let currentTime = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
                        model.editViewPresentation = .new(
                            tradedAt: Calendar.current.date(
                                bySettingHour: currentTime.hour ?? 0,
                                minute: currentTime.minute ?? 0,
                                second: currentTime.second ?? 0,
                                of: model.selectedDate ?? Date()
                            ) ?? Date(),
                            listener: .init(
                                onCancelled: { model.editViewPresentation = nil },
                                onConfirmed: { _ in model.editViewPresentation = nil }
                            )
                        )
                    }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20))
        }
    }
}

struct RootFloatingButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RootFloatingButtonView(model: .init())
    }
}
