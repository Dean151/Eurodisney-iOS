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
    @IBOutlet weak var parkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    
    func configure(attraction attraction: Attraction) {
        
        self.subviews.forEach { $0.alpha = attraction.active ? 1.0 : 0.4 }
        
        titleLabel.text = attraction.name
        statusLabel.text = attraction.statusString
        waitTimeLabel.text = attraction.status != .Closed ? attraction.waitTime.description + "'" : nil
        
        parkImageView.image = attraction.park.image
        parkImageView.tintColor = ThemeColor()
        
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
        
        // Downloading the attraction image
        attImageView.image = nil
        if let url = attraction.imageUrl {
            attImageView.setImageWithURL(url)
        }
        
    }
}
