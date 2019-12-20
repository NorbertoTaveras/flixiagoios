//
//  MediaTableViewCell.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit
import UICircularProgressRing

class MediaTableViewCell: UITableViewCell {
    /*private static let red = UIColor.init(
        displayP3Red: 0.7,
        green: 0.2,
        blue: 0.2,
        alpha: 1.0) */
    
    /*private static let green = UIColor.init(
        displayP3Red: 0.2,
        green: 0.8,
        blue: 0.2,
        alpha: 1.0)*/
    
    let green = UIColor(
        red: CGFloat(0x40) / 255.0,
        green: CGFloat(0xC7) / 255.0,
        blue: CGFloat(0x58) / 255.0,
        alpha: CGFloat(1.0))
    
    let red = UIColor(
        red: CGFloat(0xF3) / 255.0,
        green: CGFloat(0x2E) / 255.0,
        blue: CGFloat(0x55) / 255.0,
        alpha: 1.0)

    let purple = UIColor(
        red: CGFloat(0x4e) / 255.0,
        green: CGFloat(0x32) / 255.0,
        blue: CGFloat(0x8e) / 255.0,
        alpha: CGFloat(1.0))
    
    let yellow = UIColor(
        red: CGFloat(0xE8) / 255.0,
        green: CGFloat(0xC5) / 255.0,
        blue: CGFloat(0x46) / 255.0,
        alpha: 1.0)
    
    @IBOutlet weak var certificationView: UILabel!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var genresView: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var ratingView: UICircularProgressRing!
    @IBOutlet weak var favoriteView: UIImageView!
    
    public var genreList: GenreList.GenreLookup?
    
    private var currentMedia: Media?
    
    private var color: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ratingView.maxValue = 100.0
        ratingView.outerRingColor = purple
        ratingView.outerRingWidth = 1
        
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(favoriteClick))
        
        favoriteView.addGestureRecognizer(recognizer)
    }
    
    @objc func favoriteClick() {
        currentMedia?.toggleFavorite(into: favoriteView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupMediaCell(media: Media) {
        currentMedia = media
        media.setPosterImage(into: posterView)
        posterView.layer.cornerRadius = 4.0
        titleView.text = media.getTitle()
        dateView.text = media.formatReleaseDate()
        media.getGenreList { (genreList, error) in

            if self.currentMedia?.id != media.id {
                return
            }
            
            guard let genreList = genreList else {
                self.genresView.text = "???"
                return
            }
            
            self.genresView.text = media.formatGenreList(lookup: genreList)
        }
        
        /*let color = (media.vote_average ?? 0) >= Float(5.0)
            ? MediaTableViewCell.green
            : MediaTableViewCell.red; */
        let score = 100.0 * CGFloat((media.vote_average ?? 0) / Float(10.0))
        
        if score < 40 {
            color = red
        } else if score < 60 {
            color = UIColor.orange
        } else if score < 75 {
            color = yellow
        } else {
            color = green
        }
        
        ratingView.innerRingColor = color!
        /*ratingView.fontColor = (media.vote_average ?? 0) >= Float(5.0)
            ? UIColor.black
            : color */

        ratingView.startProgress(to: 0, duration: 0.001) {
            self.ratingView.startProgress(
                to: 100.0 * CGFloat((media.vote_average ?? 0) / Float(10.0)),
                duration: 1.0)
        }
        
        media.getCertification() { (cert, error) in
            if self.currentMedia?.id != media.id {
                return
            }
            
            var formattedCert = cert
            
            if formattedCert == nil || (formattedCert?.isEmpty ?? true) {
                formattedCert = "Certification Unknown"
            }

            self.certificationView.text = formattedCert
        }
        
        media.setupFavoriteButton(into: favoriteView)
    }
}
