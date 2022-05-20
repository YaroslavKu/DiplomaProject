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
    
    var patientsList: UICollectionView?
    var tableView: UITableView?
    
    let ref = Database.database().reference()
    let model = HomeModel()
    
    var tableViewLastContentOffset: CGFloat = 0
    var selectedPatient: Patient? {
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
        tableView?.tableFooterView = setupFooterView()
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
    
    func setupFooterView() -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView!.frame.width, height: 50))
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Add custom data"
        
        let addCustomDataButton = UIButton(configuration: configuration)
        addCustomDataButton.isSelected = true
        addCustomDataButton.addTarget(self, action: #selector(handleFooterTap(_:)), for: .touchUpInside)
        addCustomDataButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(addCustomDataButton)
        
        NSLayoutConstraint.activate([
            addCustomDataButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            addCustomDataButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        return containerView
    }
    
    @objc func handleFooterTap(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add new data", message: nil, preferredStyle: .alert)

        alert.addTextField { (titleTextField) in
            titleTextField.placeholder = "Value name"
        }
        alert.addTextField { (initialValuetextField) in
            initialValuetextField.placeholder = "Initial Value"
        }

        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            guard let valueKey = alert?.textFields?[0].text,
                  let initialValue = alert?.textFields?[1].text,
                  let uid = UserData.shared.userUid,
                  let patientId = self.selectedPatient?.id else { return }
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.string(from: date)
            
            self.ref.child("users/\(uid)/patients/\(patientId)/data/\(valueKey)").setValue([
                dateFormatter.string(from: date): Double(initialValue)
            ])
        }))

        self.present(alert, animated: true, completion: nil)
    }
}

