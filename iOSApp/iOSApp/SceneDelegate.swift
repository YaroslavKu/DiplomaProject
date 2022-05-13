//
//  SceneDelegate.swift
//  iOSApp
//
//  Created by Yaroslav Kukhar on 08.01.2022.
//

import UIKit
import Firebase
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        FirebaseApp.configure()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.showModalAuth()
            } else {
                print("\(String(describing: UserData.shared.userUid))")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }


    // MARK: Navigation
    func showModalAuth() {
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        authVC.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(authVC, animated: true, completion: nil)
    }
}

