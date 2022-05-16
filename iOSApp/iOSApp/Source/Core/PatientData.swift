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
    
    var phone: String?
    var age: Int?
    var description: String?
    
    var isAppleWatchConnected: Bool?
    
    init(from dict: [String: Any]) {
        self.id = dict["id"] as? String ?? ""
        self.name = dict["name"] as? String ?? "Unknown"
        self.surname = dict["surname"] as? String ?? " "
        self.phone = dict["phone"] as? String
        self.age = dict["age"] as? Int
        self.description = dict["description"] as? String
    }
    
    public func toDict() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "surname": surname,
            "phone": phone,
            "age": age,
            "description": description,
        ]
    }
}
