//
//  ReceiptController.swift
//  ReceiptTracker
//
//  Created by Gi Pyo Kim on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData
import Cloudinary

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
    case noRepresentation
}

class ReceiptController {
    
    // MARK: - Properties
    private let baseURL = URL(string: "https://api-receipt-tracker.herokuapp.com/api")!
    
    var bearer: Bearer?
    var receiptID: Int64?
    var receipts: [ReceiptRepresentation] = []
            
    
    
    init() {
        fetchReceiptsFromServer()
    }
    
    
    //MARK: Fetch from server
    func fetchReceiptsFromServer(completion: @escaping (NetworkingError?) -> Void = { _ in }) {
        guard let bearer = bearer else { return }
        
        let requestURL = baseURL
            .appendingPathComponent("auth")
            .appendingPathComponent("receipts")
            .appendingPathComponent("all")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue(bearer.token, forHTTPHeaderField: HeaderNames.authorization.rawValue)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                NSLog("Error fetching receipts: \(error)")
                completion(.serverError(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                NSLog("Unexpected status code: \(response.statusCode)")
                completion(.unexpectedStatusCode(response.statusCode))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from receipt fetch data task")
                completion(.noData)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let receipts = try decoder.decode([ReceiptRepresentation].self, from: data)
                self.updateReceipts(with: receipts)
                self.receipts = receipts
            } catch {
                NSLog("Error decoding ReceiptRepresentation: \(error)")
                completion(.badDecode)
            }
            completion(nil)
        }.resume()
    }
    
    
    //MARK: Back-End CRUD Methods
    
    
    
    //MARK: PUT
    func addNewReceiptToServer(postReceiptRepresentation: PostReceiptRepresentation, completion: @escaping (NetworkingError?) -> Void = { _ in }) {
        
        guard let bearer = bearer else {
            completion(.noBearer)
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent("auth")
            .appendingPathComponent("receipts")
            .appendingPathComponent("add")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("\(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            request.httpBody = try encoder.encode(postReceiptRepresentation)
        } catch {
            NSLog("Error encoding receipt representation: \(error)")
            completion(.badEncode)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                NSLog("Error PUTting receipt: \(error)")
                completion(.serverError(error))
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 201 {
                NSLog("Unexpected status code: \(response.statusCode)")
                completion(.unexpectedStatusCode(response.statusCode))
                return
            }
            
            guard let data = data else {
                NSLog("No id returned after adding a new receipt")
                completion(.noData)
                return
            }
            
            do {
                let id = try JSONDecoder().decode(ReceiptID.self, from: data)
                self.receiptID = Int64(id.receiptID)
                completion(nil)
            } catch {
                NSLog("Could not decode receipt ID: \(error)")
                completion(.badDecode)
            }

        }.resume()

    }
    
//    func updateReceiptToServer(receipt: Receipt, completion: @escaping (NetworkingError?) -> Void = { _ in }) {
//        
//        guard let bearer = bearer else {
//            completion(.noBearer)
//            return
//        }
//        
//        let requestURL = baseURL
//            .appendingPathComponent("auth")
//            .appendingPathComponent("receipts")
//            .appendingPathComponent(String(receipt.id))
//        
//        var request = URLRequest(url: requestURL)
//        request.httpMethod = HTTPMethod.post.rawValue
//        request.setValue("\(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
//        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
//        
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        
//        do {
//            request.httpBody = try encoder.encode(ReceiptRepresentation)
//        } catch {
//            NSLog("Error encoding receipt representation: \(error)")
//            completion(.badEncode)
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            
//            if let error = error {
//                NSLog("Error PUTting receipt: \(error)")
//                completion(.serverError(error))
//            }
//            
//            if let response = response as? HTTPURLResponse,
//                response.statusCode != 201 {
//                NSLog("Unexpected status code: \(response.statusCode)")
//                completion(.unexpectedStatusCode(response.statusCode))
//                return
//            }
//            
//            guard let data = data else {
//                NSLog("No id returned after adding a new receipt")
//                completion(.noData)
//                return
//            }
//            
//            do {
//                let id = try JSONDecoder().decode(ReceiptID.self, from: data)
//                self.receiptID = Int64(id.receiptID)
//                completion(nil)
//            } catch {
//                NSLog("Could not decode receipt ID: \(error)")
//                completion(.badDecode)
//            }
//
//        }.resume()
//
//    }
    
    
    // UPDATE
    func updateReceipts(with representations: [ReceiptRepresentation]) {
        
        let identifiersToFetch = representations.map({ $0.id })
        // [[id]: [ReceiptRepresentation]]
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var receiptsToCreate = representationsByID
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.performAndWait {
            
            do {
                let fetchRequest: NSFetchRequest<Receipt> = Receipt.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id IN %@", identifiersToFetch)
                
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
    func deleteReceiptFromServer(_ receipt: Receipt, completion: @escaping (NetworkingError?) -> Void = { _ in }) {
        
        guard let bearer = bearer else {
            completion(.noBearer)
            return
        }
        let id = receipt.id
        
        let requestURL = baseURL
            .appendingPathComponent("auth")
            .appendingPathComponent("receipts")
            .appendingPathComponent(String(id))
            .appendingPathComponent("del")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.setValue("\(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            
            if let error = error {
                NSLog("Error deleting receipt \(id) from server: \(error)")
                completion(.serverError(error))
                return
            }
            completion(nil)
        }.resume()
    }
    
    
    
    // MARK: - Core Data CRUD Methods

    func createReceipt(dateOfTransaction: String, amountSpent: String, category: String, merchant: String, imageURL: String?, username: String, receiptDescription: String?, context: NSManagedObjectContext) {

        let postReceiptRepresentation = PostReceiptRepresentation(dateOfTransaction: dateOfTransaction, amountSpent: amountSpent, category: category, merchant: merchant, imageURL: imageURL, username: username, description: receiptDescription)
        
        addNewReceiptToServer(postReceiptRepresentation: postReceiptRepresentation, completion: { (error) in
            if let id =  self.receiptID{
                Receipt(id: id, postReceiptRepresentation: postReceiptRepresentation, context: context)
                CoreDataStack.shared.save(context: context)
            }
        })
    }

    
    //Update
    func updateReceipt(receipt: Receipt, date: String, amount: String, category: String, merchant: String, receiptDescription: String?, imageURL: String?, context: NSManagedObjectContext) {
        
        receipt.dateOfTransaction = date
        receipt.amountSpent = amount
        receipt.category = category
        receipt.merchant = merchant
        receipt.receiptDescription = receiptDescription
        receipt.imageURL = imageURL
        
        // TODO: update to datatbase
        
        CoreDataStack.shared.save(context: context)
        
    }
    
    //Delete
    func deleteReceipt(receipt: Receipt, context: NSManagedObjectContext) {
        context.performAndWait {
            deleteReceiptFromServer(receipt) { (error) in
                context.delete(receipt)
                CoreDataStack.shared.save(context: context)
            }
        }
    }
    
    
    func searchForReceipts(with searchTerm: String, completion: @escaping (NetworkingError?) -> Void) {
        
        guard let bearer = bearer else {
            completion(.noBearer)
            return
        }
        
        //https://api-receipt-tracker.herokuapp.com/api/auth/receipts/category
        
        let requestURL = baseURL
            .appendingPathComponent("auth")
            .appendingPathComponent("receipts")
            //.appendingPathComponent(sortType.rawValue)
            .appendingPathComponent(searchTerm)
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
            
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                NSLog("Error fetching receipt: \(error)")
                completion(.serverError(error))
                return
            }
        
            guard let data = data else {
                NSLog("No data returned from receipt search")
                completion(.noData)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let receiptsSearched = try decoder.decode(ReceiptsSearched.self, from: data).results
                
                self.receipts = receiptsSearched
            } catch {
                NSLog("Unable to decode data into ReceiptsSearched: \(error)")
            }
            completion(.badDecode)
        }.resume()
    }
}
