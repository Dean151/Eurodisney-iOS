//
//  Attraction.swift
//  EuroDisney
//
//  Created by Thomas Durand on 02/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

enum Park {
    case DisneylandPark
    case WaltDisneyStudios
    
    var parkId: String {
        switch self {
        case .DisneylandPark:
            return "dlp"
        case .WaltDisneyStudios:
            return "wds"
        }
    }
}

enum Status: String {
    case Closed = "Closed"
    case Down = "Down"
    case Operating = "Operating"
}

struct Schedule {
    var opening: NSDate
    var closing: NSDate
}

/**
 Represent an attraction
 */
class Attraction {
    let id: String
    let name: String
    let waitTime: Int
    let active: Bool
    let status: Status
    let areFastPassAvailable: Bool
    let schedule: Schedule
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.waitTime = json["waitTime"].intValue
        self.active = json["active"].boolValue
        self.status = Status(rawValue: json["status"].stringValue)!
        self.areFastPassAvailable = json["fastPass"].boolValue
        self.schedule = Schedule(
            opening: NSDate(stringDate: json["schedule"].dictionaryValue["openingTime"]!.stringValue),
            closing: NSDate(stringDate: json["schedule"].dictionaryValue["closingTime"]!.stringValue)
        )
    }
}

extension Attraction {
    static func getAttractions(park: Park, completion: (success: Bool, attractions:[Attraction]?, error: NSError?)->Void) {
        Alamofire.request(.GET, "http://api.cafelembas.com/\(park.parkId)-waittimes.json").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    var attractions = [Attraction]()
                    
                    for attrJson in json.arrayValue {
                        attractions.append(Attraction(json: attrJson))
                    }
                    
                    completion(success: true, attractions: attractions, error: nil)
                }
            case .Failure(let error):
                completion(success: false, attractions: nil, error: error)
            }
        }
    }
}

extension NSDate {
    convenience init(stringDate: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        if let d = dateFormatter.dateFromString(stringDate) {
            self.init(timeInterval: 0, sinceDate: d)
        } else {
            self.init()
        }
    }
}