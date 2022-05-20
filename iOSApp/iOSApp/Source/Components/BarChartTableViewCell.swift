//
//  BarChartTableViewCell.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 19.05.2022.
//

import UIKit
import Charts

class BarChartTableViewCell: UITableViewCell {
    static let identifier = "BarChartTableViewCell"
    
    private var barChartView: BarChartView?
    private var addDataButton: UIButton?
    
    private var addValuaeAction: (() -> Void)?
    private var barChartData: BarChartData? {
        didSet {
            barChartView?.data = barChartData
            barChartView?.isHidden = false
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        barChartView = BarChartView()
        barChartView?.clipsToBounds = true
        contentView.addSubview(barChartView!)
        
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "+"
        
        addDataButton = UIButton(configuration: configuration)
//        addDataButton?.
        addDataButton?.addTarget(self, action: #selector(handleAddDataTap(_:)), for: .touchUpInside)
        contentView.addSubview(addDataButton!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        barChartView?.frame = CGRect(x: 10, y: 10, width: contentView.frame.width - 20, height: contentView.frame.height - 20)
        barChartView?.layer.cornerRadius = 20
        barChartView?.center = contentView.center
        barChartView?.backgroundColor = .black
        barChartView?.legend.textColor = .white
        barChartView?.xAxis.labelTextColor = .white
        barChartView?.rightAxis.labelTextColor = .white
        barChartView?.tintColor = .white
        barChartView?.data?.setValueTextColor(.white)
        if barChartView?.data == nil {
            barChartView?.isHidden = true
            backgroundColor = .clear
        }
        
        addDataButton?.frame = CGRect(x: 20, y: 25, width: 40, height: 30)
        addDataButton?.tintColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        barChartView?.data = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func configure(with data: BarChartData, addAction: (() -> Void)?) {
        barChartData = data
        addValuaeAction = addAction
    }
    
    @objc func handleAddDataTap(_ sender: UIButton) {
        addValuaeAction?()
    }
}
