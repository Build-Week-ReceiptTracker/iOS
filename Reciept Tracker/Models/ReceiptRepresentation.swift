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
    
    // TODO: match the name to the backend name
    
}

struct ReceiptID: Codable {
    let receiptID: Int16
}
