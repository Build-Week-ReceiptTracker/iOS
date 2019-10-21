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
    
    @discardableResult convenience init(date: Date, price: Double, category: String, merchant: String, receiptDescription: String?, imageURL: String?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.date = date
        self.price = price
        self.category = category
        self.merchant = merchant
        self.receiptDescription = receiptDescription
        self.imageURL = imageURL
    }
    
}
