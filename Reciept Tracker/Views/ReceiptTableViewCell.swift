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
    var sortType: SortingType?
    var sortOption: SortingOption?
    var receipt: Receipt? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: IBActions
    @IBAction func sortingSegmentedControl(_ sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex
        
        switch index {
        case 0 :
            sortType = .merchant
        case 1 :
            sortType = .amount
        case 2 :
            sortType = .date
        case 3:
            sortType = .category
        default :
            sortType = .merchant
        }
    }
    
    @IBAction func sortingOptionSegmentedControl(_ sender: UISegmentedControl) {
    }
    
    func updateViews() {
        guard let receipt = receipt,
            let sortType = sortType else { return }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        if sortType != .merchant {
            merchantLabel.text = receipt.merchant
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            
            merchantLabel.text = formatter.string(from: receipt.date!)
        }
        
        priceLabel.text = currencyFormatter.string(for: receipt.amount)
        
    }
}
