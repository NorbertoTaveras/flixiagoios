//
//  ShowsViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit

class ShowsViewController: MediaViewBaseController {

    @IBOutlet weak var genresMenuView: UIImageView!
    @IBOutlet weak var moviesTable: UITableView!
    @IBOutlet weak var sortBySegment: UISegmentedControl!
    @IBOutlet weak var searchBarView: UISearchBar!
    @IBOutlet weak var sortByView: UILabel!
    @IBOutlet weak var certificationMenuView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSortBySegment(sortBySegment: sortBySegment,
                          fromSortBys: TMDBService.showSortBys,
                          titleView: sortByView)
        
        initTable(table: moviesTable)
        initSearch(searchBar: searchBarView)
        initGenreFilter(genreFilterButton: genresMenuView)
        changeSortBy(to: 0)
        initCertificationMenu(menuButton: certificationMenuView) {
            self.initLoad()
        }
    }
    
    override func loadMore(
        page: Int,
        query: String?,
        genreId: Int64?,
        requestId: Int64) {
        
        sortBySegment.isEnabled = (query == nil)
        
        let completion: (Bool) -> Void
        completion = makeLoadMoreCompletionHandler(
            page: page,
            query: query,
            genreId: genreId,
            requestId: requestId)

        removeLoadMoreIndicator(recreate: true)
        
        if let query = query {
            TMDBService.searchShows(
                query: query,
                page: page) { (shows, error) in
                    print("Got some results for query \(query)")
                    
                    guard requestId == self.latestRequestId
                        else { print("cancel"); completion(true); return }
                    
                    self.append(
                        media: shows?.results ?? [],
                        error: error) {
                            let isDone = shows?.results.count == 0 ||
                                shows?.total_pages == shows?.page
                            completion(isDone)
                    }
            }
        } else if let genreId = genreId {
            TMDBService.searchShows(
                genreId: genreId,
                page: page) { (shows, error) in
                    guard requestId == self.latestRequestId
                        else { print("cancel"); completion(true); return }
                    
                    self.append(
                        media: shows?.results ?? [],
                        error: error) {
                            let isDone = shows?.results.count == 0 ||
                                shows?.total_pages == shows?.page
                            completion(isDone)
                    }
            }
        } else {
            TMDBService.getShows(
                sortBy: TMDBService.showSortBys[currentSortBy].sortBy,
                page: page,
                language: TMDBService.LANGUAGE) { (shows, error) in
                    guard requestId == self.latestRequestId
                        else { print("cancel"); completion(true); return }
                    
                    self.append(
                        media: shows?.results ?? [],
                        error: error) {
                            let isDone = shows?.results.count == 0 ||
                                shows?.total_pages == shows?.page
                            completion(isDone)
                    }
            }
        }
    }

    @IBAction func sortByViewChanged(_ sender: UISegmentedControl) {
        changeSortBy(to: sender.selectedSegmentIndex)
    }
    
    override func titleFromSortBy(pair: TMDBService.SortByPair) -> String {
        switch pair.sortBy {
        case TMDBService.POPULAR:
            return "Popular Shows"
        case TMDBService.TOP_RATED:
            return "Top Rated Shows"
        default:
            return super.titleFromSortBy(pair: pair)
        }
    }
    
    override func getGenres(
        callback: @escaping (TMDBService.GenreLookup?, Error?) -> Void) {
        
        TMDBService.getShowGenres(callback: callback)
    }
    
    override func getMediaType() -> String {
        return "tv"
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
