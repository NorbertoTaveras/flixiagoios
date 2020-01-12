//
//  RoleTableViewCell.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/6/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import UIKit
import UICircularProgressRing

class RoleTableViewCell: UITableViewCell {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var characterView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var genreView: UILabel!
    @IBOutlet weak var ratingView: UICircularProgressRing!
    
    var item: PersonCombinedCreditsRole?
    private var color: UIColor?
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setupCell(_ role: PersonCombinedCreditsRole) {
        item = role
        setupPoster()
        titleView.text = role.name
        characterView.text = role.character ?? "<unknown>"
        
        let score = 100.0 * CGFloat((role.vote_average ?? 0) / Float(10.0))
        
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
        ratingView.outerRingWidth = 2.0
        ratingView.font = UIFont.systemFont(ofSize: 12.0)
        ratingView.startProgress(
            to: CGFloat(0),
            duration: 0.001) {
                self.ratingView.startProgress(
                to: score,
                duration: 1)
        }
        
        /*ratingView.startProgress(
            to: CGFloat(role.vote_average ?? 0 * 10),
            duration: 1) */

        if let date = Media.parseDate(fromText: role.release_date) {
            dateView.text = UIUtils.formatDate(from: date)
        } else {
            dateView.text = "<unknown>"
        }
        
        switch role.media_type {
        case "tv":
            TMDBService.getShowGenres { (lookup, error) in
                guard let lookup = lookup
                    else { return }
                
                let genreText = Media.formatGenreList(
                    genreIds: role.genre_ids ?? [],
                    lookup: lookup)
                
                self.genreView.text = genreText
            }
            break
            
        case "movie":
            TMDBService.getMovieGenres { (lookup, error) in
                guard let lookup = lookup
                    else { return }
                
                let genreText = Media.formatGenreList(
                    genreIds: role.genre_ids ?? [],
                    lookup: lookup)
                
                self.genreView.text = genreText
            }
            break
            
        default:
            break
            
        }
    }

    private func setupPoster() {
        guard let profile_path = item?.profile_path
            else { posterView.image = nil; return }
        
        let urlText = TMDBUrls.getPosterUrl(
            forWidth: 72, path: profile_path)
        
        guard let url = URL(string: urlText)
            else { posterView.image = nil; return }
        
        posterView.kf.setImage(with: url)
    }
}
