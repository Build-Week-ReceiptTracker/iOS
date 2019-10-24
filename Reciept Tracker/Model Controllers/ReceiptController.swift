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
    case noRepresentation
}

class ReceiptController {
    
    // MARK: - Properties
    private let baseURL = URL(string: "https://api-receipt-tracker.herokuapp.com/api")!
    
    var bearer: Bearer?
    var receiptID: Int64?
    var searchedReceipts: [ReceiptRepresentation] = []
    
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
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        
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
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let receipts = try decoder.decode([ReceiptRepresentation].self, from: data)
                self.updateReceipts(with: receipts)
            } catch {
                NSLog("Error decoding ReceiptRepresentation: \(error)")
                completion(.badDecode)
            }
            completion(nil)
        }.resume()
    }
    
    
    //MARK: Back-End CRUD Methods
    
    
    
    //MARK: PUT
    func addNewReceiptToServer(receipt: Receipt, completion: @escaping (NetworkingError?) -> Void = { _ in }) {
        
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
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        
        
        guard let receiptRepresentation = receipt.receiptRepresentation else {
            NSLog("Receipt Representation is nil")
            completion(.noRepresentation)
            return
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            request.httpBody = try encoder.encode(receiptRepresentation)
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
                self.receiptID = id.receiptID
                completion(nil)
            } catch {
                NSLog("Could not decode receipt ID: \(error)")
                completion(.badDecode)
            }

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

    func createReceipt(dateOfTransaction: Date, amountSpent: Double, category: String, merchant: String, imageURL: String?, username: String, receiptDescription: String?, context: NSManagedObjectContext) {
        
        let receipt = Receipt(dateOfTransaction: dateOfTransaction, amountSpent: amountSpent, category: category, merchant: merchant, imageURL: imageURL, username: username, receiptDescription: receiptDescription, context: context)

        addNewReceiptToServer(receipt: receipt, completion: { (error) in
            if let id =  self.receiptID{
                receipt.id = id
                print(id)
                CoreDataStack.shared.save(context: context)
            }
        })
    }

    
    //Update
    func updateReceipt(receipt: Receipt, date: Date, amount: Double, category: String, merchant: String, receiptDescription: String?, imageURL: String?, context: NSManagedObjectContext) {
        
        receipt.dateOfTransaction = date
        receipt.amountSpent = amount
        receipt.category = category
        receipt.merchant = merchant
        receipt.receiptDescription = receiptDescription
        receipt.imageURL = imageURL
        
        // TODO: PUT to database
        
        CoreDataStack.shared.save(context: context)
        
    }
    
    //Delete
    func deleteReceipt(receipt: Receipt, context: NSManagedObjectContext) {
        context.performAndWait {
            
            // TODO: DELETE from database
            
            context.delete(receipt)
            CoreDataStack.shared.save(context: context)
        }
    }
    
    
    func searchForReceipt(searchID: String, completion: @escaping (Result<ReceiptRepresentation, NetworkingError>) -> Void) {
        
        guard let bearer = bearer else {
            completion(.failure(.noBearer))
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent("auth")
            .appendingPathComponent("receipts")
            .appendingPathComponent(String(searchID))
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                NSLog("Error fetching receipt details: \(error)")
                completion(.failure(.serverError(error)))
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.unexpectedStatusCode(response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                let receipt = try decoder.decode(ReceiptRepresentation.self, from: data)
                
                completion(.success(receipt))
                
            } catch {
                NSLog("Error decoding Receipt: \(error)")
                completion(.failure(.badDecode))
            }
        }.resume()
    }
    
    //let params = 
    
}
