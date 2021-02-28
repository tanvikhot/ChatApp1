//
//  ProfileViewController.swift
//  LetsChat
//
//  Created by Tanvi Khot on 2/6/21.
//

import UIKit
import FirebaseAuth     //to log out the user
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //number of rows = return the number of elements in data
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //for Cell of the row: De Queue the cell off of the
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //To use the "cell" ID above, you also have to register it with tableView in viewDidLoad
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    //we want something to occur when we tap the cell, in this case logging out
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //unhighlight the cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        //alert the user if they unintentionally tapped the Log Out button
        
        //<<TODO>> action sheet a special handling for iPad as it may crash, so let's come back to it as we build more
        let actionSheet = UIAlertController(title: "",
                                            message: "",
                                            preferredStyle: .actionSheet)
        //weak_self in the closure to ensure that we don't get stuck in a retention cycle
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                        style: .destructive,
                        handler: { [weak self] _ in
                                                
                        guard let strongSelf = self else {
                            return
                        }
                            
                        // Log out of Facebook so next time the user sees 'Continue to Facebook' as it logs out of FB session completely
                        FBSDKLoginKit.LoginManager().logOut()
                            
                        // Google Log out
                        GIDSignIn.sharedInstance()?.signOut()
                            
                        do {
                            try FirebaseAuth.Auth.auth().signOut()
                                //user has successfully logged out so show the login screen (code from ConversationVC validateAuth() for more info
                                
                                let vc = LoginViewController()
                                //create a navigation controller that this vc gets plugged into
                                let nav = UINavigationController(rootViewController: vc)
                                nav.modalPresentationStyle = .fullScreen
                                strongSelf.present (nav, animated: true)
                            }
                            catch {
                                print("Failed to log out")
                            }
                        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true)
        
       
    }
}
