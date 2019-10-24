//
//  ReceiptTableViewCell.swift
//  ReceiptTracker
//
//  Created by macbook on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class ReceiptTableViewCell: UITableViewCell {
    
    //MARK: Oulets
    @IBOutlet weak var merchantLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // Properties
    var receiptRepresentation: ReceiptRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let receipt = receiptRepresentation else { return }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        
        //merchantLabel.text = formatter.string(from: receipt.dateOfTransaction)
        merchantLabel.text = receipt.merchant
        
        //priceLabel.text = currencyFormatter.string(for: receipt.amountSpent)
        priceLabel.text = receipt.amountSpent
    }
}
