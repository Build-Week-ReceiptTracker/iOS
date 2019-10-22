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
    private let baseURL = URL(string: "https://api-receipt-tracker.herokuapp.com/api")!
    
    var coreDataStack: CoreDataStack?
    
    //MARK: Back-End CRUD Methods
    
    
    //CREATE NEW
    //MARK: PUT Tasks to Firebase
      
      func addNewReceiptToServer(receipt: Receipt, completion: @escaping () -> Void = { }) {
          
          let id = receipt.id
          receipt.id = id
          
        let requestURL = baseURL
            .appendingPathComponent(String(id))
              .appendingPathExtension("json")
          
          var request = URLRequest(url: requestURL)
          request.httpMethod = HTTPMethod.put.rawValue
          
          guard let receiptRepresentation = receipt.receiptRepresentation else {
              NSLog("Receipt Representation is nil")
              completion()
              return
          }
          
          do {
              request.httpBody = try JSONEncoder().encode(receiptRepresentation)
          } catch {
              NSLog("Error encoding receipt representation: \(error)")
              completion()
              return
          }
          
          URLSession.shared.dataTask(with: request) { (_, _, error) in
              
              if let error = error {
                  NSLog("Error PUTting receipt: \(error)")
                  completion()
                  return
              }
              
              completion()
          }.resume()
      }
    
    
    
    // UPDATE
    func updateReceipts(with representations: [ReceiptRepresentation]) {
        
        // Which representations do we already have in Core Data?
        //Creating an Array of the representation's identifiers
        let identifiersToFetch = representations.map({ $0.id })
        
        // [[id]: [ReceiptRepresentation]]
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        // Make a mutable copy of the dictionary above
        
        // How many receipt (that could need to be created OR updated)
        var receiptsToCreate = representationsByID
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                
                let fetchRequest: NSFetchRequest<Receipt> = Receipt.fetchRequest()
                
                // Only fetch the receipts with the id's that are in this identifiersToFetch array
                //"identifiersToFetch.contains(id)"
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                
                let existingReceipts = try context.fetch(fetchRequest)
                
                //Update the ones we do have
                
                // Receipt
                for receipt in existingReceipts {
                    
                    // Grab the ReceiptRepresentation that corresponds to this Receipt
                    let id = receipt.id
                    guard let representation = representationsByID[id] else { continue }
                    

                    // We just updated a receipt, we don't need to create a new Receipt for this identifier
                    receiptsToCreate.removeValue(forKey: id)
                }
                
                //MARK: Figure out which ones we don't have
                
                // receipts that don't exist in Core Data already
                for representation in receiptsToCreate.values {
                    Receipt(receiptRepresentation: representation, context: context)
                }
                
                // Persist all the changes (updating and creating of receipts) to Core Data
                CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error fetching receipts from persistent store: \(error)")
            }
        }
    }
    
    
    
    
    //MARK: DELETE
    func deleteReceiptFromServer(_ receipt: Receipt, completion: @escaping () -> Void = { }) {
        
        let id = receipt.id
        
        let requestURL = baseURL
            .appendingPathComponent(String(id))
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error deleting receipt \(receipt.id) from server: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    
    
    
    
    
    // MARK: - Core Data CRUD Methods
    func createReceipt(date: Date, price: Double, category: String, merchant: String, receiptDescription: String?, imageURL: String?, id: Int16, context: NSManagedObjectContext) {
        
        let receipt = Receipt(date: date, amount: price, category: category, merchant: merchant, receiptDescription: receiptDescription, imageURL: imageURL, id: id, context: context)
        
        // TODO: PUT to database
        
        CoreDataStack.shared.save(context: context)
    }
    
    func updateReceipt(receipt: Receipt, date: Date, amount: Double, category: String, merchant: String, receiptDescription: String?, imageURL: String?, context: NSManagedObjectContext) {
        
        receipt.date = date
        receipt.amount = amount
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
