//
//  ViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/6/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import UIKit

class ReviewsViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource {

    var mediaReviews: [Review]?
    
    @IBOutlet weak var reviewsTable: UITableView!
    @IBOutlet weak var backView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewsTable.delegate = self
        reviewsTable.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(backTapped))
        backView.addGestureRecognizer(tapGesture)
        backView.isUserInteractionEnabled = true
    }
    

    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return mediaReviews?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "reviewCell",
            for: indexPath)
            as? ReviewTableViewCell
            else { return UITableViewCell() }
        
        guard let mediaReviews = mediaReviews
            else { return UITableViewCell() }
        
        let target = mediaReviews[indexPath.row]
        
        cell.setupCell(author: target.author, review: target.content)
        
        return cell
    }
    
    @objc private func backTapped(sender: UIView) {
        dismiss(animated: true, completion: nil)
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
