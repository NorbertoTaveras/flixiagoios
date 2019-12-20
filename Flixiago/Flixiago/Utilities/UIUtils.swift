//
//  UIUtils.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import UIKit

class UIUtils {
    
    static func modalDialog(parent: UIViewController,
                            title: String,
                            message: String) {
        let alert = UIAlertController.init(
            title: title,
            message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okButton)
        
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
}
