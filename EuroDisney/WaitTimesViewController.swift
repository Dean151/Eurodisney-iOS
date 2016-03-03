//
//  WaitTimesViewController.swift
//  EuroDisney
//
//  Created by Thomas Durand on 02/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import UIKit

import ChameleonFramework
import JFMinimalNotifications

class WaitTimesViewController: UITableViewController {
    
    let reuseIdentifier = "AttractionCell"
    
    var attractions = [Attraction]()
    
    
    var expectedReturns = 0
    var nbSucceded = 0
    var nbErrors = 0
    
    var lastRefreshDate: NSDate? {
        didSet {
            if let date = lastRefreshDate {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .NoStyle
                dateFormatter.timeStyle = .ShortStyle
                
                refreshControl?.attributedTitle = NSAttributedString(string: "Last refreshed at \(dateFormatter.stringFromDate(date))", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            } else {
                refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Attractions"
        
        // Table view customization
        tableView.separatorStyle = .None
        
        // Refresh Control setting
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = ThemeColor()
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.addTarget(self, action: Selector("refreshWaitTimes:"), forControlEvents: .ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshWaitTimes(nil)
    }
    
    func refreshWaitTimes(sender: UIRefreshControl?) {
        if sender == nil {
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
                presentErrorMessage()
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
    
    func presentErrorMessage() {
        let alert = JFMinimalNotification(style: .Error, title: "An error occured", subTitle: "Do you have an internet connection ?", dismissalDelay: 1.5)
        alert.show()
    }
}

/* TABLE VIEW */

extension WaitTimesViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AttractionCell
        
        cell.configure(attraction: attractions[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attractions.count
    }
}