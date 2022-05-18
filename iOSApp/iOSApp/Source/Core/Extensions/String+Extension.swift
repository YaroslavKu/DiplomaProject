//
//  String+Extension.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 19.05.2022.
//

import Foundation

extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date?{

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fa-IR")
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)

        return date

    }
}
