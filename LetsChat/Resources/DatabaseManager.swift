//
//  DatabaseManager.swift
//  LetsChat
//
//  Created by Tanvi Khot on 2/18/21.
//

/*
Design a public API or public functions to allow us to seamlessly perform operations on the database regardless of which viewcontroller we're in. For ex.  all the conversations from Chat View Control, user account verification, creation etc.
 */

import Foundation
import FirebaseDatabase

//create a simple final class (can't be subclassed)

final class DatabaseManager {
    //Make this class a singleton one for for easy R and W access, so the contant property shared returns an instance of DatabaseManager
    static let shared = DatabaseManager()
    
    //private reference to the class
    private let database = Database.database().reference()
    
    //A very simple test write function to write to our database
    public func test() {
        //We're using a non-sql db in JSON format which stores data in plain key-value pairs
        database.child("foo").setValue(["something": true])
        //Go to ConversationVC to test it out
    }
    
}

// MARK: - Account Management
extension DatabaseManager {
    
    /*
     userExists is a function that validates the current email that you are trying to use and makes sure that the new user does not exist already.
        We will have a completion Handler instead of returning a Bool because the function to actually get data out of the database is a synchronous so we need a completion block and this will be an escaping completion block and it's going to return to us a boolean based on if that if the validation passed or not. So this will return true if the user email does not exist and false if it does exist
     */
    public func userExists(with email: String,
                           completion: @escaping((Bool) -> Void)) {
        /*
         firebase database allows you to observe value changes on any entry in your no-sql database by specifying the child that you want to observe for and specifying what type of observation you want. So we only want to observe a single event which in other words is basically 'query the database' once, with child as email and we're gonna say single observe single event. Its going to return a snapshot which has a value property off of it.
         
         */
        
        //To handle : '(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                //email does not exist
                completion(false)
                return
            }
            //email is found, so call in completion handler to return true
            completion(true)
        })
        
    }
    ///Insert new user to database
    public func insertUser(with user: ChatAppUser) {
        //use safeEmail from the ChatAppUser
        database.child(user.safeEmail).setValue([
                                                    "first_name": user.firstName,
                                                    "last_name": user.lastName])
    }

}

//struct that wraps our key / value info and other imp data
struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    //let ProfilePictureUrl: String
    
    //create a computer property for safe email here
    //To handle : '(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
