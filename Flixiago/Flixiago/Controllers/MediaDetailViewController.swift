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
    
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var trailerCollectionView: UICollectionView!
    @IBOutlet weak var similarCollectionView: UICollectionView!
    
    @IBOutlet weak var favoriteView: UIButton!
    @IBOutlet weak var watchView: UIButton!
    @IBOutlet weak var similarHeadingView: UILabel!
    
    var media: Media?
    var castMembers: [CastMember]?
    public var genreList: GenreList.GenreLookup?
    var castMemberScroller: ImageScrollerManager?
    var trailerScroller: ImageScrollerManager?
    var similarScroller: ImageScrollerManager?
    
    var reviewsContainer: [Review] = []
    
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
    
    private var color: UIColor?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let type = media?.getNoun(capitalize: true, plural: true) ?? "???"
        similarHeadingView.text = "Similar \(type)"
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backArrowTap))
        backArrowView.isUserInteractionEnabled = true
        backArrowView.addGestureRecognizer(backTap)
        
        titleView.text = media?.getTitle()
        ratingCountView.text = "\(media?.vote_count ?? 0) Ratings"
        
        let score = 100.0 * CGFloat((media?.vote_average ?? 0) / Float(10.0))
        
        if score < 40 {
            color = red
        } else if score < 60 {
            color = UIColor.orange
        } else if score < 75 {
            color = yellow
        } else {
            color = green
        }
        
        ratingRingView.maxValue = 100.0
        ratingRingView.outerRingColor = purple
        ratingRingView.innerRingColor = color!
        ratingRingView.outerRingWidth = 1.0
        ratingRingView.value = 100.0 * CGFloat((media?.vote_average ?? 0) / Float(10.0))//CGFloat(10.0 * (media?.vote_average ?? 0))
        
        ratingRingView.startProgress(to: 0, duration: 0.001) {
            self.ratingRingView.startProgress(
                to: 100.0 * CGFloat((self.media?.vote_average ?? 0) / Float(10.0)),
                duration: 1.0)
        }
        
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
        
        media?.getDetailsRecord(callback: { (media, error) in
            self.dateRuntimeView.text = media?.getSeasonEpisodeText()
        })

        media?.getReviews(page: 1) { (reviews, error) in
            let reviews = reviews?.results ?? []
            self.reviewsView.text = "\(String(reviews.count)) Reviews"
        }
        
        media?.getCast(callback: { (cast, error) in
            guard let cast = cast?.cast
                else { return }
            
            self.castMemberScroller?.setItems(items: cast)
        })
        
        media?.getTrailers(callback: { (trailers, error) in
            guard let trailers = trailers?.results
                else { return }
            
            self.trailerScroller?.setItems(items: trailers)
        })
        
        media?.getSimilar(page: 1, callback: { (similars, error) in
            guard let similars = similars
                else { return }
            
            self.similarScroller?.setItems(items: similars)
        })

        media?.getGenreList { (genreList, error) in

            guard let genreList = genreList else {
                self.genresView.text = "Genres Unknown"
                return
            }
            
            self.genresView.text = self.media?.formatGenreList(lookup: genreList)
        }
        
        media?.setupFavoriteButton(into: favoriteView)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
