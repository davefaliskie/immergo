//
//  ViewController.swift
//  immergo
//
//  Created by David Faliskie on 11/22/16.
//  Copyright © 2016 David Faliskie. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController {

    @IBOutlet weak var userEmailLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUserEmail = FIRAuth.auth()?.currentUser?.email
        
        userEmailLbl.text = currentUserEmail
    }

    @IBAction func signOut(_ sender: Any) {
        
        try! FIRAuth.auth()!.signOut()
        
        // Transition to other Scene
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AuthVC") as UIViewController
        self.present(vc, animated: true, completion: nil)
        
    }
    
    

}

