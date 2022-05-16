//
//  HomeModel.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 15.05.2022.
//

import Foundation
import Firebase

class HomeModel {
    var patientsList: [Patient] = []
    
    func load(completion: @escaping (() -> Void)) {
        patientsList  = []
        UserData.shared.getPatients() { patientsDict in
            patientsDict.forEach({ p in
                if let patient = p.value as? [String: Any] {
                    self.patientsList.append(Patient(from: patient))
                }
            })
            
            completion()
        }
    }
}
