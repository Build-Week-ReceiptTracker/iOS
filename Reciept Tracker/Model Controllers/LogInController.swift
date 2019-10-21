//
//  LogInController.swift
//  ReceiptTracker
//
//  Created by macbook on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HeaderNames: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
}

class LogInController {

    var receipts: [Receipt] = []
    
    var bearer: Bearer?
    private let loginBaseURL = URL(string: "")!
//
//    // MARK: Performing fetchAllReceipt Network call
//
//    func fetchAllReciepts( completion: @escaping (Result<[String], NetworkingError>) -> Void) {
//
//        guard let bearer = bearer else {
//            completion(.failure(.noBearer))
//            return
//        }
//
//        let requestURL = loginBaseURL
//            .appendingPathComponent("")
//
//        var request = URLRequest(url: requestURL)
//        request.httpMethod = HTTPMethod.get.rawValue
//        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: HeaderNames.authorization.rawValue)
//    }
//

    // MARK: - Sign Up  &  Log In Functions :
    
    // MARK: - Sign Up URLSessionDataTask
    func signUp(with user: User, completion: @escaping (Error?) -> Void) {
        
        // Build the URL
        
        let requestURL = loginBaseURL
            .appendingPathComponent("users")
            .appendingPathComponent("signup")
        
        // Build the request
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        
        // Tell the API that the body is in JSON format
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        do {
            let userJSON = try encoder.encode(user)
            request.httpBody = userJSON
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
        }
        
        // Performing data task
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Handle errors
            if let error = error {
                NSLog("Error signing up user: \(error)")
                completion(error)
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                
                let statusCodeError = NSError(domain: "com.ReceiptTracker.Receipts", code: response.statusCode, userInfo: nil)
                completion(statusCodeError)
            }
      
            completion(nil)
        }.resume()
    }
    
    
    //MARK: - Log In URLSessionDataTask
    func signIn(with user: User, completion: @escaping (Error?) -> Void) {
        
        let requestURL = loginBaseURL
            .appendingPathComponent("users")
            .appendingPathComponent("login")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            NSLog("Error encoding user for sign in: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                NSLog("Error signing in user: \(error)")
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                
                let statusCodeError = NSError(domain: "com.ReceiptTracker.Receipts", code: response.statusCode, userInfo: nil)
                completion(statusCodeError)
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                let noDataError = NSError(domain: "com.ReceiptTracker.Receipts", code: -1, userInfo: nil)
                completion(noDataError)
                return
            }
            do {
                let bearer = try JSONDecoder().decode(Bearer.self, from: data)
                self.bearer = bearer
            } catch {
                NSLog("Error decoding the bearer token: \(error)")
                completion(error)
            }
            
            completion(nil)
        }.resume()
    }
}
