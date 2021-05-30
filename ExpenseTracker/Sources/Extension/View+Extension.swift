//
//  View+Extension.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/27.
//

import SwiftUI

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

enum KeyboardDismissMode {
    case onTap
    case onDrag
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(
            RoundedCorner(radius: radius, corners: corners)
        )
    }

    @ViewBuilder func visibleOrInvisible(_ isVisible: Bool) -> some View {
        if isVisible {
            self
        } else {
            self.hidden()
        }
    }

    @ViewBuilder func visibleOrGone(_ isVisible: Bool) -> some View {
        if isVisible {
            self
        }
    }

    @ViewBuilder func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func keyboardDismissMode(_ modes: Set<KeyboardDismissMode> = Set()) -> some View {
        self
            .if(modes.contains(.onTap)) {
                $0.simultaneousGesture(
                    TapGesture().onEnded {
                        UIApplication.hideKeyboard()
                    }
                )
            }
            .if(modes.contains(.onDrag)) {
                $0.simultaneousGesture(
                    DragGesture().onChanged { _ in
                        UIApplication.hideKeyboard()
                    }
                )
            }
    }
}
