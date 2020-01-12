//
//  MoviesViewController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit

class MoviesViewController: MediaViewBaseController {
    
    @IBOutlet weak var moviesTable: UITableView!
    @IBOutlet weak var sortByView: UILabel!
    @IBOutlet weak var sortBySegment: UISegmentedControl!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var genreMenuView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initSortBySegment(
            sortBySegment: sortBySegment,
            fromSortBys: TMDBService.movieSortBys,
            titleView: sortByView)
        
        initTable(table: moviesTable)
        initSearch(searchBar: searchView)
        initGenreFilter(genreFilterButton: genreMenuView)
        
        changeSortBy(to: 0)
        
    }
    
    override func loadMore(page: Int, query: String?, genreId: Int64?) {
        if let genreId = genreId {
            TMDBService.searchMovies(
                genreId: genreId,
                page: page) { (movies, error) in
                    self.append(media: movies?.results ?? [],
                                error: error)
            }
        } else if let query = query {
            TMDBService.searchMovies(
                query: query,
                page: page) { (movies, error) in
                    self.append(media: movies?.results ?? [],
                                error: error)
            }
        } else {
            TMDBService.getMovies(
                sortBy: TMDBService.movieSortBys[currentSortBy].sortBy,
                page: page,
                language: TMDBService.LANGUAGE) { (movies, error) in
                    self.append(media: movies?.results ?? [],
                                error: error)
            }
        }
    }
    
    @IBAction func sortByViewChanged(_ sender: UISegmentedControl) {
        changeSortBy(to: sender.selectedSegmentIndex)
    }
    
    override func titleFromSortBy(
        pair: TMDBService.SortByPair) -> String {
        
        switch pair.sortBy {
        case TMDBService.POPULAR:
            return "Popular Movies"
            
        case TMDBService.TOP_RATED:
            return "Top Rated Movies"
            
        case TMDBService.UPCOMING:
            return "Upcoming Movies"
            
        default:
            return super.titleFromSortBy(pair: pair)
            
        }
    }
    
    override func getGenres(
        callback: @escaping (TMDBService.GenreLookup?, Error?) -> Void) {
        
        TMDBService.getMovieGenres(callback: callback)
    }

}
