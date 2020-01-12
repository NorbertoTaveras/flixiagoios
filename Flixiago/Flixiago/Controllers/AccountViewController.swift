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
    
    override func viewWillAppear(_ animated: Bool) {
        let views = formViews()
        
        // Should not be able to get here without a user,
        // but just in case
        guard let user = Auth.auth().currentUser else {
            dismiss(animated: true, completion: nil)
            return
        }

        downloadProfilePhoto(userId: user.uid) { (img, error) in
            self.photoView.image = img
        }
        
        views.emailView.text = user.email
        views.displayNameView?.text = user.displayName
        
        initForm(views: views)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        emailView.resignFirstResponder()
        displayNameView.resignFirstResponder()
        passwordView.resignFirstResponder()
        confirmPasswordView.resignFirstResponder()
    }

    @IBAction func saveAccountChanges(_ sender: Any) {
        updateAccount { (errors) in
            if errors == nil {
                UIUtils.modalDialog(
                    parent: self,
                    title: "Success",
                    message: "Account updated successfully")
            } else {
                var message = "";
                
                for error in errors ?? [] {
                    if let error = error
                        as? AuthUtils.UpdateAccountError {
                        if error.self == .ValidationFailed {
                            // Avoid dialog for validation error
                            return
                        }
                    }
                    
                    if message.count > 0 {
                        message += ", "
                    }
                    
                    message += error.localizedDescription
                }
                
                UIUtils.modalDialog(
                    parent: self,
                    title: "Error updating account",
                    message: "Error updating account: (\(message))")
            }
        }
    }

}
