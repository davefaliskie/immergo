//
//  AuthenticationViewController.swift
//  immergo
//
//  Created by David Faliskie on 11/22/16.
//  Copyright © 2016 David Faliskie. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class AuthenticationViewController: UIViewController {

    
    // vars for Sign IN
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signInAleartTF: UILabel!
    @IBOutlet weak var currentUserLbl: UILabel!
    
    
    // vars for Sign UP
    @IBOutlet weak var newEmailTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var repeatPasswordTF: UITextField!
    @IBOutlet weak var signUpAleartTF: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the state of the current user
        getCurrentUser()
        
        
    }

    // buttons
    @IBOutlet weak var signOut: UIButton!
    @IBAction func signInPressed(_ sender: Any) {
        loginUser()
    }
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        createUser()
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        resetPassword()
    }
   
    
    
    // function to get the current user
    func getCurrentUser(){
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                self.currentUserLbl.text! = "Hello, \(user.email)"
                
                
            } else {
                // No user is signed in.
                self.currentUserLbl.text! = "No current user!"
                
            }
        }
    }
    
    
    // function for user to sign up. 
    func createUser(){
        // set variables from user inputed text
        let email = self.newEmailTF.text!
        let password = self.newPasswordTF.text!
        let repeatPassword = self.repeatPasswordTF.text!
        let name = self.nameTF.text!
        
        
        // check that password and repeate are the same...
        if(password == repeatPassword){
            
            // make sure the user entered a name...
            if (name.characters.count <= 2){
                self.signUpAleartTF.text! = "You must enter a full name"
            }else{
    
                // create the user
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {
                    user, error in
                    
                    if (error?._code == FIRAuthErrorCode.errorCodeInvalidEmail.rawValue){
                        self.signUpAleartTF.text! = "Invalid email address."
                        
                    }else if (error?._code == FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue){
                        self.signUpAleartTF.text! = "Account created, use forgot password"
                    
                    }else if (error != nil){
                        self.signUpAleartTF.text! = "Could not create new user!"
                        
                    }else{
                        self.signUpAleartTF.text! = "User Successfully Created!"
                        
                        // successuflly authenticated user, update the user database.
                        
                        // get users uid
                        guard let uid = user?.uid else {
                            return
                        }
                        
                        // connect to storage for pic storage
                        let imageName = NSUUID().uuidString
                        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName)")
                        
                        if let uploadData = UIImagePNGRepresentation(self.profilePicture.image!){
                            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                                
                                if error != nil {
                                    print (error!)
                                    return
                                }
                                
                                if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                                    let values = ["name": name, "email": email, "profileImageUrl": profileImageURL]
                                    
                                    self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                                        
                                    
                                }
                                
                                
                    
                            })
                        }
                        
                        
                        
                        
    
                        
                        
                        // now Login!
                        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
                            user, error in
                            
                            if (error != nil){
                                self.signUpAleartTF.text! = "Error"
                            }else{
                                self.signUpAleartTF.text! = "Success"
                                
                                // Transition to other Scene
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "welcomeVC") as UIViewController
                                self.present(vc, animated: true, completion: nil)
                            }
                            
                        })
                    }
                })
            }
        }else{
            // passwords were different...
            self.signUpAleartTF.text! = "Passwords do not match."
        }

    }
    
    // connect to the database
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]){
        // set database reference
        let ref = FIRDatabase.database().reference(fromURL: "https://immergo-90a8b.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
//        let values = ["name": name, "email": email, "profileImageUrl": metadata.downloadUrl()]
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if (err != nil){
                self.signUpAleartTF.text! = "Make sure all fields are filled out!"
            }else{
                print ("User successuflly created in DB")
            }
            
        })

    }
    
    
    
    
    // function for the user Login
    func loginUser(){
        FIRAuth.auth()?.signIn(withEmail: emailTF.text!, password: passwordTF.text!, completion: {
            user, error in
            
            
            if (error?._code == FIRAuthErrorCode.errorCodeUserNotFound.rawValue){
                self.signInAleartTF.text = "Email not on file, create a new account."
                
            }else if (error?._code == FIRAuthErrorCode.errorCodeInvalidEmail.rawValue){
                self.signInAleartTF.text = "Invalid email address."
                
            }else if (error?._code == FIRAuthErrorCode.errorCodeWrongPassword.rawValue){
                self.signInAleartTF.text = "Password not entered correctly."
                
            }else if (error != nil){
                self.signInAleartTF.text = "Check your email and password."
                
            }else {
                self.signInAleartTF.text = "Success, Logged in as \(user?.email)"
                
                // Transition to other Scene
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "welcomeVC") as UIViewController
                self.present(vc, animated: true, completion: nil)
                
            }
        })
    }
    
    func resetPassword() {
        FIRAuth.auth()?.sendPasswordReset(withEmail: emailTF.text!) { error in
            if let error = error {
                // An error happened.
                if (error._code == FIRAuthErrorCode.errorCodeUserNotFound.rawValue){
                    self.signInAleartTF.text = "Email not on file, create a new account."
                }else{
                    self.signInAleartTF.text = "Invalid email address."
                }
            } else {
                // Password reset email sent.
                self.signInAleartTF.text = "Password reset sent to your email!"
            }
        }
        
    }
    
    
    //setting the profile picture
    
    @IBAction func changePressed(_ sender: Any) {
        changeProfilePicture()
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    

    
    
    
    
    
}











