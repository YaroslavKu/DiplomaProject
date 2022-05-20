//
//  HomeViewController+UITableViewDataSource.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 19.05.2022.
//

import Foundation
import UIKit
import Charts

// MARK: UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataCount = selectedPatient?.data?.keys.count {
            return dataCount + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.row == 0 {
                return 70
        } else {
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return configureWatchDateCell(for: indexPath)
        } else {
            return configureBarChartCell(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = .ocean
        
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 5, width: headerView.frame.width-50, height: headerView.frame.height-10)
        label.font = .systemFont(ofSize: 21)
        label.textColor = .white
        headerView.addSubview(label)
        if let patient = selectedPatient {
            label.text = "\(patient.name) \(patient.surname)"
        } else {
            label.text = "Unknown"
        }
        
        let image = UIImage(systemName: "chevron.right")
        let icon = UIImageView(image: image)
        icon.frame = CGRect(x: headerView.frame.width - 40,
                            y: 15,
                            width: headerView.frame.height-30,
                            height: headerView.frame.height-30)
        icon.tintColor = .white
        headerView.addSubview(icon)
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(self.handleHeaderTap(_:)))
        headerView.addGestureRecognizer(tap)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    @objc func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "PatientProfile", bundle: nil)
        let patientProfileVC = storyboard.instantiateViewController(withIdentifier: "PatientProfileViewController") as! PatientProfileViewController
        patientProfileVC.patient = selectedPatient
        present(patientProfileVC, animated: true, completion: nil)
    }
}

private extension HomeViewController {
    private func configureWatchDateCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: WatchOSDataTableViewCell.identifier, for: indexPath) as? WatchOSDataTableViewCell else {
            return UITableViewCell()
        }
        
        var heartRate: String {
            if let heartRate = selectedPatient?.heartRate {
                return String(Int(heartRate))
            } else {
                return "nil"
            }
        }
        
        var saturation: String {
            guard let saturationDict = selectedPatient?.data?["saturation"]  as? [String: Double]else { return "nil" }
            
            let latestDate = Array(saturationDict.keys).sorted(by: {$0.toDate()! > $1.toDate()!})[0]
            
            guard let saturation = saturationDict[latestDate] else { return "nil" }
            return String(saturation)
        }
        
        cell.configure(heartRate: "❤️ \(heartRate) bpm",
                       oxygenRate: "🅾️ \(saturation)%",
                       bgColor: UIColor.pickColor(alphabet: selectedPatient?.name.first ?? "A"))
        
        return cell
    }
    
    private func configureBarChartCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: BarChartTableViewCell.identifier,
                                                        for: indexPath) as? BarChartTableViewCell,
              let patientData = selectedPatient?.data else {
            return UITableViewCell()
        }
        
        var entries: [BarChartDataEntry] = []
        let itemKey = Array(patientData.keys).sorted()[indexPath.row-1]
        if let dict = patientData[itemKey] as? [String: Double] {
            for (i, k) in Array(dict.keys).sorted(by: {$0.toDate()! < $1.toDate()!}).enumerated() {
                let x = Double(i)
                let y = Double(dict[k]!)
                entries.append(
                    BarChartDataEntry(x: x,
                                      y: y)
                )
            }
        }
        
        let set = BarChartDataSet(entries: entries, label: itemKey.capitalized)
        set.colors = ChartColorTemplates.vordiplom()
        let data = BarChartData(dataSet: set)
        
        let addAction: () -> Void = {
            let alert = UIAlertController(title: "Add new value", message: nil, preferredStyle: .alert)

            alert.addTextField { (titleTextField) in
                titleTextField.placeholder = "Value"
            }

            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
                guard let value = alert?.textFields?[0].text,
                      let doubleValue = Double(value),
                      let uid = UserData.shared.userUid,
                      let patientId = self.selectedPatient?.id else { return }
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.string(from: date)
                
                self.ref.child("users/\(uid)/patients/\(patientId)/data/\(itemKey)/")
                    .child("\(dateFormatter.string(from: date))").setValue(doubleValue)
            }))

            self.present(alert, animated: true, completion: nil)
        }
        
        cell.configure(with: data, addAction: addAction)
        
        return cell
    }
}
