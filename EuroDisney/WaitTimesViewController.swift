//
//  WaitTimesViewController.swift
//  EuroDisney
//
//  Created by Thomas Durand on 02/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import UIKit

import ChameleonFramework

class WaitTimesViewController: UITableViewController {
    
    let reuseIdentifier = "AttractionCell"
    
    var attractions: [Attraction] = []
    
    var searchController: UISearchController!
    var searchResults: [Attraction] = []
    
    var expectedReturns = 0
    var nbSucceded = 0
    var nbErrors = 0
    
    var lastRefreshDate: NSDate? {
        didSet {
            if let date = lastRefreshDate {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .NoStyle
                dateFormatter.timeStyle = .ShortStyle
                
                refreshControl?.attributedTitle = NSAttributedString(string: "LAST_REFRESHED_AT".localized + " " + dateFormatter.stringFromDate(date), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ATTRACTIONS".localized
        
        // Table view customization
        tableView.separatorStyle = .None
        
        // Refresh Control setting
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = ThemeColor()
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.attributedTitle = NSAttributedString(string: "PULL_TO_REFRESH".localized, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        refreshControl?.addTarget(self, action: Selector("refreshWaitTimes:"), forControlEvents: .ValueChanged)
        
        // Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = ThemeColor()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.sizeToFit()
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshWaitTimes(nil)
    }
    
    func refreshWaitTimes(sender: UIRefreshControl?) {
        if sender == nil {
            self.tableView.setContentOffset(CGPointMake(0, -1), animated: false)
            if let height = self.refreshControl?.frame.size.height {
                self.tableView.setContentOffset(CGPointMake(0, -height), animated: true)
            } else {
                self.tableView.setContentOffset(CGPointMake(0, 0), animated: true)
            }
            
            refreshControl?.beginRefreshing()
        }
        
        self.attractions.removeAll()
        expectedReturns = 2
        Attraction.getAttractions(Park.DisneylandPark, completion: didReceivedAttractions)
        Attraction.getAttractions(Park.WaltDisneyStudios, completion: didReceivedAttractions)
    }
    
    func didReceivedAttractions(success: Bool, attractions: [Attraction]?, error: NSError?) {
            
        if success {
            nbSucceded += 1
            
            self.attractions.appendContentsOf(attractions!)
            sortAttractions()
            tableView.reloadData()
        } else {
            nbErrors += 1
        }
        
        if expectedReturns == nbSucceded + nbErrors  {
            refreshControl?.endRefreshing()
            lastRefreshDate = NSDate()
            
            if nbErrors > 0 {
                // Do something
            }
            
            nbSucceded = 0
            nbErrors = 0
        }
    }
    
    func sortAttractions() {
        self.attractions.sortInPlace(sortByTimeAndStatus)
    }
    
    func sortByName(a1: Attraction, a2: Attraction) -> Bool {
        return a1.name.lowercaseString < a2.name.lowercaseString
    }
    
    func sortByTimeAndStatus(a1: Attraction, a2: Attraction) -> Bool {
        
        if a1.isClosedToday != a2.isClosedToday {
            return !a1.isClosedToday
        }
        
        if a1.status != a2.status {
            return a1.status.sortValue > a2.status.sortValue
        }
        
        if a1.waitTime != a2.waitTime {
            return a1.waitTime < a2.waitTime
        }
            
        return sortByName(a1, a2: a2)
    }
}

/* TABLE VIEW */

extension WaitTimesViewController {
    
    func attractionAtIndexPath(indexPath: NSIndexPath) -> Attraction? {
        
        let array = isSearching ? searchResults : attractions
        
        guard indexPath.row >= 0 && indexPath.row < array.count else {
            return nil
        }
        
        return array[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AttractionCell
        
        if let attraction = attractionAtIndexPath(indexPath) {
            cell.configure(attraction: attraction)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearching ? searchResults : attractions).count
    }
}

/* SEARCH */

extension WaitTimesViewController: UISearchResultsUpdating {
    
    var isSearching: Bool {
        guard let searchText = searchController.searchBar.text else { return false }
        return searchController.active && !searchText.isEmpty
    }
    
    func filterForSearchText(text: String) {
        searchResults = attractions.filter({
            let nameMatch = $0.name.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return nameMatch != nil
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterForSearchText(searchText)
        tableView.reloadData()
    }
}
