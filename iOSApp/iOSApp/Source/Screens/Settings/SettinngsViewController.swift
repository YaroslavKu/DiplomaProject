//
//  SettinngsViewController.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 12.05.2022.
//

import UIKit
import Firebase

class SettinngsViewController: UIViewController {
    @IBOutlet weak var settingsStackView: UIStackView!
    
    private var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserData.shared.getUserName() { name in
            self.userName.text = name
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            // TODO: Add error processing
            print("Error on sigtout action")
        }
    }
}

private extension SettinngsViewController {
    func setupViews() {
        title = "Settings"
        setupProfileCard()
    }
    
    func setupProfileCard() {
        let card = UIStackView()
        card.axis = .horizontal
        card.alignment = .leading
        card.spacing = 15
        card.layer.cornerRadius = 10
        
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = true
        iconContainer.layer.cornerRadius = 20
        iconContainer.backgroundColor = .ocean
        card.addArrangedSubview(iconContainer)
        
        let image = UIImage(systemName: "person")
        let icon = UIImageView(image: image)
        icon.tintColor = .white
        icon.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        icon.translatesAutoresizingMaskIntoConstraints = true
        iconContainer.addSubview(icon)
        
        userName = UILabel()
        userName.font = userName.font.withSize(24)
        UserData.shared.getUserName() { name in
            self.userName.text = name
        }
        card.addArrangedSubview(userName)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 70),
            
            iconContainer.widthAnchor.constraint(equalToConstant: 70),
            iconContainer.heightAnchor.constraint(equalToConstant: 70),
            
            userName.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        self.settingsStackView.addArrangedSubview(card)
    }
}
