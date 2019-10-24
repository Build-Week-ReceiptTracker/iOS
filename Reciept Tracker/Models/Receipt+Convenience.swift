//
//  Receipt+Convenience.swift
//  ReceiptTracker
//
//  Created by Gi Pyo Kim on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Receipt {
    
    var receiptRepresentation: ReceiptRepresentation? {
        
        guard let dateOfTransaction = dateOfTransaction,
            let category = category,
            let merchant = merchant else { return nil }
        
        return ReceiptRepresentation(id: id, dateOfTransaction: dateOfTransaction, amountSpent: amountSpent, category: category, merchant: merchant, imageURL: imageURL, username: username, description: description)
    }
    
    // Full initializer
    @discardableResult convenience init(id: Int64?, dateOfTransaction: Date, amountSpent: Double, category: String, merchant: String,  imageURL: String?, username: String?, receiptDescription: String?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id ?? -1 // When there is no id value, default to -1
        self.dateOfTransaction = dateOfTransaction
        self.amountSpent = amountSpent
        self.category = category
        self.merchant = merchant
        self.imageURL = imageURL
        self.username = username
        self.receiptDescription = receiptDescription
    }
    
    // POST, PUT initializer
    @discardableResult convenience init(dateOfTransaction: Date, amountSpent: Double, category: String, merchant: String,  imageURL: String?, username: String, receiptDescription: String?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.dateOfTransaction = dateOfTransaction
        self.amountSpent = amountSpent
        self.category = category
        self.merchant = merchant
        self.imageURL = imageURL
        self.username = username
        self.receiptDescription = receiptDescription
    }
    
    // GET initializer
    @discardableResult convenience init(id: Int64?, dateOfTransaction: Date, amountSpent: Double, category: String, merchant: String, imageURL: String?, receiptDescription: String?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id ?? -1
        self.dateOfTransaction = dateOfTransaction
        self.amountSpent = amountSpent
        self.category = category
        self.merchant = merchant
        self.imageURL = imageURL
        self.receiptDescription = receiptDescription
    }
    
    
    
    @discardableResult convenience init?(receiptRepresentation: ReceiptRepresentation, context: NSManagedObjectContext) {
        
        self.init(id: receiptRepresentation.id,
                  dateOfTransaction: receiptRepresentation.dateOfTransaction,
                  amountSpent: receiptRepresentation.amountSpent,
                  category: receiptRepresentation.category,
                  merchant: receiptRepresentation.merchant,
                  imageURL: receiptRepresentation.imageURL,
                  username: receiptRepresentation.username,
                  receiptDescription: receiptRepresentation.description,
                  context: context)
    }
    
}
