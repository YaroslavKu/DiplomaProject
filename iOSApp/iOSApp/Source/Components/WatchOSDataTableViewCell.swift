//
//  WatchOSDataTableViewCell.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 18.05.2022.
//

import UIKit

class WatchOSDataTableViewCell: UITableViewCell {
    static let identifier = "WatchOSDataTableViewCell"
    
    private var containerView = UIView()
    private var heartRateLabel: UILabel = UILabel()
    private var oxygenReateLabel: UILabel = UILabel()
    
    private var heartRate: String? {
        didSet {
            heartRateLabel.text = heartRate
        }
    }
    
    private var oxygenRate: String? {
        didSet {
            oxygenReateLabel.text = oxygenRate
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.clipsToBounds = true
        contentView.addSubview(containerView)
        
        heartRateLabel.clipsToBounds = true
        containerView.addSubview(heartRateLabel)
        
        oxygenReateLabel.clipsToBounds = true
        containerView.addSubview(oxygenReateLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = CGRect(x: 5, y: 5, width: contentView.frame.width - 10, height: contentView.frame.height - 10)
        containerView.layer.cornerRadius = 20
        
        heartRateLabel.textAlignment = .center
        heartRateLabel.textColor = .white
        heartRateLabel.font =  UIFont.boldSystemFont(ofSize: 28)
        heartRateLabel.frame = CGRect(x: 5, y: 0, width: (containerView.frame.width / 2) - 10, height: containerView.frame.height)
        
        oxygenReateLabel.textAlignment = .center
        oxygenReateLabel.textColor = .white
        oxygenReateLabel.font =  UIFont.boldSystemFont(ofSize: 28)
        oxygenReateLabel.frame = CGRect(x: (containerView.frame.width / 2) + 5,
                                        y: 0,
                                        width: (containerView.frame.width / 2) - 10,
                                        height: containerView.frame.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        heartRateLabel.text = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func configure(heartRate: String, oxygenRate: String, bgColor: UIColor) {
        self.heartRate = heartRate
        self.oxygenRate = oxygenRate
        containerView.backgroundColor = bgColor
    }
}
