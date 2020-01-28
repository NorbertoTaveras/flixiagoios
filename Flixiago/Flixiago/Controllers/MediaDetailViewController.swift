//
//  MediaDetailViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit
import UICircularProgressRing

public class MedialDetailViewController: UIViewController {
    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var dateRuntimeView: UILabel!
    @IBOutlet weak var genresView: UILabel!
    @IBOutlet weak var reviewsView: UITextView!
    @IBOutlet weak var backArrowView: UIImageView!
    @IBOutlet weak var backdropView: UIImageView!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var overviewView: UITextView!
    @IBOutlet weak var ratingRingView: UICircularProgressRing!
    @IBOutlet weak var ratingCountView: UILabel!
    @IBOutlet weak var showingsView: UIImageView!
    
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var trailerCollectionView: UICollectionView!
    @IBOutlet weak var similarCollectionView: UICollectionView!
    
    @IBOutlet weak var favoriteView: UIButton!
    @IBOutlet weak var watchView: UIButton!
    @IBOutlet weak var similarHeadingView: UILabel!
    @IBOutlet weak var nearbyContainer: UIView!
    
    var media: Media?
    var castMembers: [CastMember]?
    public var genreList: GenreList.GenreLookup?
    var castMemberScroller: ImageScrollerManager?
    var trailerScroller: ImageScrollerManager?
    var similarScroller: ImageScrollerManager?
    
    var reviewsContainer: [Review] = []
    
    var selectedSimilar: Media?
    
    private var color: UIColor?
    private var selectedCastMember: CastMember?

    var pending = 0
    var completed = 0
    var removeIndicator: UIUtils.IndicatorRemover?
    
    private func handleCompletion() {
        completed += 1
        
        if completed == pending,
            let removeIndicator = removeIndicator {
            removeIndicator()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let mediaType = media?.getMediaType()
        
        nearbyContainer.isHidden = mediaType == "tv"
        
        let tapNearbyGesture = UITapGestureRecognizer(
            target: self, action: #selector(nearbyTapped))
        nearbyContainer.isUserInteractionEnabled = true;
        nearbyContainer.addGestureRecognizer(tapNearbyGesture)
        
        pending = 0
        completed = 0
        
        let type = media?.getNoun(capitalize: true, plural: true) ?? "???"
        similarHeadingView.text = "Similar \(type)"
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backArrowTap))
        backArrowView.isUserInteractionEnabled = true
        backArrowView.addGestureRecognizer(backTap)
        
        titleView.text = media?.getTitle()
        ratingCountView.text = "\(media?.vote_count ?? 0) Ratings"

        UIUtils.setupRatingRing(
            ringView: ratingRingView,
            vote_average: media?.vote_average)
        
        overviewView.text = media?.overview ?? "Overview Unavailable"

        media?.setBackdropImage(into: backdropView)
        media?.setPosterImage(into: posterView)
        posterView.layer.cornerRadius = 4.0
        castMemberScroller = ImageScrollerManager(
            view: castCollectionView)
        trailerScroller = ImageScrollerManager(
            view: trailerCollectionView)
        similarScroller = ImageScrollerManager(
            view: similarCollectionView)
        
        pending += 1
        media?.getDetailsRecord(callback: { (media, error) in
            self.dateRuntimeView.text = media?.getSeasonEpisodeText()
            self.handleCompletion()
        })

        pending += 1
        media?.getReviews(page: 1) { (reviews, error) in
            self.processReviews(reviews?.results, error)
            self.handleCompletion()
        }
        
        pending += 1
        media?.getCast(callback: { (cast, error) in
            guard let cast = cast?.cast
                else { return }
            
            self.pending += 1
            self.castMemberScroller?.setItems(items: cast) { item in
                guard let castMember = item as? CastMember
                    else { self.handleCompletion(); return }
                
                self.selectedCastMember = castMember
                
                self.performSegue(
                    withIdentifier: "castMemberView",
                    sender: self)
                
                self.handleCompletion()
            }
            
            self.handleCompletion()
        })
        
        pending += 1
        media?.getTrailers(callback: { (trailers, error) in
            guard let trailers = trailers?.results
                else { self.handleCompletion(); return }
            
            self.pending += 1
            self.trailerScroller?.setItems(items: trailers) { item in
                guard let trailer = item as? Trailer,
                    let videoUrl = trailer.getVideoUrl()
                    else { self.handleCompletion(); return }
                
                UIUtils.playVideoUrl(
                    parentView: self,
                    urlText: videoUrl,
                    inBrowser: true)
                
                self.handleCompletion()
            }
        })
        
        pending += 1
        media?.getSimilar(page: 1, callback: { (similars, error) in
            guard let similars = similars
                else { self.handleCompletion(); return }
            
            self.pending += 1
            self.similarScroller?.setItems(items: similars) { item in
                guard let media = item as? Media
                    else { self.handleCompletion(); return }
                
                self.pending += 1
                TMDBService.getMediaDetail(
                    id: media.id,
                    type: media.getMediaType()) { (media, error) in
                        self.selectedSimilar = media
                        
                        self.performSegue(
                            withIdentifier: "MediaDetailSelfReference",
                            sender: self)
                        
                        self.handleCompletion()
                }
                
                self.handleCompletion()
            }
        })

        self.pending += 1
        media?.getGenreList { (genreList, error) in
            guard let genreList = genreList else {
                self.genresView.text = "Genres Unknown"
                self.handleCompletion()
                return
            }
            
            self.genresView.text = self.media?.formatGenreList(lookup: genreList)
            
            self.handleCompletion()
        }
        
        media?.setupFavoriteButton(into: favoriteView)
        
        media?.setupWatchButton(into: watchView)
        
        let isLoggedIn = AuthUtils.isLoggedIn()
        favoriteView.isUserInteractionEnabled = isLoggedIn
        watchView.isUserInteractionEnabled = isLoggedIn
        favoriteView.isEnabled = isLoggedIn
        watchView.isEnabled = isLoggedIn
    }
    
    @objc private func nearbyTapped() {
        guard let title = media?.getTitle()
            else { return }
        
        UIUtils.openGoogleSearch(query: title + " showtimes")
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        if pending < completed {
            removeIndicator = UIUtils.createIndicator(parent: self)
        }
    }
    
    private func processReviews(_ reviews: [Review]?, _ error: Error?) {
        reviewsView.text = "\(String(reviews?.count ?? 0)) Reviews"
        
        guard let reviews = reviews
            else { return }

        reviewsContainer = reviews
        
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(reviewsTapped))
        
        reviewsView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func reviewsTapped(sender: UIView) {
        performSegue(withIdentifier: "reviewView", sender: self)
    }
    
    /*
    // MARK: - Cast Collection View
    */

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return castMembers?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /*guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "mediaCastMemberCell",
            for: indexPath) as? ImageScrollerCollectionViewCell
            else { return UICollectionViewCell() }
        
        guard let castMember = castMembers?[indexPath.row]
            else { return cell }
        
        cell.setupCastCell(member: castMember)
        
        return cell */
        return UICollectionViewCell()
    }
    
    @objc func backArrowTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favoriteClicked(_ sender: UIButton) {
        media?.toggleFavorite(into: favoriteView)
    }
    
    @IBAction func watchClicked(_ sender: UIButton) {
        media?.toggleWatch(into: watchView)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "reviewView":
            guard let destination = segue.destination as? ReviewsViewController
                else { return }
            
            destination.mediaReviews = reviewsContainer
            break;
            
        case "castMemberView":
            guard let destination = segue.destination as? CastViewController
                else { return }
            
            guard let selectedCastMemberId = selectedCastMember?.id
                else { return }
            
            destination.personId = selectedCastMemberId
            
            break;
            
        case "MediaDetailSelfReference":
            guard let destination = segue.destination
                as? MedialDetailViewController
                else { return }
            
            guard let selectedSimilarMedia = selectedSimilar
                else { return }
            
            destination.media = selectedSimilarMedia
            
            break
            
        default:
            break;
        }
    }

}
