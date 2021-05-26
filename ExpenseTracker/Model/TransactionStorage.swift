//
//  TransactionStorage.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/04/25.
//

import Combine
import CoreData
import SwiftUI

class TransactionStorage: NSObject {
    static let shared: TransactionStorage = TransactionStorage(
        persistentController: PersistentController.shared
    )

    private let persistentController: PersistentController
    private let fetchController: NSFetchedResultsController<TransactionMO>
    var transactions = CurrentValueSubject<[Transaction], Never>([])

    init(persistentController: PersistentController) {
        self.persistentController = persistentController
        let request: NSFetchRequest<TransactionMO> = TransactionMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        self.fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistentController.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchController.delegate = self
        do {
            try fetchController.performFetch()
            transactions.value = (fetchController.fetchedObjects ?? [])
                .map { Transaction(with: $0) }
                .sorted(by: { $0.createdAt > $1.createdAt })
        } catch let error {
            print(error)
        }
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
        } else {
            let mo = TransactionMO(context: persistentController.context)
            mo.id = transaction.id
            mo.value = transaction.value
            mo.currencyCode = transaction.currencyCode
            mo.category = transaction.category
            mo.title = transaction.title
            mo.detail = transaction.detail
            mo.createdAt = transaction.createdAt
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
}

extension TransactionStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.transactions.value = (fetchController.fetchedObjects ?? [])
            .map { Transaction(with: $0) }
    }
}
