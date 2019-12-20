//
//  SignUpViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit
import MaterialComponents

class SignUpViewController: AuthUtils {

    @IBOutlet weak var emailView: MDCTextField!
    @IBOutlet weak var displayNameView: MDCTextField!
    @IBOutlet weak var passwordView: MDCTextField!
    @IBOutlet weak var confirmPasswordView: MDCTextField!
    @IBOutlet weak var photoView: UIImageView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        emailView.resignFirstResponder()
        displayNameView.resignFirstResponder()
        passwordView.resignFirstResponder()
        confirmPasswordView.resignFirstResponder()
    }
    
    private func formViews() -> FormViews {
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
        
        initForm(views: views)
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }

    @IBAction func signUp(_ sender: Any) {
        if let _ = validate(type: ValidationType.signUp) {
            signUpWith(fields: fields)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func skip(_ sender: Any) {
        continueToMainUI()
    }
}
