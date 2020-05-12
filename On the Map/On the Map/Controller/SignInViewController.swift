//
//  SignInViewController.swift
//  On the Map
//
//  Created by Hanoudi on 5/10/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    //  MARK:- Variables and Outlets
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    

    // MARK:- UI Methods
    
    @IBAction func signIn(_ sender: Any) {
        //disable UI during login
        enableUI(false)
        //save email and password in userData
        let userData = LoginData(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "")
        // attempt to login in
        UdacityStudent.login(userData: userData, completion: handleLogin(registered:error:))
    }
    
    // If user has entered correct info and user is authorized sign in
    // else return to sign in view
    
    func handleLogin(registered: Bool, error: Error?){
        enableUI(false)
        guard error == nil, registered == true
            else {
                displayErrorAlert(title: "Sign in Failed", message: error?.localizedDescription ?? "Error")
                enableUI(true)
                return
            }
        self.performSegue(withIdentifier: "SignIn", sender: self)
    }
    
    //  MARK:- SignInView Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableUI(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribeToKeyboardNotifications()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillAppear(animated)
            unsubscribeFromKeyboardNotifications()
        }

}

// MARK:- TextField Delegation Methods

extension SignInViewController: UITextFieldDelegate {

    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if passwordTextField.isFirstResponder && view.frame.origin.y == 0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }

    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if passwordTextField.isFirstResponder && view.frame.origin.y != 0  {
            view.frame.origin.y = 0
        }
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

   
    //  MARK:- Show network activity spinner and disable UI accordingly
    func enableUI(_ bool: Bool){
        if !bool{
            activityIndicator.startAnimating()
            usernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            signInButton.isEnabled = false
        }else{
            activityIndicator.stopAnimating()
            usernameTextField.isEnabled = true
            passwordTextField.isEnabled = true
            signInButton.isEnabled = true
        }
    }
}

//  MARK:- Extension, to work with any view that inherits from UIViewController
extension UIViewController{
    
    // MARK: Display Error Message to the User
    func displayErrorAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let errorButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(errorButton)
        present(alertController, animated: true, completion: nil)
    }
}
