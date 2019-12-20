//
//  ImageScrollerManager.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing

public class ImageScrollerManager:
    NSObject,
    UICollectionViewDelegate,
    UICollectionViewDataSource {
    
    var collectionView: UICollectionView?
    var items: [ImageProvider]?

    public init(view: UICollectionView) {
        self.collectionView = view
        super.init()
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
    
    public func setItems(items: [ImageProvider]) {
        self.items = items
        collectionView?.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "imageScrollerCell",
                for: indexPath)
            as? ImageScrollerCollectionViewCell
            else { return UICollectionViewCell() }
        
        guard let item = items?[indexPath.row]
            else { return UICollectionViewCell() }
        
        collectionCell.setItem(item: item)
                
        return collectionCell
    }
}

public class ImageScrollerCollectionViewCell: UICollectionViewCell {
    
    // #4e328e
    let purple = UIColor(
        red: CGFloat(0x4e) / 255.0,
        green: CGFloat(0x32) / 255.0,
        blue: CGFloat(0x8e) / 255.0,
        alpha: CGFloat(1.0))
    
    // #40C758
    let green = UIColor(
        red: CGFloat(0x40) / 255.0,
        green: CGFloat(0xC7) / 255.0,
        blue: CGFloat(0x58) / 255.0,
        alpha: CGFloat(1.0))
    
    //#F32E55
    let red = UIColor(
        red: CGFloat(0xF3) / 255.0,
        green: CGFloat(0x2E) / 255.0,
        blue: CGFloat(0x55) / 255.0,
        alpha: 1.0)
    
    // #e8c546
    let yellow = UIColor(
        red: CGFloat(0xE8) / 255.0,
        green: CGFloat(0xC5) / 255.0,
        blue: CGFloat(0x46) / 255.0,
        alpha: 1.0)
    
    @IBOutlet weak var ratingView: UICircularProgressRing?
    @IBOutlet weak var captionView: UILabel?
    @IBOutlet weak var photoView: UIImageView!
    
    private var color: UIColor?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        if let ratingView = ratingView {
            if ratingView.font.pointSize != 8.0 {
                ratingView.font = UIFont(
                    descriptor: ratingView.font.fontDescriptor,
                    size: 8.0)
            }
            ratingView.startProgress(to: 0.0, duration: 0.01)
        }
    }
    
    public func setItem(item: ImageProvider) {
        captionView?.text = item.getImageCaption()
        
        if let urlText = item.getImageUrl(),
            let url = URL(string: urlText) {
            photoView.kf.setImage(with: url)
        } else {
            photoView.image = nil
        }
        
        if let ratingView = ratingView,
            let rating = item.getImageRating() {
            
            let score = 100.0 * CGFloat((rating) / Float(10.0))
            
            if score < 40 {
                color = red
            } else if score < 60 {
                color = UIColor.orange
            } else if score < 75 {
                color = yellow
            } else {
                color = green
            }
            ratingView.maxValue = 100.0
            ratingView.outerRingColor = purple
            ratingView.innerRingColor = color!
            ratingView.outerRingWidth = 1.0
            ratingView.startProgress(
                to: CGFloat(0),
                duration: 0.01) {
                ratingView.startProgress(
                    to: CGFloat(rating * 10),
                    duration: 1)
            }
        }
    }
}
