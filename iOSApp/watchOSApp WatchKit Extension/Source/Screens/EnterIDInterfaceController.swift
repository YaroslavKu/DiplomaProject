//
//  EnterIDInterfaceController.swift
//  watchOSApp WatchKit Extension
//
//  Created by Yaroslav Kukhar on 17.05.2022.
//

import WatchKit
import Foundation
import Firebase

class EnterIDInterfaceController: WKInterfaceController {

    var id: String? {
        didSet {
            idLabel.setText(id)
        }
    }
    
    @IBOutlet weak var idLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func backPaceButtonPressed() {
        WKInterfaceDevice.current().play(.click)
        if let id = self.id, !id.isEmpty {
            self.id = String(id.dropLast())
        }
    }
    
    
    @IBAction func oneButtonPressed() {
        addCheracterToId("1")
    }
    
    @IBAction func twoButtonPressed() {
        addCheracterToId("2")
    }
    
    @IBAction func threeButtonPressed() {
        addCheracterToId("3")
    }
    
    
    @IBAction func fourButtonPressed() {
        addCheracterToId("4")
    }
    
    
    @IBAction func fiveButtonPressed() {
        addCheracterToId("5")
    }
    
    @IBAction func sixButtonPressed() {
        addCheracterToId("6")
    }
    
    @IBAction func sevenButtonPressed() {
        addCheracterToId("7")
    }
    
    
    @IBAction func eightButtonPressed() {
        addCheracterToId("8")
    }
    
    @IBAction func nineButtonPressed() {
        addCheracterToId("9")
        
    }
    
    @IBAction func zeroButtonPressed() {
        addCheracterToId("0")
    }
    
    @IBAction func doneButtonPressed() {
        WKInterfaceDevice.current().play(.click)
        
        if id == nil || id?.isEmpty == true {
            playError()
        } else {
            let ref = Database.database().reference()
            ref.child("patients/\(id!)").getData(completion:  { error, snapshot in
                guard error == nil else {
                    self.playError()
                    print(error!.localizedDescription)
                    return
                }
                guard let value = snapshot.value as? [String: Any],
                      let supervisor = value["supervisor"] as? String else {
                    self.playError()
                    return
                }
                UserDefaults.standard.set(supervisor, forKey: Constants.UserDefaultsKeys.supervisorUid)
                UserDefaults.standard.set(self.id!, forKey: Constants.UserDefaultsKeys.patientId)
                self.dismiss()
            })
        }
    }
    
    private func addCheracterToId(_ character: String) {
        WKInterfaceDevice.current().play(.click)
        if id?.isEmpty == false {
            self.id = id! + character
        } else {
            self.id = character
        }
    }
    
    private func playError() {
        WKInterfaceDevice.current().play(.retry)
        self.idLabel.setText("Wrong id")
        self.idLabel.setTextColor(.red)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.idLabel.setTextColor(.white)
            self.idLabel.setText(self.id ?? "")
        })
    }
}
