//
//  MediaViewBaseController.swift
//  Flixiago
//
//  Created by Norberto Taveras on 12/16/19.
//  Copyright © 2019 Norberto Taveras. All rights reserved.
//

import UIKit

import UIKit

class MediaViewBaseController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UITableViewDataSourcePrefetching,
    UISearchBarDelegate {

    typealias GenrePair = (name: String, id: Int64)

    private var media: [Media] = []
    private var searchBarView: UISearchBar?
    private var genreFilterButton: UIImageView?

    private var titleView: UILabel?
    private var sortByView: UISegmentedControl?
    private var sortBys: [TMDBService.SortByPair]?
    
    var currentSortBy: Int = 0
    private var page = 1
    private var loading = false
    
    private var selectedMedia = -1
    
    private var currentGenreId: Int64?
    
    private var tablePlaceholder: UIUtils.PlaceholderView?
    
    weak var table: UITableView!

    func loadMore(page: Int, query: String?, genreId: Int64?) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tablePlaceholder = UIUtils.PlaceholderView(
            parent: table,
            text: "Error getting results")

        table.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tablePlaceholder?.handleLayoutSubViews()
    }
    
    func initSearch(searchBar: UISearchBar) {
        self.searchBarView = searchBar
        searchBar.delegate = self
    }
    
    func initTable(table: UITableView) {
        self.table = table
        table.delegate = self
        table.dataSource = self
        table.prefetchDataSource = self

        loadMore(page: page, query: nil, genreId: currentGenreId)
    }
    
    func initSortBySegment(sortBySegment: UISegmentedControl,
                           fromSortBys: [TMDBService.SortByPair],
                           titleView: UILabel) {
        self.sortByView = sortBySegment
        self.sortBys = fromSortBys
        self.titleView = titleView
        self.sortByView?.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.white],
            for: .selected)
        for (index,info) in fromSortBys.enumerated() {
            sortBySegment.setTitle(info.text, forSegmentAt: index)
        }
    }
    
    func initGenreFilter(genreFilterButton: UIImageView) {
        self.genreFilterButton = genreFilterButton
        
        let gestureTap = UITapGestureRecognizer(
            target: self,
            action: #selector(filterButtonClicked))
        genreFilterButton.addGestureRecognizer(gestureTap)
        genreFilterButton.isUserInteractionEnabled = true
    }

    @objc func filterButtonClicked(sender: UIView) {
        let sheet = UIAlertController(
            title: "Choose a genre",
            message: nil,
            preferredStyle: .actionSheet)
        
        getGenres { (genreLookup, error) in
            guard let genreLookup = genreLookup
                else {
                    UIUtils.modalDialog(
                        parent: self,
                        title: "Error",
                        message: "Genre list download failed")
                    return
            }
            
            var sortedItems: [GenrePair] = []
            var actions: [UIAlertAction] = []
            
            for entry in genreLookup {
                sortedItems.append((entry.value, entry.key))
            }
            
            sortedItems.sort { (a, b) in
                return a.name < b.name
            }
            
            let genreButtonHandler: (UIAlertAction) -> Void
            genreButtonHandler = { action in
                let index = actions.firstIndex { candidate in
                    return candidate == action
                }
                
                guard let validIndex = index
                    else { return }
                
                self.changeGenreFilter(
                    pair: sortedItems[validIndex])
            }
            
            for item in sortedItems {
                let action = UIAlertAction(
                    title: item.name,
                    style: .default,
                    handler: genreButtonHandler)
                actions.append(action)
                sheet.addAction(action)
            }
            
            let cancel = UIAlertAction(
                title: "Cancel",
                style: .cancel) { (action) in
                    sheet.dismiss(animated: true, completion: nil)
            }
            sheet.addAction(cancel)
            
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    func clearSortBy() {
        //sortByView?.isMomentary = true
        
        // do a song and dance to get events when they click
        // on the segmented control that was selected before
        // setting it to .noSegment
        guard let oldSel = sortByView?.selectedSegmentIndex,
            oldSel != UISegmentedControl.noSegment
            else { return }
        
        sortByView?.selectedSegmentIndex = UISegmentedControl.noSegment
        
//        let oldTitle = sortByView?.titleForSegment(
//            at: oldSel)
//        
//        sortByView?.removeSegment(
//            at: oldSel,
//            animated: false)
//        
//        sortByView?.insertSegment(
//            withTitle: oldTitle,
//            at: oldSel,
//            animated: false)
        
        sortByView?.setNeedsLayout()
    }
    
    func clearGenreFilter() {
        currentGenreId = nil
        
        // #e8c546
        // #4e328e
        let color = UIColor(
            red: CGFloat(0x4e) / 255.0,
            green: CGFloat(0x32) / 255.0,
            blue: CGFloat(0x8e) / 255.0,
            alpha: CGFloat(1.0))
        
        genreFilterButton?.tintColor = color
    }
    
    func clearQuery() {
        searchBarView?.text = nil
    }

    func changeGenreFilter(pair: GenrePair) {
        // Clear the other two search filters
        clearQuery()
        clearSortBy()
        
        let color = UIColor(
            red: CGFloat(0xe8) / CGFloat(255.0),
            green: CGFloat(0xc5) / CGFloat(255.0),
            blue: CGFloat(0x46) / CGFloat(255.0),
            alpha: CGFloat(1.0))
        
        genreFilterButton?.tintColor = color
        
        titleView?.text = pair.name

        currentGenreId = pair.id
        reset()
        loadMore(page: 1, query: nil, genreId: currentGenreId)
    }
    
    func titleFromSortBy(pair: TMDBService.SortByPair) -> String {
        return pair.text
    }
    
    func changeSortBy(to index: Int) {
        guard let sortBys = sortBys
            else { return }
        
        // Clear the other search filters
        clearQuery()
        clearGenreFilter()
        
        let sortByInfo = sortBys[index]
        
        titleView?.text = titleFromSortBy(pair: sortByInfo)
        
        if currentSortBy != index {
            currentSortBy = index
            reset()
            let query = (searchBarView?.text?.isEmpty ?? false)
                ? nil
                : searchBarView?.text
            loadMore(page: 1, query: query, genreId: currentGenreId)
        }
    }
    
    // MARK: - Data Results Processing
    func append(media: [Media], error: Error?) {
        self.media.append(contentsOf: media)
        self.table.reloadData()
        
        tablePlaceholder?.toggle(show: media.isEmpty)
    }
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return media.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
            table.dequeueReusableCell(
                withIdentifier: "media_cell") as? MediaTableViewCell
            else {return UITableViewCell()}
        
        let target = media[indexPath.row]
        cell.setupMediaCell(media: target)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 166
    }
    
    func currentQuery() -> String? {
        return (searchBarView?.text?.isEmpty ?? true)
            ? nil
            : searchBarView?.text
    }
    
    func tableView(_ tableView: UITableView,
                   prefetchRowsAt indexPaths: [IndexPath]) {
        if !loading {
            loading = true
            page += 1
            loadMore(page: page, query: currentQuery(), genreId: currentGenreId)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMedia = indexPath.row
        performSegue(withIdentifier: "detailView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailView":
            if let destination = segue.destination as? MedialDetailViewController {
                destination.media = media[selectedMedia]
                selectedMedia = -1
            }
            break
            
        default:
            print("Unexpected segue identifier: \(segue.identifier)")
            break
            
        }
    }
    
    public func getGenres(
        callback: @escaping (TMDBService.GenreLookup?, Error?) -> Void) {
        
        fatalError("Don't call super")
    }
    
    func reset() {
        media.removeAll()
        table.reloadData()
        tablePlaceholder?.toggle(show: false)
        page = 1
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if (searchText == "") {
            updateSearch()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        updateSearch()
    }
    
    func updateSearch() {
        let query = currentQuery()
        
        if query != nil && !query!.isEmpty {
            clearSortBy()
            clearGenreFilter()
            titleView?.text = "Search"
        }
        
        reset()
        
        loadMore(page: 1, query: currentQuery(), genreId: currentGenreId)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        updateSearch()
    }
}
