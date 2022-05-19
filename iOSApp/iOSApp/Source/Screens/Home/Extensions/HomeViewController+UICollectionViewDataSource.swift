//
//  HomeViewController+UICollectionViewDataSource.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 19.05.2022.
//

import Foundation
import UIKit

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
