//
//  AttractionCell.swift
//  EuroDisney
//
//  Created by Thomas Durand on 02/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import UIKit

class AttractionCell: UITableViewCell {
    
    @IBOutlet weak var attImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var waitTimeLabel: UILabel!
    
    func configure(attraction attraction: Attraction) {
        titleLabel.text = attraction.name
        timeLabel.text = nil
        waitTimeLabel.text = attraction.waitTime.description
    }
}
