//
//  TextTableViewCell.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 16.05.2022.
//

import UIKit

class TextTableViewCell: UITableViewCell {
    static let identifier = "TextTableViewCell"
    
    private var textLabelView: UILabel = UILabel()
    
    private var text: String? {
        didSet {
            textLabelView.text = text
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabelView.clipsToBounds = true
        contentView.addSubview(textLabelView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabelView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textLabelView.text = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func configure(with text: String) {
        self.text = text
    }
}
