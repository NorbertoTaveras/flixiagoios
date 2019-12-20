//
//  SignInViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit

import UIKit
import MaterialComponents
import MaterialComponents.MaterialTextFields_ColorThemer

class SignInViewController: AuthUtils {
    
    @IBOutlet weak var emailView: MDCTextField!
    @IBOutlet weak var passwordView: MDCTextField!
    
    func formViews() -> FormViews {
        return (
            emailView,
            nil,
            passwordView,
            nil,
            nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let views = formViews()
        initForm(views: views)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailView.resignFirstResponder()
        passwordView.resignFirstResponder()
    }
    
    @IBAction func signIn(_ sender: Any) {
        signInWith()
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        guard let email = emailView.text else {return}
        
        if email.isEmpty || !AuthUtils.isValid(email: email) {
            UIUtils.modalDialog(
                parent: self,
                title: "Invalid email",
                message: "Enter an email account to" +
                "recover in the email field")
            return
        }
        
        UIUtils.modalConfirm(
            parent: self,
            title: "Password Recovery",
            message: "Send password recovery email to \(email)?",
            completionHandler: { (yes) in
                if !yes {return}
                self.resetPassword(withEmail: email) { success in
                    let message = success ?
                        "Password recovery mail was sent. Check your" +
                            " email and follow the instructions there" +
                        " to recover your password" :
                        "There was a problem sending the password" +
                        " recovery email. Check the email address" +
                    " and try again"
                    
                    UIUtils.modalDialog(
                        parent: self,
                        title: "Password Recovery",
                        message: message)
                }
        })
    }
}
