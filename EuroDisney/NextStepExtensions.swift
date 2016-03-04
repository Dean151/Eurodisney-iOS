//
//  NextStepExtensions.swift
//  EuroDisney
//
//  Created by Thomas Durand on 04/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension NSDate {
    convenience init(stringDate: String, format: String? = nil) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format ?? "yyyy-MM-dd'T'HH:mm:ssZZZ"
        if let d = dateFormatter.dateFromString(stringDate) {
            self.init(timeInterval: 0, sinceDate: d)
        } else {
            self.init()
        }
    }
}
