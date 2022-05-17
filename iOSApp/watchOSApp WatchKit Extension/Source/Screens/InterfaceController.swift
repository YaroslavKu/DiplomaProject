//
//  InterfaceController.swift
//  watchOSApp WatchKit Extension
//
//  Created by Yaroslav Kukhar on 17.05.2022.
//

import WatchKit
import Foundation
import Firebase

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var connectTitle: WKInterfaceLabel!
    @IBOutlet weak var connectButton: WKInterfaceButton!
    @IBOutlet weak var supervisorTitle: WKInterfaceLabel!
    @IBOutlet weak var superviserName: WKInterfaceLabel!
    @IBOutlet weak var patientIdTitle: WKInterfaceLabel!
    @IBOutlet weak var separetoView: WKInterfaceSeparator!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        setupViews()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    private func setupViews() {
        if let supervisorUid = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.supervisorUid),
           let patientId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.patientId)
        {
            separetoView.setHidden(false)
            connectTitle.setHidden(false)
            connectButton.setHidden(false)
            supervisorTitle.setHidden(false)
            superviserName.setHidden(false)
            patientIdTitle.setHidden(false)
            
            patientIdTitle.setText("Patient id: \(patientId)")
            
            let ref = Database.database().reference()
            ref.child("users/\(supervisorUid)/name").getData(completion:  { error, snapshot in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                guard let value = snapshot.value as? String else { return }
                self.superviserName.setText(value)
            })
            
        } else {
            connectTitle.setHidden(false)
            connectButton.setHidden(false)
            supervisorTitle.setHidden(true)
            superviserName.setHidden(true)
            patientIdTitle.setHidden(true)
            separetoView.setHidden(true)
        }
    }
}
