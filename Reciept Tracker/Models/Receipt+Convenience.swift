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
            let merchant = merchant,
            let receiptDescription = receiptDescription,
            let imageURL = imageURL else { return nil }
        
        return ReceiptRepresentation(date: date, amount: amount, category: category, merchant: merchant, receiptDescription: receiptDescription, imageURL: imageURL, id: id)
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
    
    @discardableResult convenience init?(receiptRepresentation: ReceiptRepresentation, context: NSManagedObjectContext) {
              
        self.init(date: receiptRepresentation.date,
                  amount: receiptRepresentation.amount,
                  category: receiptRepresentation.category,
                  merchant: receiptRepresentation.merchant,
                  receiptDescription: receiptRepresentation.receiptDescription,
                  imageURL: receiptRepresentation.imageURL,
                  id: receiptRepresentation.id,
                  context: context)
    }
    
}
