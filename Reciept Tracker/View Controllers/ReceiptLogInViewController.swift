//
//  ReceiptLogInViewController.swift
//  ReceiptTracker
//
//  Created by macbook on 10/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class ReceiptLogInViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var logInSegmentedControl: UISegmentedControl!
    @IBOutlet weak var logInButton: UIButton!
    
    //MARK: Properties
    var logInController: LogInController!
    var receiptController: ReceiptController!
    var loginType = LoginType.signUp
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions Handlers
    
    // LogIn/SignUp Segment Controller
    @IBAction func logInSegmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            logInButton.setTitle("Sign Up", for: .normal)
            emailTextField.isUserInteractionEnabled = true
            emailTextField.alpha = 1
        } else {
            loginType = .logIn
            logInButton.setTitle("Log In", for: .normal)
            emailTextField.text = ""
            emailTextField.isUserInteractionEnabled = false
            emailTextField.alpha = 0
        }
    }
    
    
    // LogIn/SignUp Button
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        // Create a user
        guard let username = usernameTextField.text,
            let password = passwordTextField.text,
            !username.isEmpty,
            !password.isEmpty else { return }
        
        // perform login or sign up operation based on loginType
        if loginType == .signUp {
            guard let email = emailTextField.text, !email.isEmpty else { return }
            let user = User(username: username, email: email, password: password)
            signUp(with: user)
        } else {
            let user = User(username: username, email: nil, password: password)
            logIn(with: user)
        }
    }
    
    //MARK: LogIn/SignUp functions
    
    func signUp(with user: User) {
        logInController.signUp(with: user) { (error) in
            if let error = error {
                NSLog("Error occurred during sign up: \(error)")
            } else {
                let alert = UIAlertController(title: "Sign Up Successful",
                                              message: "Now please log in",
                                              preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(okAction)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true) {
                        self.loginType = .logIn
                        self.logInSegmentedControl.selectedSegmentIndex = 1
                        self.logInButton.setTitle("Log In", for: .normal)
                        self.emailTextField.text = ""
                        self.emailTextField.isUserInteractionEnabled = false
                        self.emailTextField.alpha = 0
                    }
                }
            }
        }
    }
    
    func logIn(with user: User) {
        logInController.logIn(with: user) { (error) in
            if let error = error {
                NSLog("Error occurred during sign in: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.receiptController.bearer = self.logInController.bearer
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}

enum LoginType {
    case logIn
    case signUp
}
