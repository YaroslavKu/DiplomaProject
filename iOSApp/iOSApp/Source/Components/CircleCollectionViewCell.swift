//
//  CircleCollectionViewCell.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 15.05.2022.
//

import UIKit

class CircleCollectionViewCell: UICollectionViewCell {
    static let identifier = "CircleCollectionViewCell"
    
    private var imageView: UIImageView = UIImageView()
    private var nameLabel: UILabel = UILabel()
    
    private var name: String = "" {
        didSet {
            nameLabel.text = name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        contentView.addSubview(imageView)
        
        nameLabel.numberOfLines = 2
        nameLabel.font = nameLabel.font.withSize(12)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        nameLabel.frame = CGRect(x: 0, y: 70, width: 70, height: 50)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        nameLabel.text = nil
    }
    
    public func configure(with model: Patient) {
        var initials = ""
        if let nameFirstLetter = model.name.first {
            if let surnameFirstLetter = model.surname.first {
                initials = "\(nameFirstLetter)\(surnameFirstLetter)"
            } else {
                initials = "\(nameFirstLetter)"
            }
        }
        
        imageView.image = getInitialsImage(initials: initials)
        name = "\(model.name) \(model.surname)"
    }
    
    public func configure(initials: String, label: String) {
        imageView.image = getInitialsImage(initials: initials)
        name = label
    }
    
    public func setSelected(_ isSelected: Bool) {
        imageView.layer.borderWidth = isSelected ? 3 : 0
        imageView.layer.borderColor = UIColor.ocean.cgColor
    }
    
    
    // TODO: Replase with UIImage extension
    private func getInitialsImage(initials: String) -> UIImage {
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
