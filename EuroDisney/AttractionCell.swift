//
//  AttractionCell.swift
//  EuroDisney
//
//  Created by Thomas Durand on 02/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import UIKit

import ChameleonFramework

class AttractionCell: UITableViewCell {
    
    @IBOutlet weak var attImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configure(attraction attraction: Attraction) {
        titleLabel.text = attraction.name
        statusLabel.text = attraction.statusString
        timeLabel.text = attraction.scheduleString
        
        waitTimeLabel.text = attraction.status != .Closed ? attraction.waitTime.description + "'" : nil
        if attraction.waitTime >= 90 {
            // Red
            waitTimeLabel.textColor = FlatRed()
        } else if attraction.waitTime > 30 {
            // Orange
            waitTimeLabel.textColor = FlatOrange()
        } else {
            // Green
            waitTimeLabel.textColor = FlatGreen()
        }
        
    }
}
