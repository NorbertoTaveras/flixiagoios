//
//  EpisodeTabTableViewCell.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/15/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import UIKit

public class EpisodeTableViewCell: UITableViewCell {

    @IBOutlet weak var episodeNameView: UILabel!
    @IBOutlet weak var episodeDateView: UILabel!
    @IBOutlet weak var watchedView: UIImageView!
    
    private var favoriteTogger: Media.FavoriteToggler?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(target: ShowEpisode) {
        episodeNameView.text = target.name
        
        let formattedDate: String
        
        if let episodeDate = Media.parseDate(
            fromText: target.air_date) {
            
            formattedDate = UIUtils.formatDate(
                from: episodeDate)
        } else {
            formattedDate = "<unknown date>"
        }
        
        let text = "Episode \(target.episode_number ?? 0) - " +
            formattedDate
        
        episodeDateView.text = text
        
        FavoriteRecord.setupButton(
            kind: "e",
            type: "tv",
            id: target.id,
            into: watchedView)

        favoriteTogger = nil
        self.favoriteTogger = Media.FavoriteToggler(
            kind: "e",
            type: "tv",
            media: nil,
            id: target.id,
            into: watchedView)
    }
}
