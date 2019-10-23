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
        
        guard let date = date,
            let category = category,
            let merchant = merchant else { return nil }
        
        return ReceiptRepresentation(id: id, dateOfTransaction: date, amountSpent: amount, category: category, merchant: merchant, imageURL: imageURL, description: receiptDescription)
    }
    
    @discardableResult convenience init(date: Date, amount: Double, category: String, merchant: String, receiptDescription: String?, imageURL: String?, id: Int16, context: NSManagedObjectContext) {
        self.init(context: context)
        self.date = date
        self.amount = amount
        self.category = category
        self.merchant = merchant
        self.receiptDescription = receiptDescription
        self.imageURL = imageURL
        self.id = id
    }
    
    // Initializer without id
    @discardableResult convenience init(date: Date, amount: Double, category: String, merchant: String, receiptDescription: String?, imageURL: String?, context: NSManagedObjectContext) {
           self.init(context: context)
           self.date = date
           self.amount = amount
           self.category = category
           self.merchant = merchant
           self.receiptDescription = receiptDescription
           self.imageURL = imageURL
       }
    
    
    
    @discardableResult convenience init?(receiptRepresentation: ReceiptRepresentation, context: NSManagedObjectContext) {
              
        self.init(date: receiptRepresentation.dateOfTransaction,
                  amount: receiptRepresentation.amountSpent,
                  category: receiptRepresentation.category,
                  merchant: receiptRepresentation.merchant,
                  receiptDescription: receiptRepresentation.description,
                  imageURL: receiptRepresentation.imageURL,
                  id: receiptRepresentation.id,
                  context: context)
    }
    
}
