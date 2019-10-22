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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: Actions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
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
            //TODO: self.receiptController?.removeFromPersistentStore(receipt: receipt)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        // Show the alert
        present(alert, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
