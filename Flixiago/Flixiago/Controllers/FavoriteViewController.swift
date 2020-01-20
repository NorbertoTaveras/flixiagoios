//
//  FavoriteViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/18/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit

class FavoriteViewController:
    UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout{
    
    enum ViewType: Int {
        case ALL
        case MOVIE
        case SHOW
    }

    @IBOutlet weak var typeFilterView: UISegmentedControl!
    @IBOutlet weak var favoritesView: UICollectionView!
    
    var favorites: [FavoriteRecord]?
    var displayedFavorites: [FavoriteRecord] = []
    var favoriteListenerId: Int?
    var viewType: ViewType = .ALL
    var selectedMedia: Media?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        favoritesView.delegate = self
        favoritesView.dataSource = self
        self.typeFilterView?.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.white],
            for: .selected)
    }
    
    private func loadFavorites() {
        favorites = getRecords()
        
        filterFavorites()
    }
    
    func filterFavorites() {
        displayedFavorites.removeAll()
        
        guard let favorites = favorites
            else { return }
        
        for favorite in favorites {
            switch viewType {
            case .ALL:
                displayedFavorites.append(favorite)
                
            case .MOVIE:
                if favorite.parseKey()?.type == Movie.type {
                    displayedFavorites.append(favorite)
                }
                
            case .SHOW:
                if favorite.parseKey()?.type == Show.type {
                    displayedFavorites.append(favorite)
                }
                
            }
        }
        
        displayedFavorites.sort { (lhs, rhs) -> Bool in
            return lhs.timestamp > rhs.timestamp
        }
        
        favoritesView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFavorites()
        
        favoriteListenerId = FavoriteRecord.startListeningForChanges {
            self.favorites = self.getRecords()
            self.filterFavorites()
        }
    }
    
    public func getRecords() -> [FavoriteRecord] {
        return FavoriteRecord.getFavorites(
            onlyFavorite: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let id = favoriteListenerId {
            FavoriteRecord.stopListeningForChanges(id: id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return displayedFavorites.count
    }
    
    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = favoritesView.dequeueReusableCell(
            withReuseIdentifier: "favoriteCell",
            for: indexPath)
            as? FavoriteCollectionCell
            else { return UICollectionViewCell() }
        
        let target = displayedFavorites[indexPath.row]

        guard let info = target.parseKey()
            else { return UICollectionViewCell() }
        
        cell.setupCell(info: info)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let record = displayedFavorites[indexPath.row]
        openSelectedFavorite(record: record)
    }
    
    func openSelectedFavorite(record: FavoriteRecord) {
        guard let info = record.parseKey()
            else { return }
        
        TMDBService.getMediaDetail(
            id: info.id,
            type: info.type) { (media, error) in
                
                if let media = media {
                    self.open(media: media)
                } else {
                    UIUtils.modalDialog(
                        parent: self,
                        title: "Error",
                        message: "Failed to get media details: " +
                        (error?.localizedDescription
                        ?? "<unknown error>"))
                }
        }
    }
    
    func open(media: Media) {
        switch media.getMediaType() {
        case "tv":
            selectedMedia = media
            
            performSegue(
                withIdentifier: "MediaSeasonsView",
                sender: self)
            break
            
        case "movie":
            selectedMedia = media
            
            performSegue(
                withIdentifier: "MediaDetailView",
                sender: self)
            break
            
        default:
            fatalError("Unhandled media type")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        switch segue.identifier {
        case "MediaDetailView":
            guard let destination = segue.destination
                as? MedialDetailViewController
                else { return }
            
            destination.media = selectedMedia
            break
            
        case "MediaSeasonsView":
            guard let destination = segue.destination
                as? SeasonsViewController
                else { return }
            
            destination.show = selectedMedia as? Show
            destination.episodes = nil
            break

        default:
            fatalError("Unhandled segue ID")
            break
        }
    }
    
    // MARK: - Segmented Control
    
    @IBAction func typeFilterChange(_ sender: UISegmentedControl) {
        viewType = ViewType(rawValue: sender.selectedSegmentIndex) ?? .ALL
        filterFavorites()
    }
}
