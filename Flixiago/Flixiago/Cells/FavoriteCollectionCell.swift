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
    
    var info: FavoriteRecord.TypeIdPair?
    var media: Media?
    
    override func awakeFromNib() {
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(favoriteClick))
        
        favoriteView.addGestureRecognizer(recognizer)
        
        self.posterView.layer.cornerRadius = 8.0
    }
    
    func setupCell(info: FavoriteRecord.TypeIdPair) {
        self.info = info
        
        TMDBService.getMediaDetail(
            id: info.id,
            type: info.type) { (media, error) in
                self.media = media
                media?.setPosterImage(into: self.posterView)
                media?.setupFavoriteButton(into: self.favoriteView)
        }
    }
    
    @objc func favoriteClick() {
        media?.toggleFavorite(into: favoriteView)
    }
}
