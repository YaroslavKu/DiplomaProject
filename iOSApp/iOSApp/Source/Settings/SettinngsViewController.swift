//
//  SettinngsViewController.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 12.05.2022.
//

import UIKit
import Firebase

class SettinngsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            // TODO: Add error processing
            print("Error on sigtout action")
        }
    }
}
