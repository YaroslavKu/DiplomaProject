//
//  HomeViewController.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 15.05.2022.
//

import UIKit
import Firebase
import Charts

class HomeViewController: UIViewController {
    
    private var patientsList: UICollectionView?
    private var tableView: UITableView?
    
    private let ref = Database.database().reference()
    private let model = HomeModel()
    
    private var tableViewLastContentOffset: CGFloat = 0
    private var selectedPatient: Patient? {
        didSet {
            oldValue?.removeAllObservers()
            selectedPatient?.onHeartRateDidChange {
                self.tableView?.reloadData()
            }
            tableView?.reloadData()
            tableView?.isHidden = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.authStateDidChange(notification:)),
                                               name: .userAuthDidChenge,
                                               object: nil)
        tableView?.isHidden = true
    }
    
    @objc func authStateDidChange(notification: Notification) {
        guard let uid = UserData.shared.userUid else {
            ref.removeAllObservers()
            return
        }
        
        ref.child("users/\(uid)/patients").observe(.value, with: { _ in
            self.model.load() {
                self.patientsList?.reloadData()
            }
        })
    }
    
    deinit {
        ref.removeAllObservers()
        NotificationCenter.default.removeObserver(self, name: .userAuthDidChenge, object: nil)
    }
}

private extension HomeViewController {
    func setupViews() {
        setupPatientListView()
        setupTableView()
    }
    
    func setupPatientListView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        patientsList = UICollectionView(frame: .zero, collectionViewLayout: layout)
        patientsList?.register(CircleCollectionViewCell.self, forCellWithReuseIdentifier: CircleCollectionViewCell.identifier)
        patientsList?.showsHorizontalScrollIndicator = false
        patientsList?.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        patientsList?.delegate = self
        patientsList?.dataSource = self
        patientsList?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(patientsList!)
        
        NSLayoutConstraint.activate([
            patientsList!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            patientsList!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            patientsList!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            patientsList!.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView?.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.identifier)
        tableView?.register(WatchOSDataTableViewCell.self, forCellReuseIdentifier: WatchOSDataTableViewCell.identifier)
        tableView?.register(BarChartTableViewCell.self, forCellReuseIdentifier: BarChartTableViewCell.identifier)
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.sectionHeaderHeight = 50
        tableView?.separatorColor = .clear
        view.addSubview(tableView!)
        
        NSLayoutConstraint.activate([
            tableView!.topAnchor.constraint(equalTo: patientsList!.bottomAnchor),
            tableView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        let lowPriorityTopConstraint = tableView!.topAnchor.constraint(equalTo: view.topAnchor)
        lowPriorityTopConstraint.priority = .defaultLow
        lowPriorityTopConstraint.isActive = true
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.patientsList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircleCollectionViewCell.identifier,
                                                            for: indexPath) as? CircleCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.row == model.patientsList.count {
            //TODO: Fix bug on deleteng user when model.patientsList.count == 1
            cell.configure(initials: "+", label: "Add new patient")
            
        } else {
            cell.configure(with: model.patientsList[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = patientsList?.cellForItem(at: indexPath) as! CircleCollectionViewCell
        cell.setSelected(false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = patientsList?.cellForItem(at: indexPath) as! CircleCollectionViewCell
        
        if indexPath.row != model.patientsList.count {
            cell.setSelected(true)
            selectedPatient = model.patientsList[indexPath.row]
        } else {
            let storyboard = UIStoryboard(name: "AddPatient", bundle: nil)
            let addPatientVC = storyboard.instantiateViewController(withIdentifier: "AddPatientViewController") as! AddPatientViewController
            present(addPatientVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
            case 0:
                return 70
            case 1:
                return 200
            default:
                return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                return configureWatchDateCell(for: indexPath)
            case 1:
                return configureBarChartCell(for: indexPath)
            default:
                return UITableViewCell()
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
            guard let saturationDict = selectedPatient?.saturation else { return "nil" }
            
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
              let patient = selectedPatient else {
            return UITableViewCell()
        }
        
        var entries: [BarChartDataEntry] = []
        
        if let saturationDict = patient.saturation {
            for (i, k) in Array(saturationDict.keys).sorted(by: {$0.toDate()! < $1.toDate()!}).enumerated() {
                let x = Double(i)
                let y = Double(patient.saturation![k]!)
                entries.append(
                    BarChartDataEntry(x: x,
                                      y: y)
                )
            }
        }
        
        let set = BarChartDataSet(entries: entries, label: "Saturation")
        set.colors = ChartColorTemplates.vordiplom()
        let data = BarChartData(dataSet: set)
        
        cell.configure(with: data)
        
        return cell
    }
}

