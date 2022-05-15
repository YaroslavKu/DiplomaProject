//
//  HomeViewController.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 15.05.2022.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    private var patientsList: UICollectionView?
    private var tableView: UITableView?
    
    private let ref = Database.database().reference()
    private let model = HomeModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        
        guard let uid = UserData.shared.userUid else { return }
        ref.child("users/\(uid)/patients").observe(.value, with: { _ in
            self.model.load() {
                self.patientsList?.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeAllObservers()
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
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.delegate = self
        tableView?.delegate = self
        tableView?.backgroundColor = .red
        view.addSubview(tableView!)
        
        NSLayoutConstraint.activate([
            tableView!.topAnchor.constraint(equalTo: patientsList!.bottomAnchor),
            tableView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Test"
        return cell
    }
    
    
}

