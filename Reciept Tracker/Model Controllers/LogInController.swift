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

    //var receipts: [Receipt] = []
    
    var bearer: Bearer?
    var username: String?
    private let loginBaseURL = URL(string: "https://api-receipt-tracker.herokuapp.com/api")!

    // MARK: - Sign Up  &  Log In Functions :
    
    // MARK: - Sign Up URLSessionDataTask
    func signUp(with user: User, completion: @escaping (Error?) -> Void) {
        
        // Building the URL
        let requestURL = loginBaseURL.appendingPathComponent("register")
        
        // Building the request
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        
        let encoder = JSONEncoder()
        
        do {
            let userJSON = try encoder.encode(user)
            request.httpBody = userJSON
        } catch {
            NSLog("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Handle errors
            if let error = error {
                NSLog("Error signing up user: \(error)")
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200, response.statusCode != 201 {
                
                let statusCodeError = NSError(domain: "com.ReceiptTracker.Receipts", code: response.statusCode, userInfo: nil)
                completion(statusCodeError)
                return
            }
            completion(nil)
        }.resume()
    }
    
    //MARK: - Log In URLSessionDataTask
    func logIn(with user: User, completion: @escaping (Error?) -> Void) {
        
        let requestURL = loginBaseURL.appendingPathComponent("login")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: HeaderNames.contentType.rawValue)
        request.httpMethod = HTTPMethod.post.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            NSLog("Error encoding user for sign in: \(error)")
            completion(error)
            return
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
                return
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
                self.username = user.username
                print(bearer.token)
            } catch {
                NSLog("Error decoding the bearer token: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
}
