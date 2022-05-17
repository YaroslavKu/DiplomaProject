//
//  AddPatientViewController.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 15.05.2022.
//

import UIKit
import Firebase

class AddPatientViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    private var patientIdentifier: String?
    private let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generatePatientId()
        doneButton.isEnabled = false
        
        nameTextField.delegate = self
        surnameTextField.delegate = self
    }

    @IBAction func addPatientAction(_ sender: Any) {
        createPatient()
    }
}

private extension AddPatientViewController {
    func createPatient() {
        if let name = nameTextField.text, !name.isEmpty,
           let surname = surnameTextField.text, !surname.isEmpty {
            guard let id = patientIdentifier else  {
                let alert = UIAlertController(title: "Error", message: "Something went wronk. Please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                present(alert, animated: true)
                return
            }
            
            guard let uid = UserData.shared.userUid else { return }
            ref.child("users/\(uid)/patients").child(id).setValue([
                "id": id,
                "name": name,
                "surname": surname
            ])
            
            ref.child("patients/\(id)").setValue([
                "supervisor": uid
            ])
            
            let alert = UIAlertController(title: "Done", message: "Patient \(name) \(surname) was succesfully added \n ID - \(id)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
                self.dismiss(animated: true, completion: {})
            })
            present(alert, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill in all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
    }
    
    func generatePatientId() {
        let letters = "0123456789"
        
        let randomString = String((0 ..< 6).map { _ in letters.randomElement()! })
        
        ref.child("patients/\(randomString)").getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                self.generatePatientId()
                return
            }
            
            self.doneButton.isEnabled = true
            self.patientIdentifier = randomString
            
        })
    }
}

extension AddPatientViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == nameTextField {
            surnameTextField.becomeFirstResponder()
            
        } else {
            createPatient()
        }
        
        return true
    }
}
