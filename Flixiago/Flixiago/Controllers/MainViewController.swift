//
//  ViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit
import FirebaseAuth
import MaterialComponents
import Reachability

class MainViewController: UIViewController {
    var reachability: Reachability?
    var alertShown: Bool = false

    @IBOutlet weak var loginView: MDCButton!
    @IBOutlet weak var signUpView: MDCButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reachability = try! Reachability()
        
        guard let reachability = reachability
            else { return }

        reachability.whenReachable = { reachability in
            self.setNetworkReachable(true)
        }
        
        reachability.whenUnreachable = { _ in
            self.setNetworkReachable(false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reachability?.stopNotifier()
        reachability = nil
    }
    
    @IBAction func signOut(segue: UIStoryboardSegue) {
        try? Auth.auth().signOut()
    }
    
    func setNetworkReachable(_ reachable: Bool) {
        print("Network reachable = \(reachable)")
        
        loginView.isEnabled = reachable
        signUpView.isEnabled = reachable
        
        if !alertShown && !reachable {
            alertShown = true
            
            UIUtils.modalDialog(
                parent: self,
                title: "No network connection",
                message: "Network is offline. Login buttons" +
                    " will be enabled when network is online.")
        }
    }
}

