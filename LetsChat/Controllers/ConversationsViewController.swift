//
//  TestViewController.swift
//  LetsChat
//
//  Created by Tanvi Khot on 2/6/21.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        //use DatabaseManager shared instance to write a sample data to the Firebase DB
        //DatabaseManager.shared.test()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       /*
        //Get value of some user defaults - can be used to save some data to disk
        let isLoggedIn = UserDefaults.standard.bool(forKey: "Logged_in")
        
        if !isLoggedIn {
         let vc  = LoginViewController()
            //create a navigation controller that this vc gets plugged into
            let nav = UINavigationController(rootViewController: vc)
            //In iOS 13, if you don't specify modalpresentarionstule as this way.. i.e.e fullscreen,
            //the conroller by default pops up as card and the user can dismiss it by swiping down and we don't want user to dismiss the login page unless they
            //are actaully truly logged in
            nav.modalPresentationStyle = .fullScreen
            present (nav, animated: false)
        }
      */
    
        validateAuth()
    }
    
    private func validateAuth() {
        let isLoggedIn = FirebaseAuth.Auth.auth().currentUser
        if isLoggedIn == nil {
         let vc  = LoginViewController()
            //create a navigation controller that this vc gets plugged into
            let nav = UINavigationController(rootViewController: vc)
            //In iOS 13, if you don't specify modalpresentarionstule as this way.. i.e.e fullscreen,
            //the conroller by default pops up as card and the user can dismiss it by swiping down and we don't want user to dismiss the login page unless they
            //are actaully truly logged in
            nav.modalPresentationStyle = .fullScreen
            present (nav, animated: false)
        }
    }

}
