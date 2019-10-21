//
//  ReceiptController.swift
//  ReceiptTracker
//
//  Created by Gi Pyo Kim on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum NetworkingError: Error {
    case noData
    case noBearer
    case serverError(Error)
    case unexpectedStatusCode(Int)
    case badDecode
    case badEncode
}

class ReceiptController {
    
    // MARK: - Properties
    private let firebaseURL = URL(string: "")
    
    
    // MARK: - Core Data CRUD Methods
    func createReceipt(date: Date, price: Double, category: String, merchant: String, receiptDescription: String?, imageURL: String?, context: NSManagedObjectContext) {
        
        let receipt = Receipt(date: date, price: price, category: category, merchant: merchant, receiptDescription: receiptDescription, imageURL: imageURL, context: context)
        
        // TODO: PUT to database
        
        CoreDataStack.shared.save(context: context)
    }
    
    func updateReceipt(receipt: Receipt, date: Date, price: Double, category: String, merchant: String, receiptDescription: String?, imageURL: String?, context: NSManagedObjectContext) {
        
        receipt.date = date
        receipt.price = price
        receipt.category = category
        receipt.merchant = merchant
        receipt.receiptDescription = receiptDescription
        receipt.imageURL = imageURL
        
        // TODO: PUT to database
        
        CoreDataStack.shared.save(context: context)
        
    }
    
    func deleteReceipt(receipt: Receipt, context: NSManagedObjectContext) {
        context.performAndWait {
            
            // TODO: DELETE from database
            
            context.delete(receipt)
            CoreDataStack.shared.save(context: context)
        }
    }
    
}
