//
//  SeasonsViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 1/15/20.
//  Copyright © 2020 Norberto Taveras. All rights reserved.
//

import UIKit
import UICircularProgressRing

class SeasonsViewController:
    UIViewController,
    UITableViewDelegate,
UITableViewDataSource {
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var showSummaryView: UILabel!
    @IBOutlet weak var genresView: UILabel!
    @IBOutlet weak var backdropView: UIImageView!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var seasonTitleView: UILabel!
    @IBOutlet weak var seasonsTable: UITableView!
    @IBOutlet weak var favoriteView: UIButton!
    @IBOutlet weak var watchView: UIButton!
    @IBOutlet weak var ratingView: UICircularProgressRing!
    @IBOutlet weak var ratingCountView: UILabel!
    
    @IBOutlet weak var ratingsView: UILabel!
    
    var show: Show?
    var episodes: [ShowEpisode]?
    
    var selectedEpisodes: [ShowEpisode]?
    
    var watchToggler: Media.FavoriteToggler?
    var favoriteToggler: Media.FavoriteToggler?
    var selectedSeason: ShowSeason?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        seasonsTable.delegate = self
        seasonsTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        show?.setupWatchButton(into: watchView)
        show?.setupFavoriteButton(into: favoriteView)
        show?.setPosterImage(into: posterView)
        show?.setBackdropImage(into: backdropView)
        
        showSummaryView.text = "\(show?.number_of_seasons ?? 0) seasons" +
            " • \(show?.number_of_episodes ?? 0) episodes "
        ratingCountView.text = "\(show?.vote_count ?? 0) Ratings"
        titleView.text = show?.getTitle()
        
        if watchToggler == nil && favoriteToggler == nil {
            watchToggler = show?.autoButton(kind: "w", into: watchView)
            favoriteToggler = show?.autoButton(kind: "f", into: favoriteView)
        } else {
            show?.setupWatchButton(into: watchView)
            show?.setupFavoriteButton(into: favoriteView)
        }
        
        UIUtils.setupRatingRing(
            ringView: ratingView,
            vote_average: show?.vote_average)
        
        TMDBService.getShowGenres { (genreLookup, error) in
            guard let genreLookup = genreLookup
                else { return }
            
            self.genresView.text = self.show?.formatGenreList(
                lookup: genreLookup)
        }
        
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(backTapped))
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tapRecognizer)
        
        seasonsTable.reloadData()
    }
    
    @objc private func backTapped(sender: UIView) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let episodes = episodes {
            return episodes.count
        } else {
            return show?.seasons?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let episodes = episodes {
            // Episode list
        
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "episodeCell")
                as? EpisodeTableViewCell
                else { return UITableViewCell() }
            
            cell.setupCell(
                target: episodes[indexPath.row])
            
                    seasonTitleView.text = "Season \(selectedSeason?.season_number ?? 0)"
            return cell
        } else {
            // Season list
            guard let show = show,
                let cell = tableView.dequeueReusableCell(
                withIdentifier: "seasonCell")
                as? SeasonTableViewCell,
                let seasons = show.seasons
                else { return UITableViewCell() }

            cell.setupCell(
                show: show,
                seasonIndex: indexPath.row)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if let episodes = episodes {
            // Tapped an episode
            // Cell controller handles it
        } else {
            // Tapped a season
            guard let show = show,
                let seasons = show.seasons
                else { return }
            
            selectedSeason = seasons[indexPath.row]
            
            guard let season_number = selectedSeason?.season_number
                else { return }
            
            TMDBService.getShowSeason(
                id: show.id,
                seasonNumber: season_number) { (showSeason, error) in
                    guard let showSeason = showSeason
                        else { return }
                    
                    self.selectedEpisodes = showSeason.episodes
                    self.performSegue(withIdentifier: "episodeView",
                                 sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "episodeView":
            guard let destination = segue.destination
                as? SeasonsViewController
                else { return }
            
            destination.show = show
            destination.selectedSeason = selectedSeason
            destination.episodes = selectedEpisodes

            break
    
        default:
            fatalError("Unhandled segue")
            break

        }
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
