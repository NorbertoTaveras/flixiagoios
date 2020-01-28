//
//  SeasonTableViewCell.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/15/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import UIKit

public class SeasonTableViewCell: UITableViewCell {

    @IBOutlet weak var seasonNumberView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var completedView: UILabel!
    @IBOutlet weak var watchedTotalView: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(show: Show, seasonIndex: Int) {
        guard let season = show.seasons?[seasonIndex],
            let season_number = season.season_number
            else { return }
        
        seasonNumberView.text = "Season \(season.season_number ?? 0)"
        if let seasonDate = Media.parseDate(fromText: season.air_date) {
            let formattedDate = UIUtils.formatDate(from: seasonDate)
            dateView.text = formattedDate
        } else {
            dateView.text = "<unknown>"
        }
        
        completedView.text = ""
        watchedTotalView.text = "?/\(season.episode_count ?? 0)"
        
        TMDBService.getShowSeason(
            id: show.id,
            seasonNumber: season_number) { (detail, error) in
                guard let episodes = detail?.episodes
                    else { return }
                
                var watched = 0
                
                for episode in episodes {
                    let record = FavoriteRecord.get(
                        kind: "e",
                        type: "tv",
                        id: episode.id)
                    
                    if record?.favorite ?? false {
                        watched += 1
                    }
                }

                self.completedView.text = watched == episodes.count
                    ? "Completed"
                    : ""
                
                self.completedView.layer.cornerRadius = 2.0
                //self.completedView.clipsToBounds = true
                self.completedView.layer.masksToBounds = true
                self.watchedTotalView.text = "\(watched)/\(episodes.count)"
        }
    }
}
