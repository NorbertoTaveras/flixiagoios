//
//  ReviewTableViewCell.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/6/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var authorView: UILabel!
    @IBOutlet weak var reviewView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupCell(author: String?, review: String?) {
        authorView.text = author ?? "<unknown>"
        reviewView.text = review ?? "<unknown>"
        
        UIUtils.autosizeView(view: reviewView)
    }
}
