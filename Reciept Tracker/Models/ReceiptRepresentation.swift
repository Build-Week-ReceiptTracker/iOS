//
//  ReceiptRepresentation.swift
//  ReceiptTracker
//
//  Created by macbook on 10/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
//import UIKit

struct ReceiptRepresentation: Codable {
    var id: Int16
    let dateOfTransaction: Date
    let amountSpent: Double
    let category: String
    let merchant: String
    let imageURL: String?
    let description: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case dateOfTransaction = "date_of_transaction"
        case amountSpent = "amount_spent"
        case category
        case merchant
        case imageURL = "image_url"
        case description
    }
}

struct PostReceiptRepresentation: Encodable {
    let dateOfTransaction: Date
    let amountSpent: Double
    let category: String
    let merchant: String
    let imageURL: String?
    let userUsername: String
    let description: String?
    
    private enum CodingKeys: String, CodingKey {
        case dateOfTransaction = "date_of_transaction"
        case amountSpent = "amount_spent"
        case category
        case merchant
        case imageURL = "image_url"
        case userUsername = "user_username"
        case description
    }
}

struct ReceiptID: Codable {
    let receiptID: Int16
}
