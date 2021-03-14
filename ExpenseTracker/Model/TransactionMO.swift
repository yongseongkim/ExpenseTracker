//
//  TransactionMO+CoreDataClass.swift
//  ExpenseTracker
//
//  Created by yongseongkim on 2021/04/30.
//
//

import Foundation
import CoreData

@objc(TransactionMO)
public class TransactionMO: NSManagedObject {
}

extension TransactionMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionMO> {
        return NSFetchRequest<TransactionMO>(entityName: "Transaction")
    }

    @NSManaged public var uniqueIdentifier: String
    @NSManaged public var category: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var currencyCode: String?
    @NSManaged public var detail: String?
    @NSManaged public var title: String?
    @NSManaged public var value: Double
}

extension TransactionMO : Identifiable {

}
