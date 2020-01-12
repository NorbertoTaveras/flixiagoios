//
//  UIUtils.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class UIUtils {
    static let dateFormat = "MMMM d, y"
    
    enum ModalButton {
        case OK
        case Second
    }
    
    typealias ModalButtonCallback = (ModalButton) -> Void
    
    typealias IndicatorRemover = () -> Void

    static func modalDialog(parent: UIViewController,
                            title: String,
                            message: String) {
        modalDialog(parent: parent,
                    title: title,
                    message: message,
                    secondButtonText: nil) { modalButton in
        }
    }

    static func modalDialog(parent: UIViewController,
                            title: String,
                            message: String,
                            secondButtonText: String?,
                            callback: @escaping ModalButtonCallback) {
        
        let alert = UIAlertController.init(
            title: title,
            message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            callback(.OK)
        }
        
        let secondButton: UIAlertAction?
        if let secondButtonText = secondButtonText {
            secondButton = UIAlertAction(title: secondButtonText, style: .default) { (action) in
                callback(.Second)
            }
        } else {
            secondButton = nil
        }
        
        alert.addAction(okButton)
        
        if let secondButton = secondButton {
            alert.addAction(secondButton)
        }
        
        parent.present(alert, animated: true, completion: nil)
    }
    
    static func modalConfirm(parent: UIViewController,
                             title: String, message: String,
                             completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController.init(
            title: title,
            message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction.init(
            title: "OK", style: .default, handler: { _ in
                completionHandler(true)
        })
        
        let cancelButton = UIAlertAction.init(
            title: "Cancel", style: .default, handler: { _ in
                completionHandler(false)
        })
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        parent.present(alert, animated: true, completion: nil)
    }
    
    static func setSizeByFrame(
        view: UIView,
        minWidth: CGFloat,
        width: CGFloat,
        height: CGFloat) {
        
        view.frame.size = CGSize(
            width: max(width, minWidth),
            height: height)
    }
    
    static func setHeightByConstraint(
        view: UIView,
        constraint: NSLayoutConstraint,
        height: CGFloat) {
        
        view.removeConstraint(constraint)
        
        let newHeightConstraint = NSLayoutConstraint(
            item: view,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: height)
        
        newHeightConstraint.isActive = true
        
        view.addConstraint(newHeightConstraint)
        view.layoutIfNeeded()
    }
    
    static func sizeThatFits(view: UIView) ->
        CGSize {
            
        let newSize = view.sizeThatFits(CGSize(
            width: view.frame.size.width,
            height: CGFloat.greatestFiniteMagnitude))
        
        return newSize
    }
    
    static func autosizeView(view: UIView) {
        let fixedWidth = view.frame.size.width

        let newSize = sizeThatFits(view: view)
        
        setSizeByFrame(
            view: view,
            minWidth: fixedWidth,
            width: newSize.width,
            height: newSize.height)
    }

    static func sizeView(view: UIView, constraintId: String, size: CGSize) {
        for constraint in view.constraints {
            if constraint.identifier == constraintId {
                setHeightByConstraint(
                    view: view,
                    constraint: constraint,
                    height: size.height)
            }
        }
    }
    
    static func autosizeView(view: UIView, constraintId: String) {
        UIUtils.autosizeView(view: view,
                     constraintId: constraintId,
                     maxHeight: 1e+9)
    }

    static func autosizeView(view: UIView,
                             constraintId: String,
                             maxHeight: CGFloat) {
        for constraint in view.constraints {
            if constraint.identifier == constraintId {
                let newSize = sizeThatFits(view: view)
                setHeightByConstraint(
                    view: view,
                    constraint: constraint,
                    height: min(maxHeight, newSize.height))
            }
        }
    }
    
    static func formatDate(from date: Date) -> String {
        let formatter = DateFormatter(
            withFormat: dateFormat,
            locale: Locale.current.identifier)
        
        return formatter.string(from: date)
    }
    
    static func playVideoUrl(
        parentView: UIViewController,
        urlText: String,
        inBrowser: Bool) {
        guard let videoURL = URL(string: urlText)
            else { return }
        
        if inBrowser {
            guard let url = URL(string: urlText)
                else { return }
            UIApplication.shared.open(
                url,
                options: [:],
                completionHandler: nil)
        } else {
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            parentView.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    // Creates and animates an activity indicator at the center of the passed
    // view controller, and returns a function you can call to remove
    // and discard it
    static func createIndicator(parent: UIViewController) -> IndicatorRemover {
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.center = parent.view.center
        activityView.startAnimating()

        parent.view.addSubview(activityView)
        
        return {
            activityView.removeFromSuperview()
        }
    }
    
    class PlaceholderView {
        let parent: UIView
        let placeholderView: UIView
        
        init(parent: UIView, text: String) {
            self.parent = parent
            
            placeholderView = UIView()
            placeholderView.translatesAutoresizingMaskIntoConstraints = false
            placeholderView.removeConstraints(placeholderView.constraints)
            placeholderView.isHidden = true
            
            let imageView = UIImageView()
            let image = UIImage(systemName: "exclamationmark.triangle.fill")
            imageView.image = image
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.removeConstraints(imageView.constraints)
            placeholderView.addSubview(imageView)
            
            let labelView = UILabel()
            labelView.translatesAutoresizingMaskIntoConstraints = false
            labelView.removeConstraints(labelView.constraints)
            labelView.numberOfLines = 0
            labelView.text = text
            labelView.textAlignment = .center
            labelView.textColor = .red
            placeholderView.addSubview(labelView)
            
            parent.addSubview(placeholderView);
            
            let leftBottomRight: [NSLayoutConstraint.Attribute] = [
                .left,
                .bottom,
                .right
            ]
            
            let leftRight: [NSLayoutConstraint.Attribute] = [
                .left,
                .right
            ]
            
            // placeholder left, right bound to parent
            for edge in leftRight {
                // Left and right of placeholder
                // to left and right of parent
                parent.addConstraint(NSLayoutConstraint(
                    item: placeholderView,
                    attribute: edge,
                    relatedBy: .equal,
                    toItem: parent,
                    attribute: edge,
                    multiplier: 1.0,
                    constant: 0.0))
            }
            
            // placeholder is centered vertically
            // relative to parent
            parent.addConstraint(NSLayoutConstraint(
                item: placeholderView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: parent,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0.0))
            
            // placeholder is centered vertically
            // relative to parent
            parent.addConstraint(NSLayoutConstraint(
                item: placeholderView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: parent,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0.0))

            // Left and right of label
            // to left and right of placeholder
            for edge in leftBottomRight {
                parent.addConstraint(NSLayoutConstraint(
                    item: labelView,
                    attribute: edge,
                    relatedBy: .equal,
                    toItem: placeholderView,
                    attribute: edge,
                    multiplier: 1.0,
                    constant: 0.0))
            }
          
            // Bottom of image to top of label
            parent.addConstraint(NSLayoutConstraint(
                item: labelView,
                attribute: .top,
                relatedBy: .equal,
                toItem: imageView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0))
            
            // Image is 1:1 aspect
            parent.addConstraint(NSLayoutConstraint(
                item: imageView,
                attribute: .top,
                relatedBy: .equal,
                toItem: placeholderView,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0))
            
            // Image is 1:1 aspect
            parent.addConstraint(NSLayoutConstraint(
                item: imageView,
                attribute: .height,
                relatedBy: .equal,
                toItem: imageView,
                attribute: .width,
                multiplier: 1.0,
                constant: 0.0))

            // imageView height
            parent.addConstraint(NSLayoutConstraint(
                item: imageView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: 32.0))
            
            // Image view centered horizontally
            parent.addConstraint(NSLayoutConstraint(
                item: imageView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: placeholderView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0.0))

            parent.layoutIfNeeded()
        }
        
        func handleLayoutSubViews() {
            placeholderView.frame = parent.bounds
        }
        
        func toggle(show: Bool) {
            placeholderView.isHidden = !show
        }
    }
    
}
