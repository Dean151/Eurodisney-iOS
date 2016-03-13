//
//  WaitTimesViewController.swift
//  EuroDisney
//
//  Created by Thomas Durand on 02/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import UIKit

final class WaitTimesViewController: DisneyTableViewController {
    
    let reuseIdentifier = "AttractionCell"
    
    var attractions: [Attraction] = []
    var searchResults: [Attraction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ATTRACTIONS".localized
        self.tabBarItem.title = "ATTRACTIONS".localized
    }
    
    override func refresh(sender: UIRefreshControl?) {
        super.refresh(sender)
        
        self.attractions.removeAll()
        expectedReturns = 2
        Attraction.getAttractions(Park.DisneylandPark, completion: didReceivedAttractions)
        Attraction.getAttractions(Park.WaltDisneyStudios, completion: didReceivedAttractions)
    }
    
    func didReceivedAttractions(success: Bool, attractions: [Attraction]?, error: NSError?) {
            
        if success {
            nbSucceded += 1
            
            self.attractions.appendContentsOf(attractions!)
            sortTable()
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
        }
    }
    
    override func sortTable() {
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
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        // TODO add action
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearching ? searchResults : attractions).count
    }
}

/* SEARCH */

extension WaitTimesViewController {
    
    override func filterForSearchText(text: String) {
        searchResults = attractions.filter({
            let nameMatch = $0.name.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return nameMatch != nil
        })
    }
}
