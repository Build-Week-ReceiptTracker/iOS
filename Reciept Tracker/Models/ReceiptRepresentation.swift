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
    let date: Date
    let amount: Double
    let category: String
    let merchant: String
    let receiptDescription: String
    let imageURL: String
    let id: Int16

}
