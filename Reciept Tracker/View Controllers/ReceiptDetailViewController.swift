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
    
    //Properties
    var receipt: Receipt?
    var receiptController: ReceiptController?
    var logInController: LogInController?
    let dateFormatter = DateFormatter()
    let imagePicker = UIImagePickerController()
    let config = CLDConfiguration(cloudName: "iosdevlambda", secure: true) //https
    
    //Cloudinary
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
            
            //Create new receipt
            receiptController?.createReceipt(dateOfTransaction: date, amountSpent: amountString, category: category, merchant: merchant, imageURL: nil, username: username, receiptDescription: nil, context: CoreDataStack.shared.mainContext)
            
        } else {
            guard let receipt = receipt,
                let date = receipt.dateOfTransaction,
                let amount = receipt.amountSpent,
                let category = receipt.category,
                let merchant = receipt.merchant else { return }
            // call update here
            receiptController?.updateReceipt(receipt: receipt, date: date, amount: amount, category: category, merchant: merchant, receiptDescription: receipt.receiptDescription, imageURL: receipt.imageURL, context: CoreDataStack.shared.mainContext)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // Adding Image with Image Picker
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }

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
    }
}

extension ReceiptDetailViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            pictureImageView.contentMode = .scaleAspectFit
            pictureImageView.image = pickedImage
            imageUpload(image: pickedImage)
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    // If Choose to cancel selecting Image from picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageUpload(image: UIImage) {
        
        let cloudinary = CLDCloudinary(configuration: config)
        
        let imageData = image.pngData()
        guard let image = imageData else { return }
        
        cloudinary.createUploader().upload(data: image, uploadPreset: cloudinaryUploadPresent)
    }
}
