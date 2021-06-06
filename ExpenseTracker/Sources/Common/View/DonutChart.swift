//
//  DonutChart.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/06/06.
//

import SwiftUI

struct DonutChart: View {
    let slideData: [PieChartSlide.Data]
    let placeholderColor: Color
    let innerCircleColor: Color

    var body: some View {
        ZStack {
            PieChart(
                slideData: slideData,
                placeholderColor: placeholderColor
            )
            InnerCircle(ratio: 1/2)
                .fill(innerCircleColor)
        }
    }
}

fileprivate struct InnerCircle: Shape {
    let ratio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(
            x: (rect.minX + rect.maxX) / 2,
            y: (rect.minY + rect.maxY) / 2
        )
        let radius = min(rect.width / 2, rect.height / 2) * ratio
        let path = Path { p in
            p.addArc(center: center,
                     radius: radius,
                     startAngle: Angle(degrees: 0),
                     endAngle: Angle(degrees: 360),
                     clockwise: true)
            p.addLine(to: center)
        }
        return path
    }
}

struct DonutChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DonutChart(
                slideData: [
                    .init(startDegrees: 0, endDegrees: 90, color: .systemGray5),
                    .init(startDegrees: 90, endDegrees: 135, color: .systemGray4),
                    .init(startDegrees: 135, endDegrees: 180, color: .systemGray3),
                    .init(startDegrees: 180, endDegrees: 270, color: .systemGray2),
                    .init(startDegrees: 210, endDegrees: 360, color: .systemGray)
                ],
                placeholderColor: .systemGray6,
                innerCircleColor: .white
            )
            .previewLayout(.fixed(width: 300, height: 300))
        }
    }
}
