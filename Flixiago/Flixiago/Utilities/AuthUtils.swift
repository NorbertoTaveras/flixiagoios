//
//  AuthUtils.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import MaterialComponents
import MaterialComponents.MaterialTextFields_ColorThemer

class AuthUtils:
    UIViewController,
    UITextFieldDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    let purple = UIColor(
        red: CGFloat(0x4e) / 255.0,
        green: CGFloat(0x32) / 255.0,
        blue: CGFloat(0x8e) / 255.0,
        alpha: CGFloat(1.0))
    
    public enum ValidationType {
        case signIn
        case signUp
        case updateAccount
    }
    
    public typealias FormViews = (
        emailView: MDCTextField,
        displayNameView: MDCTextField?,
        passwordView: MDCTextField,
        confirmPasswordView: MDCTextField?,
        photoView: UIImageView?
    )
    
    public typealias FormFields = (
        emailView: MDCTextInputControllerOutlined,
        displayNameView: MDCTextInputControllerOutlined?,
        passwordView: MDCTextInputControllerOutlined,
        confirmPasswordView: MDCTextInputControllerOutlined?,
        photoView: UIImageView?
    )
    
    public typealias FormValues = (
        email: String,
        displayName: String?,
        password: String,
        confirmPassword: String?,
        photo: UIImage?
    )
    
    var fields: FormFields!
    
    func valuesFromFields() -> FormValues {
        return (
            fields.emailView.textInput?.text ?? "",
            fields.displayNameView?.textInput?.text,
            fields.passwordView.textInput?.text ?? "",
            fields.confirmPasswordView?.textInput?.text,
            fields.photoView?.image
        )
    }
    
    public func initForm(views: FormViews) {
        
        let colorScheme = MDCSemanticColorScheme()
        colorScheme.primaryColor = purple
        
        views.emailView.delegate = self
        views.displayNameView?.delegate = self
        views.passwordView.delegate = self
        views.confirmPasswordView?.delegate = self
        
        views.emailView.translatesAutoresizingMaskIntoConstraints = false
        views.displayNameView?.translatesAutoresizingMaskIntoConstraints = false
        views.passwordView.translatesAutoresizingMaskIntoConstraints = false
       
        views.confirmPasswordView?.translatesAutoresizingMaskIntoConstraints = false
        
        let emailOutlined = MDCTextInputControllerOutlined(
            textInput: views.emailView)
        
        views.emailView.textColor = purple
        emailOutlined.borderStrokeColor = purple
        
        MDCTextFieldColorThemer.applySemanticColorScheme(
            colorScheme, to: emailOutlined)
        
        let displayNameOutlined: MDCTextInputControllerOutlined?
        if views.displayNameView != nil {
            displayNameOutlined = MDCTextInputControllerOutlined(
                textInput: views.displayNameView)
            
            views.displayNameView?.textColor = purple
            displayNameOutlined?.borderStrokeColor = purple
            
            MDCTextFieldColorThemer.applySemanticColorScheme(
                    colorScheme,
                    to: displayNameOutlined ??
                        MDCTextInputControllerOutlined())
        } else {
            displayNameOutlined = nil
        }

        let passwordOutlined = MDCTextInputControllerOutlined(
            textInput: views.passwordView)
        
        views.passwordView.textColor = purple
        passwordOutlined.borderStrokeColor = purple
        
        MDCTextFieldColorThemer.applySemanticColorScheme(
            colorScheme, to: passwordOutlined)
        
        let confirmPasswordOutlined: MDCTextInputControllerOutlined?
        if views.confirmPasswordView != nil {
            
            confirmPasswordOutlined =   MDCTextInputControllerOutlined(
                textInput: views.confirmPasswordView)
            
            views.confirmPasswordView?.textColor = purple
            confirmPasswordOutlined?.borderStrokeColor = purple
            
            MDCTextFieldColorThemer.applySemanticColorScheme(
                    colorScheme,
                    to: confirmPasswordOutlined ??
                        MDCTextInputControllerOutlined())
        } else {
            confirmPasswordOutlined = nil
        }
        
        if let photoView = views.photoView {
            photoView.layer.masksToBounds = true
            photoView.layer.cornerRadius =  photoView.frame.size.width / 2
            //photoView.clipsToBounds = true;
            photoView.image = UIImage(
                systemName: "person.badge.plus.fill")
            
            // Setup tap handler on photo
            let photoTapRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(photoTapped))
            photoView.isUserInteractionEnabled = true
            photoView.addGestureRecognizer(photoTapRecognizer)
        }
        
        fields = (
            emailOutlined,
            displayNameOutlined,
            passwordOutlined,
            confirmPasswordOutlined,
            views.photoView
        )
    }
    
    @objc func photoTapped() {
        showPhotoActionSheet()
    }
    
    func showPhotoActionSheet() {
        let cameraAction = UIAlertAction(
            title: "Camera",
            style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.getPhotoFromCamera()
        })
        
        let galleryAction = UIAlertAction(
            title: "Gallery",
            style: .default,
            handler: { (alert:UIAlertAction!) -> Void in
            self.getPhotoFromGallery()
        })
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)

        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func getPhotoFrom(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = source
            present(pickerController, animated: true, completion: nil)
        }
    }
    
    func getPhotoFromCamera() {
        getPhotoFrom(source: .camera)
    }
    
    func getPhotoFromGallery() {
        getPhotoFrom(source: .photoLibrary)
    }
    
    func imagePicked(image: UIImage) {
        fields!.photoView?.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let key = UIImagePickerController.InfoKey.originalImage
        if let image = info[key] as? UIImage {
            self.imagePicked(image: image)
        } else {
            print("Unable to get picked image!")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
           nextField.becomeFirstResponder()
        } else {
           // Not found, so remove keyboard.
           textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }

    // returns the values if valid, nil if not valid
    public func validate(type: ValidationType) -> FormValues? {
        var isValid = true
        
        let values = valuesFromFields()
        
        if values.email.isEmpty {
            fields.emailView.setErrorText(
                "The email field cannot be blank",
                errorAccessibilityValue: nil)
            isValid = false
        } else if !AuthUtils.isValid(email: values.email) {
            fields.emailView.setErrorText(
                "The email address is not valid",
                errorAccessibilityValue: nil)
            isValid = false
        } else {
            fields.emailView.setErrorText(nil, errorAccessibilityValue: nil)
        }

        fields.confirmPasswordView?.setErrorText(nil, errorAccessibilityValue: nil)
        fields.passwordView.setErrorText(nil, errorAccessibilityValue: nil)
        
        if type != ValidationType.updateAccount ||
            !values.password.isEmpty ||
            !(values.confirmPassword?.isEmpty ?? false) {
            if values.password.isEmpty {
                fields.passwordView.setErrorText(
                    "The password field cannot be blank",
                    errorAccessibilityValue: nil)
                isValid = false
            } else if values.password.count < 8 {
                fields.passwordView.setErrorText(
                    "The password must be at least 8 characters",
                    errorAccessibilityValue: nil)
                isValid = false
            } else if type != ValidationType.signIn && values.password != values.confirmPassword {
                fields.confirmPasswordView?.setErrorText(
                    "The passwords do not match",
                    errorAccessibilityValue: nil)
                isValid = false
            }
        }
        
        if type != ValidationType.signIn &&
            (values.displayName == nil ||
                values.displayName!.isEmpty) {
            fields.displayNameView?.setErrorText(
                "The display name field cannot be blank",
                errorAccessibilityValue: nil)
            isValid = false
        } else {
            fields.displayNameView?.setErrorText(nil, errorAccessibilityValue: nil)
        }
        
        return isValid ? values : nil
    }
    
    func signInWith() {
        if let values = validate(type: ValidationType.signIn) {
            Auth.auth().signIn(
                withEmail: values.email,
                password: values.password) { (authResult, error) in
                    guard let user = authResult?.user, error == nil else {
                        UIUtils.modalDialog(
                            parent: self,
                            title: "Error",
                            message: error!.localizedDescription)
                        return
                    }
                    
                    if !user.isEmailVerified {
                        UIUtils.modalDialog(
                            parent: self,
                            title: "Email Not Verified",
                            message: "Email needs to be verified." +
                            " Please check your mail and click the" +
                            " account verification link")
                        return
                    }
                    
                    print("User signed in: " +
                        "\(Auth.auth().currentUser?.email ?? "<no email in current user>")" +
                        " (\(user.email ?? "<no email>")")
                    
                    // Success
                    self.continueToMainUI()
            }
            
        }
    }
    
    func signUpWith(fields: FormFields) {
        if let values = validate(type: ValidationType.signUp) {
            Auth.auth().createUser(
                withEmail: values.email,
                password: values.password) { (authResult, error) in
                    
                    guard let user = authResult?.user, error == nil else {
                        UIUtils.modalDialog(
                            parent: self,
                            title: "Error",
                            message: error!.localizedDescription)
                        return
                    }
                    
                    print("User signed up: " +
                        "\(user.displayName ?? "<no display name>")" +
                        " (\(user.email ?? "<no email>")")
                    
                    let photoUploadHandler: (URL?, Error?) -> Void = { (url, error) in
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = values.displayName
                        changeRequest.photoURL = url
                        changeRequest.commitChanges { (error) in
                            if let error = error {
                                UIUtils.modalDialog(
                                    parent: self,
                                    title: "Error",
                                    message: "Profile change request failed with" +
                                    " \(error.localizedDescription)")
                                return
                            }
                            
                            self.sendEmailVerification(user: user)
                        }
                    }
                    
                    // If there is a photo, upload it and get the URL for it
                    // otherwise, just call the photoUploadHandler with no URL
                    if let photo = values.photo {
                        self.uploadProfilePhoto(
                            userId: user.uid,
                            image: photo,
                            callback: photoUploadHandler)
                    } else {
                        photoUploadHandler(nil, nil)
                    }

                    
            }
        }
    }
    
    func promptForVerification(user: User) {
        UIUtils.modalConfirm(
            parent: self,
            title: "Email Verification",
            message: "An email has been sent to" +
            " the account email address. Please" +
            " check your mail and click the link to" +
            " verify your email address.\n" +
            "\n" +
            "Click OK after following the instructions" +
            " in the account verification email") { (ok) in
                if ok {
                    user.reload { (error) in
                        if error == nil && user.isEmailVerified {
                            self.continueToMainUI()
                        } else {
                            self.promptForVerification(user: user)
                        }
                    }
                }
        }
    }
    
    func sendEmailVerification(user: User) {
        user.sendEmailVerification() { error in
            if error == nil {
                self.promptForVerification(user: user)
            } else {
                UIUtils.modalDialog(
                    parent: self,
                    title: "Email Verification Failed",
                    message: "Unable to send account" +
                    " verification email. Try again later")
            }
        }
    }
    
    enum UpdateAccountError: Error {
        case NotSignedIn
        case ValidationFailed
    }
    
    func updateAccount(completionHandler: @escaping ([Error]?) -> Void) {
        var errors: [Error] = []
        
        guard let user = Auth.auth().currentUser else {
            errors.append(UpdateAccountError.NotSignedIn)
            completionHandler(errors)
            return
        }
        
        guard let values = validate(
            type: ValidationType.updateAccount) else {
                errors.append(UpdateAccountError.ValidationFailed)
                completionHandler(errors)
                return
        }
        
        var expectedCompletions = 0
        var receivedCompletions = 0
        
        let profileChangeCallback: UserProfileChangeCallback = { error in
            DispatchQueue.main.async {
                if let error = error {
                    errors.append(error)
                }
                receivedCompletions += 1
                
                if receivedCompletions == expectedCompletions {
                    completionHandler(errors.isEmpty != false
                        ? nil
                        : errors)
                }
            }
        }

        if user.displayName != values.displayName {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = values.displayName
            expectedCompletions += 1
            changeRequest.commitChanges(completion: profileChangeCallback)
        }
        
        if user.email != values.email {
            expectedCompletions += 1
            user.updateEmail(to: values.email, completion: profileChangeCallback)
        }
        
        if !values.password.isEmpty {
            expectedCompletions += 1
            user.updatePassword(
                to: values.password,
                completion: profileChangeCallback)
        }
    }
    
    func resetPassword(withEmail: String,
                       completionHandler: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: withEmail) { (error) in
            DispatchQueue.main.async {
                if error == nil {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        }
    }
    
    func promptResetPassword(withEmail: String,
                             completionHandler: @escaping (Bool) -> Void) {
        
        UIUtils.modalConfirm(
            parent: self,
            title: "Password Recovery Email",
            message: "Send a password recovery email to \(withEmail)?") { (ok) in
                DispatchQueue.main.async {
                    if ok {
                        self.resetPassword(
                            withEmail: withEmail,
                            completionHandler: completionHandler)
                    }
                }
        }
    }
    
    func continueToMainUI() {
        performSegue(withIdentifier: "authSuccess", sender: self)
    }
    
    func uploadProfilePhoto(userId: String, image: UIImage,
                            callback: @escaping (URL?, Error?) -> Void) {
        let storage = Storage.storage()
        let root = storage.reference()
        let profilePhotos = root.child("profilePhotos")
        let photo = profilePhotos.child(userId)
        guard let jpeg = image.jpegData(compressionQuality: 0.7) else {
            callback(nil, nil)
            return
        }
        
        let metadata = StorageMetadata(dictionary: [
            "contentType": "image/jpeg"
        ])
        
        photo.putData(jpeg, metadata: metadata) { (metadata, error) in
            photo.downloadURL(completion: callback)
        }
    }
    
    public static func isValid(email: String) -> Bool {
        let rfc5322 = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        do {
            let regex = try NSRegularExpression(pattern: rfc5322, options: .caseInsensitive)
            
            return regex.firstMatch(
                in: email,
                options: .init(),
                range: NSRange(location: 0, length: email.count)) != nil
        } catch {
            return false
        }
    }
}
