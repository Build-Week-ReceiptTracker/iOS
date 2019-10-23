//
//  ReceiptDetailViewController.swift
//  ReceiptTracker
//
//  Created by macbook on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class ReceiptDetailViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    var receipt: Receipt?
    var receiptController: ReceiptController?
    let dateFormatter = DateFormatter()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    //MARK: Actions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        if receipt == nil {
            guard let merchant = nameTextField.text,
                let date = dateTextField.text,
                let dateFormatted = dateFormatter.date(from: date),
                let category = categoryTextField.text,
                let amount = amountTextField.text,
                let imageURL = pictureImageView,
                !merchant.isEmpty,
                !date.isEmpty,
                !category.isEmpty else { return }
            
            //TODO: Call method(s) to create new receipt
            
            
            let newReceipt = Receipt(date: dateFormatted, amount: amount as! Double, category: category, merchant: merchant, receiptDescription: nil, imageURL: nil, context: CoreDataStack.shared.mainContext)
            receiptController?.addNewReceiptToServer(receipt: newReceipt)
            
        } else { return }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        showAlert()
    }
    
    //MARK: Method for an Alert with cancel & delete show options
    private func showAlert() {
        // Create the alert
        let alert = UIAlertController(title: "Delete Receipt?", message: "All data from this Receipt will be erased", preferredStyle: .alert)
        // Add an action (button)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            //do something
            self.navigationController?.popToRootViewController(animated: true) }))
        // Adding another action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            guard let receipt = self.receipt else { return }
            //TODO: Delete function -> self.receiptController?.removeFromPersistentStore(receipt: receipt)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        // Show the alert
        present(alert, animated: true, completion: nil)
    }
    
    func updateViews() {
        
        
        
        guard let receipt = receipt,
            let date = receipt.date,
            let imageURL = receipt.imageURL else {
                
                nameTextField.isEnabled = true
                dateTextField.isEnabled = true
                categoryTextField.isEnabled = true
                amountTextField.isEnabled = true
                
                nameTextField.text = ""
                dateTextField.text = ""
                categoryTextField.text = ""
                amountTextField.text = ""
                
                return
        }
        
        nameTextField.text = receipt.merchant
        dateTextField.text = dateFormatter.string(from: date)
        categoryTextField.text = receipt.category
        amountTextField.text = String(receipt.amount)
        pictureImageView.image = UIImage(named: imageURL)
        
        nameTextField.isEnabled = false
        dateTextField.isEnabled = false
        categoryTextField.isEnabled = false
        amountTextField.isEnabled = false
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
//          //TODO: Add done button if theres no back button on screen
//        //MARK: dismiss view with Done button
//        @IBAction func doneButton(_ sender: UIBarButtonItem) {
//            navigationController?.popToRootViewController(animated: true)
//        }
    
}
