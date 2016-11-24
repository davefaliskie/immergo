//
//  ProfileViewController.swift
//  immergo
//
//  Created by David Faliskie on 11/23/16.
//  Copyright © 2016 David Faliskie. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var aleartLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserData()
    }

    func getUserData(){
        if FIRAuth.auth()?.currentUser?.uid == nil {
            self.aleartLbl.text = "There is no user logged in"
        }else{
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let user = snapshot.value as? [String: Any]{
                    self.nameLbl.text = "Welcome, \(user["name"] as! String)"
                    self.emailLbl.text = "Email: \(user["email"] as! String)"
                    // show default image while loading.
                    self.profilePicture.image = UIImage(named: "apple")
                    self.profilePicture.contentMode = .scaleAspectFill
       
                    
                    if let profileImageUrl = user["profileImageUrl"] as? String{
                        let url = NSURL(string: profileImageUrl)
                        URLSession.shared.dataTask(with: url! as URL, completionHandler: {
                            (data, response, error) in
                            
                            // download hit an error, return out.
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            DispatchQueue.main.async{
                                self.profilePicture.image = UIImage(data: data!)
                            }
                        
                        }).resume()
                    }
                }
                
            }, withCancel: nil)
        }

    }

}
