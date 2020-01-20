//
//  FavoriteCollectionCell.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/18/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit

class FavoriteCollectionCell: UICollectionViewCell {
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var favoriteView: UIImageView!
    
    var info: FavoriteRecord.KindTypeId?
    var media: Media?
    
    var favoriteToggler: Media.FavoriteToggler?
    
    override func awakeFromNib() {
        self.posterView.layer.cornerRadius = 8.0
    }
    
    func setupCell(info: FavoriteRecord.KindTypeId) {
        self.info = info

        TMDBService.getMediaDetail(
            id: info.id,
            type: info.type) { (media, error) in
                self.media = media
                
                self.favoriteToggler = media?.autoButton(
                    kind: info.kind,
                    into: self.favoriteView)
                
                media?.setPosterImage(into: self.posterView)
        }
    }
}
