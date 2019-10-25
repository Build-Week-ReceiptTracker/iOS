//
//  ReceiptDetailViewController.swift
//  ReceiptTracker
//
//  Created by macbook on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import Cloudinary

class ReceiptDetailViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    var receipt: Receipt?
    var receiptController: ReceiptController?
    var logInController: LogInController?
    let dateFormatter = DateFormatter()
    let imagePicker = UIImagePickerController()
//    var jpegImage: String = ""
    
    //TODO: Pass them to the file that manages the image uploading
    var cloudinaryURL =  "https://api.cloudinary.com/v1_1/iosdevlambda"
    var cloudinaryUploadPresent = "z2og3e0q"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
          imagePicker.delegate = self
        dateFormatter.dateFormat = "MM/dd/yy"
    }
    
    //MARK: Actions
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        if receipt == nil {
            guard let merchant = nameTextField.text,
                let date = dateTextField.text,
                let category = categoryTextField.text,
                let amountString = amountTextField.text,
                let logInController = logInController,
                let username = logInController.username,
                // let imageURL = pictureImageView.image,
                !merchant.isEmpty,
                !date.isEmpty,
                !category.isEmpty else { return }
            
            //TODO: Call method(s) to create new receipt
            receiptController?.createReceipt(dateOfTransaction: date, amountSpent: amountString, category: category, merchant: merchant, imageURL: nil, username: username, receiptDescription: nil, context: CoreDataStack.shared.mainContext)
            
        } else {
            guard let receipt = receipt,
                let date = receipt.dateOfTransaction,
                let amount = receipt.amountSpent,
                let category = receipt.category,
                let merchant = receipt.merchant else { return }
            // call update here
            receiptController?.updateReceipt(receipt: receipt, date: date, amount: amount, category: category, merchant: merchant, receiptDescription: receipt.receiptDescription, imageURL: receipt.imageURL, context: CoreDataStack.shared.mainContext)
            return
            
        }
        navigationController?.popViewController(animated: true)
    }
    
    // Adding Image with Image Picker
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
//    
//    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
//        showAlert()
//    }
//    
//    //MARK: Method for an Alert with cancel & delete show options
//    private func showAlert() {
//        // Create the alert
//        let alert = UIAlertController(title: "Delete Receipt?", message: "All data from this Receipt will be erased", preferredStyle: .alert)
//        // Add an action (button)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
//            //do something
//            self.navigationController?.popToRootViewController(animated: true) }))
//        // Adding another action
//        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
//            guard let receipt = self.receipt else { return }
//            //TODO: Delete function -> self.receiptController?.removeFromPersistentStore(receipt: receipt)
//            self.navigationController?.popToRootViewController(animated: true)
//        }))
//        // Show the alert
//        present(alert, animated: true, completion: nil)
//    }
    
    func updateViews() {
        guard let receipt = receipt,
            let amountSpent = receipt.amountSpent,
            let date = receipt.dateOfTransaction,
            let imageURL = receipt.imageURL else {
                
                nameTextField.text = ""
                dateTextField.text = ""
                categoryTextField.text = ""
                amountTextField.text = ""
                return
        }
        
        nameTextField.text = receipt.merchant
        //dateTextField.text = dateFormatter.date(from: date)
        dateTextField.text = date
        categoryTextField.text = receipt.category
        amountTextField.text = amountSpent
        pictureImageView.image = UIImage(named: imageURL)
        
//        nameTextField.isEnabled = false
//        dateTextField.isEnabled = false
//        categoryTextField.isEnabled = false
//        amountTextField.isEnabled = false
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

extension ReceiptDetailViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            pictureImageView.contentMode = .scaleAspectFit
            pictureImageView.image = pickedImage
            imageUpload(image: pickedImage)
            
//
//            // Encoding the image to jpegData
//            let jpegCompressionQuality: CGFloat = 0.9
//
//            if let jpegImage = pickedImage.jpegData(compressionQuality: jpegCompressionQuality)?.base64EncodedString() {
//                self.jpegImage = jpegImage
//            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // If Choose to cancel selecting Image from picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageUpload(image: UIImage) {
        let config = CLDConfiguration(cloudName: "iosdevlambda", secure: true) //https
        let cloudinary = CLDCloudinary(configuration: config)
        
        let imageData = image.pngData()
        guard let image = imageData else { return }
        
        cloudinary.createUploader().upload(data: image, uploadPreset: cloudinaryUploadPresent)
    }
}
