//
//  DisneyTableViewController.swift
//  EuroDisney
//
//  Created by Thomas Durand on 06/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import UIKit

class DisneyTableViewController: UITableViewController {
    
    var searchController: UISearchController!
    
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
        
        // Table view customization
        tableView.separatorStyle = .None
        
        // Refresh Control setting
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = ThemeColor()
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.attributedTitle = NSAttributedString(string: "PULL_TO_REFRESH".localized, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        refreshControl?.addTarget(self, action: #selector(DisneyTableViewController.refresh(_:)), forControlEvents: .ValueChanged)
        
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
        super.viewDidAppear(animated)
        
        if lastRefreshDate == nil || lastRefreshDate?.compare(NSDate(timeIntervalSinceNow: NSTimeInterval(-5*60))) == .OrderedAscending  {
            refresh(nil)
        }
    }
    
    func refresh(sender: UIRefreshControl?) {
        nbSucceded = 0
        nbErrors = 0
        
        if sender == nil {
            self.tableView.setContentOffset(CGPointMake(0, -1), animated: false)
            if let height = self.refreshControl?.frame.size.height {
                self.tableView.setContentOffset(CGPointMake(0, -height), animated: true)
            } else {
                self.tableView.setContentOffset(CGPointMake(0, 0), animated: true)
            }
            
            refreshControl?.beginRefreshing()
        }
    }
    
    func sortTable() {}
}

/* TABLE VIEW */

extension DisneyTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
}

/* SEARCH */

extension DisneyTableViewController: UISearchResultsUpdating {
    
    var isSearching: Bool {
        guard let searchText = searchController.searchBar.text else { return false }
        return searchController.active && !searchText.isEmpty
    }
    
    func filterForSearchText(text: String) {
        preconditionFailure("This must be overridden")
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterForSearchText(searchText)
        tableView.reloadData()
    }
}