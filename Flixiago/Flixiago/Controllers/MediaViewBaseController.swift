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

    public var media: [Media] = []
    private var displayedMedia: [Media] = []
    
    private var searchBarView: UISearchBar?
    private var genreFilterButton: UIImageView?

    private var titleView: UILabel?
    private var sortByView: UISegmentedControl?
    private var sortBys: [TMDBService.SortByPair]?
    
    var currentSortBy: Int = 0
    private var page = 1
    private var loading: Int = 0
    
    private var selectedMedia = -1
    
    private var currentGenreId: Int64?
    
    private var tablePlaceholder: UIUtils.PlaceholderView?
    
    private var certificationMenuButton: UIView?
    private var certificationList: [CertificationListEntry]?
    private var certificationLookup: [String: CertificationListEntry]?
    private var certificationLimit: Int = Int.max
    
    private var certCache: [Int64: Any] = [:]
    
    public var closing: Bool = false
    public var latestRequestId: Int64 = 0
    public var visibleRows: Int = 1
    
    typealias IndicatorCleanup = () -> Void
    public var removeIndicator: IndicatorCleanup?
    
    private let cellHeight = 166
    
    private let activeFilterColor = UIColor(
        red: CGFloat(0xe8) / CGFloat(255.0),
        green: CGFloat(0xc5) / CGFloat(255.0),
        blue: CGFloat(0x46) / CGFloat(255.0),
        alpha: CGFloat(1.0))

    private let inactiveFilterColor = UIColor(
        red: CGFloat(0x4e) / 255.0,
        green: CGFloat(0x32) / 255.0,
        blue: CGFloat(0x8e) / 255.0,
        alpha: CGFloat(1.0))

    weak var table: UITableView!

    func loadMore(page: Int, query: String?,
                  genreId: Int64?, requestId: Int64) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        closing = false
        
        tablePlaceholder = UIUtils.PlaceholderView(
            parent: table,
            text: "Error getting results")
        
        table.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        visibleRows = max(1, Int(table.frame.height) / cellHeight)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tablePlaceholder?.handleLayoutSubViews()
    }
    
    func makeLoadMoreCompletionHandler(
        page: Int,
        query: String?,
        genreId: Int64?,
        requestId: Int64) -> (Bool) -> Void {
        
        return { done in
            self.loading -= 1
            
            if !done {
                self.loadMoreIfNeeded(
                    page: page,
                    query: query,
                    genreId: genreId,
                    requestId: requestId)
            } else {
                print("done items")
            }
        }
    }
    
    func removeLoadMoreIndicator(recreate: Bool) {
        if removeIndicator != nil {
            removeIndicator!()
            removeIndicator = nil
        }
        
        if recreate {
            removeIndicator = UIUtils.createIndicator(parent: self)
        }
    }

    public func loadMoreIfNeeded(
        page: Int, query: String?,
        genreId: Int64?, requestId: Int64) {
        
        self.table.layoutIfNeeded()
        if !closing &&
            self.table.contentSize.height < self.table.frame.height {
            self.loadMore(page: page + 1,
                          query: query,
                          genreId: genreId,
                          requestId: requestId)
        }
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
        table.rowHeight = CGFloat(cellHeight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        closing = true
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
    
    func newRequestId() -> Int64 {
        latestRequestId += 1
        return latestRequestId
    }
    
    func initLoad() {
        reset()
        let requestId = newRequestId()
        loadMore(page: page,
                 query: currentQuery(),
                 genreId: currentGenreId,
                 requestId: requestId)
    }
    
    func initCertificationMenu(
        menuButton: UIView,
        callback: @escaping () -> Void) {
        
        self.certificationMenuButton = menuButton

        getCertificationList(
        forCountry: TMDBService.COUNTRY) { (list, error) in
            let allEntry = CertificationListEntry(JSON: [
                "certification": "All",
                "meaning": "",
                "order": Int.max
            ])
            
            self.certificationList = list
            self.certificationList?.insert(allEntry!, at: 0)

            self.certificationLookup = [:]
            for certification in list ?? [] {
                guard let letter = certification.certification
                    else { continue }
                
                self.certificationLookup![letter] = certification
            }
            
            let gestureTab = UITapGestureRecognizer(
                target: self,
                action: #selector(self.certificationButtonClicked))
            menuButton.addGestureRecognizer(gestureTab)
            menuButton.isUserInteractionEnabled = true
            
            callback()
        }
    }
    
    @objc func certificationButtonClicked(sender: UITapGestureRecognizer) {
        let sheet = UIAlertController(
            title: "Choose a certification limit",
            message: nil,
            preferredStyle: .actionSheet)
        
        var actions: [UIAlertAction] = []
        
        guard let certs = certificationList
            else { return }
        
        let sortedCerts = certs.sorted { (lhs, rhs) -> Bool in
            if lhs.order == Int.max {
                return true
            }
            if rhs.order == Int.max {
                return false
            }
            return (lhs.order ?? 0) < (rhs.order ?? 0)
        }

        let certificationButtonHandler: (UIAlertAction) -> Void
        certificationButtonHandler = { action in
            let index = actions.firstIndex { candidate in
                return candidate == action
            }
            
            guard let validIndex = index
                else { return }
            
            self.changeCertificationFilter(
                entry: sortedCerts[validIndex])
        }

        for cert in certs {
            let action = UIAlertAction(
                title: cert.certification,
                style: .default,
                handler: certificationButtonHandler)
    
            actions.append(action)
            sheet.addAction(action)
        }
        
        let cancel = UIAlertAction(
            title: "Cancel",
            style: .cancel) { (action) in
                sheet.dismiss(animated: true, completion: nil)
        }
        sheet.addAction(cancel)
        
        UIUtils.presentPopover(
            sheet,
            controller: self,
            view: sender.view)
        
        present(sheet, animated: true, completion: nil)
    }
    
    typealias CertCallback = (String?, Error?) -> Void
    
    func getCachedCert(
        media: Media,
        callback: @escaping CertCallback) {
        
        let entry = certCache[media.id]
        
        if var pendingList = entry as? [CertCallback] {
            // It is an array of callbacks, add to the pending list
            pendingList.append(callback)
            return
        } else if let error = entry as? Error {
            callback(nil, error)
        } else if let certification = entry as? String {
            // It is fully resolved to a certification
            callback(certification, nil)
            return
        }
        
        // Create pending list
        certCache[media.id] = [callback]
        
        media.getCertification { (certification, error) in
            let callbacks = self.certCache[media.id]
                as? [CertCallback] ?? []
            
            self.certCache[media.id] = error == nil
                ? certification
                : error

            for pendingCallback in callbacks {
                pendingCallback(certification, error)
            }
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

    @objc func filterButtonClicked(sender: UITapGestureRecognizer) {
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
            
            let all = UIAlertAction(
                title: "All",
                style: .default) { (action) in
                    self.clearGenreFilter()
                    self.initLoad()
                    sheet.dismiss(animated: true, completion: nil)
            }
            sheet.addAction(all)

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
            
            UIUtils.presentPopover(
                sheet,
                controller: self,
                view: sender.view)
            
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
        
        sortByView?.setNeedsLayout()
    }
    
    func clearGenreFilter() {
        currentGenreId = nil
        
        // #e8c546
        // #4e328e
        
        genreFilterButton?.tintColor = inactiveFilterColor
    }
    
    func clearQuery() {
        searchBarView?.text = nil
    }
    
    typealias MediaCertOrder = (media: Media, certOrder: Int?)
    
    func changeCertificationFilter(entry: CertificationListEntry) {
        guard let order = entry.order
            else { return }

        certificationLimit = order
        certificationMenuButton?.tintColor = order < 5
            ? activeFilterColor
            : inactiveFilterColor
        
        updateTitle()

        refreshCertificationFilter()
    }
    
    func refreshCertificationFilter() {
        let removeIndicator = UIUtils.createIndicator(parent: self)
        
        var itemsWithCert: [MediaCertOrder] = []
        
        let pending = media.count
        var completed = 0
        
        let completion = {
            self.displayedMedia.removeAll()
            
            for item in itemsWithCert {
                if self.shouldDisplay(
                    order: item.certOrder ?? -1,
                    genre_ids: item.media.getGenreIds()) {
                    
                    self.displayedMedia.append(item.media)
                }
            }
            self.table.reloadData()
            removeIndicator()
        }
        
        displayedMedia.removeAll()
        for (index, medium) in media.enumerated() {
            itemsWithCert.append((
                media: medium,
                certOrder: nil
            ))
            getCachedCert(media: medium) { (letter, error) in
                if let letter = letter {
                    let certEntry = self.certificationLookup![letter]
                    itemsWithCert[index].certOrder = certEntry?.order
                }
                completed += 1
                if completed == pending {
                    completion()
                }
            }
        }
        
        if pending == 0 {
            completion()
        }
    }

    func changeGenreFilter(pair: GenrePair) {
        // Clear the other two search filters
        //clearQuery()
        //clearSortBy()
        
        genreFilterButton?.tintColor = activeFilterColor
        //titleView?.text = pair.name

        currentGenreId = pair.id
        updateTitle()
        let requestId = reset()
        loadMore(page: 1,
                 query: currentQuery(),
                 genreId: currentGenreId,
                 requestId: requestId)
    }
    
    func titleFromSortBy(pair: TMDBService.SortByPair) -> String {
        return pair.text
    }
    
    func updateTitle() {
        var title: [String] = []
        
        guard let sortByInfo = sortBys?[currentSortBy]
            else { return }
        
        if currentQuery() != nil {
            title.append("Search")
        } else {
            let sortText = titleFromSortBy(
                pair: sortByInfo)
            
            title.append(sortText)
        }
        
        let mediaType = getMediaType()
        
        let genreCallback = { (list: TMDBService.GenreLookup?, error: Error?) in
            guard let list = list
                else { return }
            
            if let currentGenreId = self.currentGenreId {
                let genreText = Media.formatGenreList(
                    genreIds: [currentGenreId],
                    lookup: list)
            
                title.append(genreText)
            }
            
            TMDBService.getCertificationTable(
                type: mediaType,
                forCountry: TMDBService.COUNTRY) { (list, error) in
                    guard let list = list
                        else { return }
                    
                    for entry in list {
                        if entry.order == self.certificationLimit {
                            if self.certificationLimit != Int.max {
                                title.append(entry.certification ?? "???")
                            }
                            break
                        }
                    }
                    
                    let titleText = title.joined(separator: " • ")
                    self.titleView?.text = titleText
            }
        }
        
        switch getMediaType() {
        case "tv":
            TMDBService.getShowGenres(callback: genreCallback)
            break
            
        case "movie":
            TMDBService.getMovieGenres(callback: genreCallback)
            break
            
        default:
            fatalError("Unhandled media type")
            
        }
    }
    
    func changeSortBy(to index: Int) {
        // Clear the other search filters
        clearQuery()
        
        if currentSortBy != index {
            currentSortBy = index
            updateTitle()
            let requestId = reset()
            let query = currentQuery()
            loadMore(page: 1,
                     query: query,
                     genreId: currentGenreId,
                     requestId: requestId)
        }
    }
    
    // MARK: - Data Results Processing
    func append(media: [Media], error: Error?,
                callback: @escaping () -> Void) {
        print("Received \(media.count) items \(Int64(Date().timeIntervalSince1970))")
        self.media.append(contentsOf: media)
        filterAppendedMedia(addedMedia: media) {
            self.removeLoadMoreIndicator(recreate: false)
            callback()
        }
        
        tablePlaceholder?.toggle(show: error != nil)
    }
    
    func shouldDisplay(order: Int, genre_ids: [Int64]) -> Bool {
        if let currentGenreId = currentGenreId {
            if genre_ids.firstIndex(of: currentGenreId) == nil {
                return false
            }
        }
        
        if self.certificationLimit < 5 {
            return order > 0 && order <= self.certificationLimit
        }
        
        return true
    }
    
    func filterAppendedMedia(addedMedia media: [Media],
                             callback: @escaping () -> Void) {
        var results: [String?] = []
        
        let pending = media.count
        var completed = 0
        
        let completion = {
            var anyChanges = false
            
            for (index, letter) in results.enumerated() {
                guard let lookup = self.certificationLookup,
                    let letter = letter,
                    let entry = lookup[letter],
                    let order = entry.order
                    else { continue }
                
                let ids = media[index].getGenreIds()
                
                if self.shouldDisplay(
                    order: order,
                    genre_ids: ids) {
                    
                    self.displayedMedia.append(media[index])
                    anyChanges = true
                }
            }
            
            if anyChanges {
                self.table.reloadData()
            }
            
            callback()
        }
        
        for (index, medium) in media.enumerated() {
            // Append vacant slot
            results.append(nil)
            
            getCachedCert(
                media: medium) { rating, error in
                    // Populate slot
                    results[index] = rating
                    
                    completed += 1
                    if completed == pending {
                        completion()
                    }
            }
        }
        
        if pending == 0 {
            completion()
        }
    }
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return displayedMedia.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
            table.dequeueReusableCell(
                withIdentifier: "media_cell") as? MediaTableViewCell
            else {return UITableViewCell()}
        
            let target = displayedMedia[indexPath.row]
            cell.setupMediaCell(with: target)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }
    
    func currentQuery() -> String? {
        return (searchBarView?.text?.isEmpty ?? true)
            ? nil
            : searchBarView?.text
    }
    
    func tableView(_ tableView: UITableView,
                   prefetchRowsAt indexPaths: [IndexPath]) {
        var wtf = ""
        for ip in indexPaths {
            wtf += "\(ip.row) "
        }
        print(wtf)
        
        let needed = indexPaths.contains { item in
            return item.row + visibleRows >= displayedMedia.count
        }
        
        for path in indexPaths {
            print("The path is \(path)")
        }
        
        if !needed {
            print("prefetch not needed")
            return
        } else {
            print("prefetch needed")
        }
        
        if loading == 0 {
            loading += 1
            page += 1
            loadMore(page: page,
                     query: currentQuery(),
                     genreId: currentGenreId,
                     requestId: latestRequestId)
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
                destination.media = displayedMedia[selectedMedia]
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
    
    func getMediaType() -> String {
        fatalError("Don't call super")
    }
    
    public func getCertificationList(
        forCountry countryCode: String,
        callback: @escaping ([CertificationListEntry]?, Error?) -> Void) {
        
        TMDBService.getCertificationTable(
            type: getMediaType(),
            forCountry: TMDBService.COUNTRY,
            callback: callback)
    }
    
    func reset() -> Int64 {
        media.removeAll()
        displayedMedia.removeAll()
        table.reloadData()
        updateTitle()
        tablePlaceholder?.toggle(show: false)
        
        removeLoadMoreIndicator(recreate: false)
        
        page = 1
        
        return newRequestId()
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            changeSearchText()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        changeSearchText()
    }
    
    func changeSearchText() {
        let query = currentQuery()
        
        if query != nil {
            clearSortBy()
        }
        
        let requestId = reset()
        
        loadMore(page: 1,
                 query: query,
                 genreId: currentGenreId,
                 requestId: requestId)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        changeSearchText()
    }
}
