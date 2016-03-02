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
    
    var attractions = [Attraction]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Attractions"
        
        // Refresh Control setting
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = ThemeColor()
        refreshControl?.tintColor = UIColor.whiteColor()
        refreshControl?.addTarget(self, action: Selector("refreshWaitTimes:"), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshWaitTimes(nil)
    }
    
    func refreshWaitTimes(sender: UIRefreshControl?) {
        if sender == nil {
            refreshControl?.beginRefreshing()
        }
        
        self.attractions.removeAll()
        Attraction.getAttractions(Park.DisneylandPark) { (success, attractions, error) -> Void in
            self.refreshControl?.endRefreshing()
            
            if success {
                self.attractions.appendContentsOf(attractions!)
                self.tableView.reloadData()
            } else {
                print(error!)
            }
        }
    }
}

/* TABLE VIEW */

extension WaitTimesViewController {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AttractionCell
        
        cell.configure(attraction: attractions[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attractions.count
    }
}