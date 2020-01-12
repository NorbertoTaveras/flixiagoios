//
//  WatchlistViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/7/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import UIKit

class WatchlistViewController: FavoriteViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func getRecords() -> [FavoriteRecord] {
        return FavoriteRecord.getWatches(onlyFavorite: true)
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
