//
//  AppDelegate.swift
//  LetsChat
//
//  Created by Tanvi Khot on 2/6/21.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

//@main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        //Google Config
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        print("Signed in with Google: \(user)")
        
        //logic to check if the email user used to sign in with does not already exist (either with FB or with our own app sign-in functionality
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
            return
        }
        DatabaseManager.shared.userExists(with: email,
                        completion: { exists in
                            if (!exists) {
                                // insert into database
                                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                                    lastName: lastName,
                                                                                    emailAddress: email))
                            }
                        })
        
        // if user email exists, skip inserting but don't go to registration again, still trade it for a credential and continue with Google
        guard let authentication = user.authentication else {
            print("Missing auth object off of Google user")
            return
        }
        
        //trade access token fro mGoogle for a Firebase credential
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        // ... Use Firebase auth to actually sign the user in
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                print("Failed to log in with Google credentials")
                return
            }
            print("Successfully signed in with Google credentials")
            //User has signed in and go ahead and post the notification to dismiss the View Controller
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //other delegate function for the GoogleSignInDelegate, gets called when the user logs out
        print("Google user was disconnected")
    }
    
}
    
