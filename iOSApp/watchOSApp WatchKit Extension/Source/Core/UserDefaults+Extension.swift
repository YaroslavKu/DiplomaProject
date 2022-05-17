//
//  UserDefaults+Extension.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 17.05.2022.
//

import Foundation

extension UserDefaults {
    @objc dynamic var supervisorUid: Int {
        return integer(forKey: Constants.UserDefaultsKeys.supervisorUid)
    }
}
