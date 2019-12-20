//
//  MediaTabbarController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/17/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit

class MediaTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let selectedVC = viewControllers?[selectedIndex]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Got segue id \(segue.identifier)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
