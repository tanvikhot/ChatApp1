//
//  LoginViewController.swift
//  LetsChat
//
//  Created by Tanvi Khot on 2/6/21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {

    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue //default is the return key for the password field
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done //auto login for the password field
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true

        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    //set up some scopes on FB Login Button
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        //public_profile will include the first name and last name we want and email from email is self-explanatory
        print("In FBLogin Button scope creation")
        button.permissions = ["email", "public_profile"]
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self,
                              action: #selector(logginButtonTapped),
                              for: .touchUpInside)
        
        /*
         Additinally, to make our login form experience nicer, leverage the text
         field "delegate" so when the user hits the return key on email, it can focus the password field and when the user hits the return key on the password field, it automatically calls the logginButtonTapped()
         */
        emailField.delegate = self
        passwordField.delegate = self
        /*
         When we first set up the email pass log in, we are creating users in firebase when a
         user signs in with Facebook rather continues with Facebook we still need to make sure that the email that is associated with that Facebook user doesn't already exist. If that email exists in our database before, we want to sign the user in with a firebase credential. If they don't exist, we want to sign them up with a firebase credential and there is a bit of handling we need to do around that. So the first thing we want to do is essentially get if the login was successful as well as set up the Scopes to request from Facebook so we're gonna set up a delegate for this FBbutton and to self and add an extension to the login view controller for a login button delegate

         */
        facebookLoginButton.delegate = self
        
        //We want the controller to conform to this delegate, so create an extention on this controller
        //Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)

        //FB SDK
        scrollView.addSubview(facebookLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width - 60,
                                   height: 52)
        
        facebookLoginButton.frame = CGRect(x: 30,
                                   y: loginButton.bottom+10,
                                   width: scrollView.width - 60,
                                   height: 52)
        
        facebookLoginButton.center = scrollView.center
        facebookLoginButton.frame.origin.y = loginButton.bottom+20
    }

    //user-login credentials check
    @objc private func logginButtonTapped() {
        
        //Get rid of the keyboard as soon as the user taps enter on either email or the password field
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        //Firebase Log In
        //Dismiss LoginViewController once the user authentication done and the user logs in
        //So use [weak self] authResult, so we don't cauze a retention cycle, and unwrap that weak self to a strong self using guard let
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            let user = result.user
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops!",
                                      message: "Please enter all information to login.",
                                      preferredStyle: .alert)
    
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        //once the user taps the Register button, push the RegisterViewController onto the screen
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}

//Create an extenstion on LoginViewController and conform to the UITextFieldDelegate
//Extensions are great ways to separate out code instead of putting the code of conforming to the delegate at the very top but that makes the code heavy and messy as you have to put out the code in the same block

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if user taps return key while focus was on emailField, pass on the focus to the passwordField
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            //just call loginButtonPresses action so user doesn't have to hit the LoginButton explicitely
            logginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //no op
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
       
        //Unwrap the token from Facebook
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with Facebook")
            return
        }
        
        //Before we actaully trade this token for a credential in Firebase, we should call a FB Graph request and get the name and email out of the current FB logged user
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"], tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        //execute the FB get request with name and email
        facebookRequest.start(completionHandler: {_, result, error in
            //unwrap the name and email
            guard let result = result as? [String: Any],
                  error == nil else {
                print("Failed to make Facebook graph request")
                return
            }
            
            //print("\(result)")
        
            //Once we have a token, we can create a credential and pass that on to Firebase
            //we need to trade this access token to Firebase to get a credential
            //Once we have the email out, we'll use our DatabaseManager to ensure the email is not already in the database. If it is, we don't have to do the insertion, we just have to log the user in. 'Continue' is not same as a registration for FB
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("Failed to get name and email from FB result")
                return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName, emailAddress: email))
                }
                //we don't need an else here because that means the user email already exists so go ahead and log him in ..
            })
            
            //Trade this access token from FB (withAccessToken: token) to Firebase credential..
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            //Now use this AuthCredential to sign the user in because we traded this credential for Firebase cedential
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    return
                }
                //Additional handling for multi-factor authentication. Facebook has MFA (text in the code that we sent to your phone, call / email etc. otherwise
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential login failed. MFA may be needed - \(error)")
                    }
                    return
                }
                print("Successfully logged in using Facebook credentials")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
        })
        
        
        
    }
    
    
}


