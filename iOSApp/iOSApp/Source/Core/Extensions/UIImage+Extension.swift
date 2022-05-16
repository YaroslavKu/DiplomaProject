//
//  UIImage+Extension.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 16.05.2022.
//

import Foundation
import UIKit

extension UIImage {
    static func getInitialsImage(initials: String) -> UIImage {
        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = UIColor.pickColor(alphabet: initials.first ?? "A")
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 32)
        nameLabel.text = initials
        
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage ?? UIImage()
        }
        
        return UIImage()
    }
}
