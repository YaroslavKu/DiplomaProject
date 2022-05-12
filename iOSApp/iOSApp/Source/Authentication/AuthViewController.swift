//
//  AuthViewController.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 21.03.2022.
//

import UIKit
import Firebase

class AuthViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var switchLoginButton: UIButton!
    
    private var signUp: Bool = true {
        willSet {
            UIView.animate(withDuration: 0.3, animations: {
                if newValue {
                    self.titleLabel.text = "Sign Up"
                    self.authButton.setTitle("Sign Up", for: .normal)
                    self.switchLoginButton.setTitle("Already have an account? Sign In", for: .normal)
                    self.nameField.isHidden = false
                    self.confirmPasswordField.isHidden = false
                } else {
                    self.titleLabel.text = "Sign In"
                    self.authButton.setTitle("Sign In", for: .normal)
                    self.switchLoginButton.setTitle("Don't have an account? Register", for: .normal)
                    self.nameField.isHidden = true
                    self.confirmPasswordField.isHidden = true
                }
            }, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }
    
    @IBAction func authAction(_ sender: Any) {
        signUp == true ? createUser() : login()
    }
    
    @IBAction func switchLogin(_ sender: Any) {
        signUp = !signUp
    }
}

private extension AuthViewController {
    func setupViews() {
        
    }
    
    func showAuthAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    func login() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        if !email.isEmpty, !password.isEmpty {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
                if error == nil {
                    self.dismiss(animated: true, completion: {})
                } else {
                    // TODO: Add error processing
                    print("Error \(error.debugDescription)")
                }
            })
        } else {
            showAuthAlert(message: "Fill in all fields")
        }
    }
    
    func createUser() {
        let name = nameField.text ?? ""
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let confirmPassowd = confirmPasswordField.text ?? ""
        
        if !name.isEmpty,
           !email.isEmpty,
           !password.isEmpty,
           !confirmPassowd.isEmpty {
            guard password == confirmPassowd else {
                showAuthAlert(message: "Passwords do not match")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
                if error == nil {
                    if let result = result {
                        let ref = Database.database().reference()
                        ref.child("users").child(result.user.uid).setValue([
                            "name": name,
                            "email": email
                        ])
                        
                        self.dismiss(animated: true, completion: {})
                    }
                } else {
                    // TODO: Add error processing
                    print("Error \(error.debugDescription)")
                }
            })
        } else {
            showAuthAlert(message: "Fill in all fields")
        }
    }
}

extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == nameField {
            emailField.becomeFirstResponder()
            
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
            
        } else if textField == passwordField {
            if signUp {
                confirmPasswordField.becomeFirstResponder()
            } else {
                login()
            }
            
        } else if textField == confirmPasswordField {
            createUser()
        }
        
        return true
    }
}
