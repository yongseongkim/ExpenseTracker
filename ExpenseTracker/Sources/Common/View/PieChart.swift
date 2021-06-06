//
//  PieChart.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/06/06.
//

import SwiftUI

struct PieChart: View {
    let slideData: [PieChartSlide.Data]
    let placeholderColor: Color

    var body: some View {
        ZStack {
            PieChartSlide(
                startDegrees: 0,
                endDegrees: 360
            )
            .fill(placeholderColor)
            ForEach(slideData) {
                PieChartSlide(
                    startDegrees: $0.startDegrees,
                    endDegrees: $0.endDegrees
                )
                .fill($0.color)
            }
        }
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PieChart(
                slideData: [
                    .init(startDegrees: 0, endDegrees: 90, color: .systemGray5),
                    .init(startDegrees: 90, endDegrees: 135, color: .systemGray4),
                    .init(startDegrees: 135, endDegrees: 180, color: .systemGray3),
                    .init(startDegrees: 180, endDegrees: 270, color: .systemGray2),
                    .init(startDegrees: 210, endDegrees: 360, color: .systemGray)
                ],
                placeholderColor: .systemGray6
            )
            .previewLayout(.fixed(width: 300, height: 300))
        }
    }
}
