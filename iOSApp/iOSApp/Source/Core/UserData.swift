//
//  UserData.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 13.05.2022.
//

import Foundation
import Firebase

class UserData {
    public static var shared = UserData()
    
    private let ref = Database.database().reference()
    
    var userUid: String? = Auth.auth().currentUser?.uid
    var userName: String = "Unknown"
    
    
    private init() {
    }
    
    public func getUserName(completion: @escaping ((String) -> Void)) {
        guard let uid = userUid else { return }
        ref.child("users/\(uid)/name").getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let value = snapshot.value as? String else { return }
            completion(value)
        })
    }
    
    public func getPatients(completion: @escaping (([String: Any]) -> Void)) {
        guard let uid = userUid else { return }
        ref.child("users/\(uid)/patients").getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let value = snapshot.value as? [String: Any] else { return }
            completion(value)
        })
    }
}

