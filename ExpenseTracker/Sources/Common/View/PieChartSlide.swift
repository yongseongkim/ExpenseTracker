//
//  PieChartSlide.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/06/06.
//

import SwiftUI

struct PieChartSlide: Shape {
    let startDegrees: Double
    let endDegrees: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(
            x: ((rect.minX + rect.maxX) / 2),
            y: ((rect.minY + rect.maxY) / 2)
        )
        let path = Path { path in
            path.move(to: center)
            path.addArc(
                center: center,
                radius: rect.width / 2,
                startAngle: Angle(degrees: startDegrees - 90),
                endAngle: Angle(degrees: endDegrees - 90),
                clockwise: false
            )
            path.addLine(to: center)
        }
        return path
    }
}

extension PieChartSlide {
    struct Data: Identifiable {
        let id = UUID()
        let startDegrees: Double
        let endDegrees: Double
        let color: Color
    }
}

struct PieChartSlide_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PieChartSlide(
                startDegrees: 0,
                endDegrees: 165
            )
            .fill(Color.systemGray4)
            .padding(30)
            .previewLayout(.fixed(width: 300, height: 300))
            PieChartSlide(
                startDegrees: 165,
                endDegrees: 300
            )
            .fill(Color.systemGray)
            .padding(30)
            .previewLayout(.fixed(width: 300, height: 300))
        }
    }
}
