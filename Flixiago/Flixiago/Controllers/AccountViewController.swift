//
//  AccountViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit
import MaterialComponents
import FirebaseAuth

class AccountViewController: AuthUtils {

    @IBOutlet weak var emailView: MDCTextField!
    @IBOutlet weak var displayNameView: MDCTextField!
    @IBOutlet weak var passwordView: MDCTextField!
    @IBOutlet weak var confirmPasswordView: MDCTextField!
    @IBOutlet weak var photoView: UIImageView!
    
    func formViews() -> FormViews {
        return (
            emailView,
            displayNameView,
            passwordView,
            confirmPasswordView,
            photoView
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let views = formViews()
        
        // Should not be able to get here without a user,
        // but just in case
        guard let user = Auth.auth().currentUser else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        views.emailView.text = user.email
        views.displayNameView?.text = user.displayName
        
        initForm(views: views)
    }
    

    @IBAction func saveAccountChanges(_ sender: Any) {
        updateAccount { (errors) in
            print(errors ?? [])
        }
    }

}
