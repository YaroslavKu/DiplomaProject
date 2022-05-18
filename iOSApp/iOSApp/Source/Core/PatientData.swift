//
//  PatientData.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 15.05.2022.
//

import Foundation
import Firebase

class Patient {
    private let ref = Database.database().reference()
    
    var id: String
    var name: String
    var surname: String
    
    var phone: String?
    var age: Int?
    var description: String?
    
    var heartRate: Double?
    var saturation: [String: Int]?
    
    var isAppleWatchConnected: Bool?
    
    init(from dict: [String: Any]) {
        self.id = dict["id"] as? String ?? ""
        self.name = dict["name"] as? String ?? "Unknown"
        self.surname = dict["surname"] as? String ?? " "
        self.phone = dict["phone"] as? String
        self.age = dict["age"] as? Int
        self.description = dict["description"] as? String
        self.heartRate = dict["heartRate"] as? Double
        self.saturation = dict["saturation"] as? [String: Int]
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
    
    func onHeartRateDidChange(completion: @escaping (() -> Void)) {
        guard let uid = UserData.shared.userUid else { return }
        ref.child("users/\(uid)/patients/\(id)/heartRate").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? Double else { return }
            self.heartRate = value
            completion()
        })
    }
    
    func removeAllObservers() {
        ref.removeAllObservers()
    }
}
