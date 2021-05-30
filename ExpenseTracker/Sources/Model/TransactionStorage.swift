//
//  TransactionStorage.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/04/25.
//

import Combine
import CoreData
import SwiftUI

struct DateRange {
    let from: Date
    let to: Date
}

class TransactionStorage: NSObject {
    static let shared: TransactionStorage = TransactionStorage(
        persistentController: PersistentController.shared
    )

    private let persistentController: PersistentController
    private var fetchController: NSFetchedResultsController<TransactionMO>
    var fetchRange: DateRange {
        didSet {
            let request: NSFetchRequest<TransactionMO> = TransactionMO.fetchRequest()
            request.predicate = NSPredicate(format: "(%@ <= tradedAt) AND (tradedAt <= %@)", fetchRange.from as CVarArg, fetchRange.to as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "tradedAt", ascending: false)]
            self.fetchController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: persistentController.context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            detectFetchControllerChanges()
        }
    }
    var transactions = CurrentValueSubject<[Transaction], Never>([])

    init(
        persistentController: PersistentController,
        fetchRange: DateRange = DateRange(
            from: Calendar.current.firstDateOfMonth(date: Date()),
            to: Calendar.current.firstDateOfMonth(date: Calendar.current.date(byAdding: DateComponents(month: 1), to: Date()) ?? Date())
        )
    ) {
        self.persistentController = persistentController
        self.fetchRange = fetchRange
        let request: NSFetchRequest<TransactionMO> = TransactionMO.fetchRequest()
        request.predicate = NSPredicate(format: "(%@ <= tradedAt) AND (tradedAt <= %@)", fetchRange.from as CVarArg, fetchRange.to as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "tradedAt", ascending: false)]
        self.fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistentController.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        detectFetchControllerChanges()
    }

    func fetch(id: String) -> Transaction? {
        let request: NSFetchRequest<TransactionMO> = TransactionMO.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let result = try? persistentController.context.fetch(request)
        return result?.first.map { Transaction(with: $0) }
    }

    func upsert(transaction: Transaction) {
        let request: NSFetchRequest<TransactionMO> = TransactionMO.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", transaction.id)
        let result = try? persistentController.context.fetch(request)
        if let fetched = result?.first {
            fetched.value = transaction.value
            fetched.currencyCode = transaction.currencyCode
            fetched.category = transaction.category
            fetched.title = transaction.title
            fetched.detail = transaction.detail
            fetched.tradedAt = transaction.tradedAt
        } else {
            let mo = TransactionMO(context: persistentController.context)
            mo.id = transaction.id
            mo.value = transaction.value
            mo.currencyCode = transaction.currencyCode
            mo.category = transaction.category
            mo.title = transaction.title
            mo.detail = transaction.detail
            mo.tradedAt = transaction.tradedAt
            mo.createdAt = Date()
        }
        saveContext()
    }

    func delete(id: String) {
        let request: NSFetchRequest<TransactionMO> = TransactionMO.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let result = try? persistentController.context.fetch(request)
        if let fetched = result?.first {
            persistentController.context.delete(fetched)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try fetchController.managedObjectContext.save()
        } catch let error {
            print("\(error)")
        }
    }

    private func detectFetchControllerChanges() {
        fetchController.delegate = self
        do {
            try fetchController.performFetch()
            transactions.value = (fetchController.fetchedObjects ?? [])
                .map { Transaction(with: $0) }
                .sorted(by: { $0.tradedAt > $1.tradedAt })
        } catch let error {
            print(error)
        }
    }
}

extension TransactionStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.transactions.value = (fetchController.fetchedObjects ?? [])
            .map { Transaction(with: $0) }
    }
}
