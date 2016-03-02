//
//  Attraction.swift
//  EuroDisney
//
//  Created by Thomas Durand on 02/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import Foundation

/**
 Represent an attraction
 
{
 "id": "P1AA01",
 "name": "La Cabane des Robinson",
 "waitTime": 0,
 "active": false,
 "status": "Closed",
 "fastPass": false,
 "schedule": {
 "openingTime": "2016-03-02T00:00:00+01:00",
 "closingTime": "2016-03-02T23:59:00+01:00",
 "special": [
 
 ],
 "type": "Closed"
 }
}
 
*/

enum Status {
    case Closed
    case Operating
}

struct Schedule {
    var opening: NSDate
    var closing: NSDate
}

class Attraction {
    let id: String
    let name: String
    let waitTime: Int
    let active: Bool
    let status: String
    let hasFastpass: Bool
    let schedule: Schedule
}