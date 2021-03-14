//
//  TransactionEditView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/18.
//

import SwiftUI

struct TransactionEditView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        ZStack {
            Form {
                Section {
                    DatePicker("", selection: .init(get: { model.createdAt }, set: { model.createdAt = $0 }))
                        .accentColor(Color.systemBlack)
                    HStack(spacing: 0) {
                        TransactionTypeSelector(
                            isExpense: .init(
                                get: { model.isExpense },
                                set: { model.isExpense = $0 }
                            )
                        )
                        Spacer()
                        TextField(
                            "금액",
                            text: .init(
                                get: { String("\(model.value)") },
                                set: { model.value = Double($0) ?? 0 }
                            )
                        )
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .font(.system(size: 30))
                        .padding(.trailing, 25)
                    }
                    .padding(.top, 30)
                }
                Section {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Spacer()
                            Text(model.selectedCategory.displayName)
                                .font(.system(size: 18))
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.trailing, 20)
                        HStack(spacing: 0) {
                            Spacer()
                            categoryGridView()
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
                Section {
                    TextField(
                        "어디서 썼나요?",
                        text: .init(get: { model.title }, set: { model.title = $0 })
                    )
                    TextEditor(
                        text: .init(
                            get: { model.detail },
                            set: { model.detail = $0 }
                        )
                    )
                    .frame(minHeight: 100)
                }
            }
            .padding(.bottom, 44)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.hideKeyboard()
                }
            )
            .simultaneousGesture(
                DragGesture().onChanged { _ in
                    UIApplication.hideKeyboard()
                }
            )
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Text("저장")
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                        .background(Color.blue)
                        .onTapGesture { self.model.confirm() }
                }
                .ignoresSafeArea()
            }
        }
    }

    var numberOfCategoryColumns: Int = 6

    var numberOfCategoryRows: Int {
        Int(ceil(Double(Category.allCases.count) / Double(self.numberOfCategoryColumns)))
    }

    @ViewBuilder
    private func categoryGridView() -> some View {
        VStack(spacing: 0) {
            ForEach(0..<numberOfCategoryRows) { row in
                HStack(spacing: 0) {
                    ForEach(0..<self.numberOfCategoryColumns) { column in
                        categoryIcon(row: row, column: column)
                    }
                }
            }
        }
    }

    private func categoryIcon(row: Int, column: Int) -> some View {
        let idx = row * self.numberOfCategoryColumns + column
        return Group {
            if idx < Category.allCases.count {
                categoryIcon(idx: idx)
                    .frame(width: 32, height: 32)
            } else {
                Color.systemWhite.opacity(0)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(4)
    }

    private func categoryIcon(idx: Int) -> some View {
        let category = Category.allCases[idx]
        let isSelected = model.selectedCategory == category
        return ZStack {
            if isSelected {
                Color.systemBlack.cornerRadius(18)
            }
            Image(symbol: category.symbol)
                .frame(width: 22, height: 22)
                .foregroundColor(isSelected ? .systemWhite : .systemBlack)
                .onTapGesture {
                    model.selectedCategory = category
                }
        }
    }
}

extension TransactionEditView {
    class ViewModel: ObservableObject {
        @Published var value: Double
        @Published var isExpense: Bool
        @Published var selectedCategory: Category
        @Published var title: String
        @Published var detail: String
        @Published var createdAt: Date
        let listener: Listener

        init(
            value: Double,
            isExpense: Bool,
            selectedCategory: Category,
            title: String,
            detail: String,
            createdAt: Date,
            listener: Listener
        ) {
            self.value = abs(value)
            self.isExpense = isExpense
            self.selectedCategory = selectedCategory
            self.title = title
            self.detail = detail
            self.createdAt = createdAt
            self.listener = listener

        }

        func confirm() {
            if title.isEmpty || detail.isEmpty || value == 0 {
                return
            }
            let target: Transaction = .init(
                value: isExpense ? -value : value,
                currencyCode: "KRW",
                category: selectedCategory.rawValue,
                title: title,
                detail: detail,
                createdAt: createdAt
            )
            TransactionStorage.shared.upsert(transaction: target)
            listener.onFinished(target)
        }
    }

    struct Listener {
        let onFinished: (Transaction) -> Void
    }
}

extension TransactionEditView.ViewModel {
    static func new(createdAt: Date = Date(), listener: TransactionEditView.Listener) -> TransactionEditView.ViewModel {
        return .init(
            value: 0,
            isExpense: true,
            selectedCategory: .etc,
            title: "",
            detail: "",
            createdAt: createdAt,
            listener: listener
        )
    }

    static func edit(transaction: Transaction, listener: TransactionEditView.Listener) -> TransactionEditView.ViewModel {
        return .init(
            value: transaction.value,
            isExpense: transaction.isExpense,
            selectedCategory: Category.allCases.first(where: { $0.rawValue == transaction.category }) ?? .etc,
            title: transaction.title ?? "",
            detail: transaction.detail ?? "",
            createdAt: transaction.createdAt,
            listener: listener
        )
    }
}

struct TransactionEditView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionEditView(model: .new(listener: .init(onFinished: { _ in })))
    }
}
