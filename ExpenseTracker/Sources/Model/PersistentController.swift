//
//  PersistentController.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/05/05.
//

import CoreData

class PersistentController {
    static let shared: PersistentController = PersistentController(modelName: "Model")

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            // TODO: handle errors.
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext { container.viewContext }

    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }
}
