//
//  TransactionEditView.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/03/18.
//

import SwiftUI

struct TransactionEditView: View {
    @ObservedObject var model: ViewModel
    @State var keyboardHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Text("닫기")
                        .font(.system(size: 17))
                        .frame(height: 44)
                        .padding(.leading, 14)
                        .onTapGesture { self.model.cancel() }
                    Spacer()
                    Text("거래내역")
                        .font(.system(size: 17, weight: .bold))
                    Spacer()
                    Text("확인")
                        .font(.system(size: 17))
                        .frame(height: 44)
                        .padding(.trailing, 14)
                        .onTapGesture { self.model.confirm() }
                }
                .padding(.top, geometry.safeAreaInsets.top)
                Form {
                    Section {
                        DatePicker("", selection: .init(get: { model.tradedAt }, set: { model.tradedAt = $0 }))
                            .accentColor(Color.systemBlack)
                        HStack(spacing: 0) {
                            TransactionTypeSelector(
                                isExpense: .init(
                                    get: { model.isExpense },
                                    set: { model.isExpense = $0 }
                                )
                            )
                            Spacer()
                            HStack(spacing: 0) {
                                TextField(
                                    "금액",
                                    text: .init(
                                        get: { String("\(model.value)") },
                                        set: { model.value = Int($0.digits) ?? 0 }
                                    )
                                )
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                Text("원")
                            }
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
                .keyboardDismissMode([.onTap])
                .padding(.bottom, geometry.safeAreaInsets.bottom)
            }
            .ignoresSafeArea()
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
    enum Presentation: Identifiable {
        var id: String {
            switch self {
            case .new: return "new"
            case .edit(let transaction, _): return transaction.id
            }
        }

        var viewModel: ViewModel {
            switch self {
            case .new(let tradedAt, let listener):
                return ViewModel(tradedAt: tradedAt, listener: listener)
            case .edit(let transaction, let listener):
                return ViewModel(
                    targetTransactionId: transaction.id,
                    value: transaction.value,
                    isExpense: transaction.isExpense,
                    selectedCategory: Category.from(raw: transaction.category),
                    title: transaction.title,
                    detail: transaction.detail,
                    tradedAt: transaction.tradedAt,
                    listener: listener
                )
            }
        }

        case new(tradedAt: Date, listener: TransactionEditView.Listener)
        case edit(transaction: Transaction, listener: TransactionEditView.Listener)
    }

    class ViewModel: ObservableObject {
        @Published var value: Int
        @Published var isExpense: Bool
        @Published var selectedCategory: Category
        @Published var title: String
        @Published var detail: String
        @Published var tradedAt: Date

        let targetTransactionId: String?
        let listener: Listener

        init(
            targetTransactionId: String? = nil,
            value: Int? = nil,
            isExpense: Bool? = nil,
            selectedCategory: Category? = nil,
            title: String? = nil,
            detail: String? = nil,
            tradedAt: Date? = nil,
            listener: Listener
        ) {
            self.targetTransactionId = targetTransactionId
            if let targetId = targetTransactionId, let existed = TransactionStorage.shared.fetch(id: targetId) {
                self.value = abs(value ?? existed.value)
                self.isExpense = isExpense ?? existed.isExpense
                self.selectedCategory = selectedCategory ?? Category.from(raw: existed.category)
                self.title = title ?? existed.title ?? ""
                self.detail = detail ?? existed.detail ?? ""
                self.tradedAt = tradedAt ?? existed.tradedAt
                self.listener = listener
            } else {
                self.value = abs(value ?? 0)
                self.isExpense = isExpense ?? false
                self.selectedCategory = selectedCategory ?? .etc
                self.title = title ?? ""
                self.detail = detail ?? ""
                self.tradedAt = tradedAt ?? Date()
                self.listener = listener
            }
        }

        func cancel() {
            listener.onCancelled()
        }

        func confirm() {
            if title.isEmpty || detail.isEmpty || value == 0 {
                return
            }
            let target: Transaction = .init(
                id: targetTransactionId,
                value: isExpense ? -abs(value) : abs(value),
                currencyCode: "KRW",
                category: selectedCategory.rawValue,
                title: title,
                detail: detail,
                tradedAt: tradedAt
            )
            TransactionStorage.shared.upsert(transaction: target)
            listener.onConfirmed(target)
        }
    }

    struct Listener {
        let onCancelled: () -> Void
        let onConfirmed: (Transaction) -> Void
    }
}

struct TransactionEditView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionEditView(
            model: .init(
                value: 100,
                isExpense: true,
                selectedCategory: .etc,
                title: "title",
                detail: "detail",
                tradedAt: Date(),
                listener: .init(
                    onCancelled: {},
                    onConfirmed: { _ in }
                )
            )
        )
    }
}
