//
//  PatientData.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 15.05.2022.
//

import Foundation

struct Patient: Codable {
    
    var id: String
    var name: String
    var surname: String
    
    var age: Int?
    var description: String?
}
