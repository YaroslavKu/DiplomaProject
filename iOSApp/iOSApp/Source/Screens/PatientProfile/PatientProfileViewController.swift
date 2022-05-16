//
//  PatientProfileViewController.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 16.05.2022.
//

import UIKit

class PatientProfileViewController: UIViewController {
    public var patient: Patient?
    
    private var profileImageView: UIImageView?
    private var containerView: UIView?
    private var infoStackView: UIStackView?
    private var nameLabel: UILabel?
    private var idLabel: UILabel?
    private var phoneLabel: UILabel?
    private var ageLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var deletePatentButton: UIButton?
    
    private let model = PatientProfileModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        guard let patient = self.patient else { return }
        
        if let nameFirstLetter = patient.name.first,
           let surnameFirstLetter = patient.surname.first {
            self.profileImageView?.image = UIImage.getInitialsImage(initials: "\(nameFirstLetter)\(surnameFirstLetter)")
        }
        
        nameLabel?.text = "\(patient.name) \(patient.surname)"
        phoneLabel?.text = "Phone: \(patient.phone ?? "None")"
        ageLabel?.text =  patient.age != nil ? "Age: \(patient.age!)" : "Age: None"
        idLabel?.text = "ID: \(patient.id)"
        descriptionLabel?.text = patient.description ?? "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries"
    }

}

private extension PatientProfileViewController {
    func setupViews() {
        view.backgroundColor = .clear
        
        setupContainerView()
        setupProfileImage()
        setupNameView()
        setupInfoViews()
        setupDescriptionView()
        setupDeletePatientButton()
    }
    
    func setupContainerView() {
        containerView = UIView()
        containerView?.clipsToBounds = true
        containerView?.backgroundColor = .white
        containerView?.layer.cornerRadius = 20
        containerView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView!)
        
        NSLayoutConstraint.activate([
            containerView!.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            containerView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView!.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    func setupProfileImage() {
        profileImageView = UIImageView()
        profileImageView?.clipsToBounds = true
        profileImageView?.layer.cornerRadius = 50
        profileImageView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView!)
        
        NSLayoutConstraint.activate([
            profileImageView!.centerXAnchor.constraint(equalTo: containerView!.centerXAnchor),
            profileImageView!.centerYAnchor.constraint(equalTo: containerView!.topAnchor),
            profileImageView!.heightAnchor.constraint(equalToConstant: 100),
            profileImageView!.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupNameView() {
        nameLabel = UILabel()
        nameLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel?.translatesAutoresizingMaskIntoConstraints = false
        containerView!.addSubview(nameLabel!)
        
        NSLayoutConstraint.activate([
            nameLabel!.topAnchor.constraint(equalTo: containerView!.topAnchor, constant: 60),
            nameLabel!.centerXAnchor.constraint(equalTo: containerView!.centerXAnchor)
        ])
    }
    
    func setupInfoViews() {
        infoStackView = UIStackView()
        infoStackView?.axis  = .vertical
        infoStackView?.distribution  = .equalSpacing
        infoStackView?.alignment = .leading
        infoStackView?.spacing   = 5
        infoStackView?.translatesAutoresizingMaskIntoConstraints = false
        containerView!.addSubview(infoStackView!)
        
        phoneLabel = UILabel()
        phoneLabel?.translatesAutoresizingMaskIntoConstraints = false
        infoStackView?.addArrangedSubview(phoneLabel!)
        
        ageLabel = UILabel()
        ageLabel?.translatesAutoresizingMaskIntoConstraints = false
        infoStackView?.addArrangedSubview(ageLabel!)
        
        idLabel = UILabel()
        idLabel?.translatesAutoresizingMaskIntoConstraints = false
        infoStackView?.addArrangedSubview(idLabel!)
        
        NSLayoutConstraint.activate([
            infoStackView!.topAnchor.constraint(equalTo: nameLabel!.bottomAnchor, constant: 10),
            infoStackView!.leadingAnchor.constraint(equalTo: containerView!.leadingAnchor, constant: 10),
            infoStackView!.trailingAnchor.constraint(equalTo: containerView!.trailingAnchor, constant: -10)
        ])
    }
    
    func setupDescriptionView() {
        let notesLabel = UILabel()
        notesLabel.font = UIFont.boldSystemFont(ofSize: 18)
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.text = "Notes:"
        containerView!.addSubview(notesLabel)
        
        descriptionLabel = UILabel()
        descriptionLabel?.numberOfLines = 0
        descriptionLabel?.translatesAutoresizingMaskIntoConstraints = false
        containerView!.addSubview(descriptionLabel!)
        
        NSLayoutConstraint.activate([
            notesLabel.topAnchor.constraint(equalTo: infoStackView!.bottomAnchor, constant: 10),
            notesLabel.centerXAnchor.constraint(equalTo: containerView!.centerXAnchor),
            
            descriptionLabel!.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 5),
            descriptionLabel!.leadingAnchor.constraint(equalTo: infoStackView!.leadingAnchor),
            descriptionLabel!.trailingAnchor.constraint(equalTo: infoStackView!.trailingAnchor)
        ])
    }
    
    func setupDeletePatientButton() {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Delete"
        deletePatentButton = UIButton(configuration: configuration)
        deletePatentButton?.isSelected = true
        deletePatentButton?.addTarget(self, action: #selector(deletePatientAction), for: .touchUpInside)
        deletePatentButton?.translatesAutoresizingMaskIntoConstraints = false
        containerView!.addSubview(deletePatentButton!)
        
        NSLayoutConstraint.activate([
            deletePatentButton!.topAnchor.constraint(equalTo: descriptionLabel!.bottomAnchor, constant: 20),
            deletePatentButton!.centerXAnchor.constraint(equalTo: containerView!.centerXAnchor)
        ])
    }
    
    @objc func deletePatientAction() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete the patient?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            UserData.shared.deletePatient(with: self.patient!.id)
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        present(alert, animated: true)
    }
}
