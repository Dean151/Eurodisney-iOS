//
//  Attraction.swift
//  EuroDisney
//
//  Created by Thomas Durand on 02/03/2016.
//  Copyright © 2016 Thomas Durand. All rights reserved.
//

import Foundation

import AFNetworking
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
    
    var image: UIImage? {
        return UIImage(named: self.parkId)
    }
}

enum Status: String {
    case Closed = "Closed"
    case Down = "Down"
    case Operating = "Operating"
    
    var sortValue: Int {
        switch self {
        case .Closed:
            return 0
        case .Down:
            return 1
        case .Operating:
            return 2
        }
    }
}

struct Schedule {
    var opening: NSDate
    var closing: NSDate
}

/**
 Represent an attraction
 */
class Attraction: Equatable, CustomStringConvertible {
    let id: String
    let name: String
    let waitTime: Int
    let active: Bool
    let status: Status
    let areFastPassAvailable: Bool
    let schedule: Schedule
    let park: Park
    
    init(json: JSON, park: Park) {
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
        self.park = park
    }
    
    var isClosedToday: Bool {
        guard status == .Closed else {
            return false
        }
        
        return schedule.closing.timeIntervalSinceDate(schedule.opening) == ((60*60*24)-60)
    }
    
    var scheduleString: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(schedule.opening) + " → " + dateFormatter.stringFromDate(schedule.closing)
    }
    
    var statusString: String? {
        
        if isClosedToday {
            return "Closed today"
        }
        
        var string = scheduleString
        
        if status == .Operating && areFastPassAvailable {
            string += " - FastPass available"
        }
        
        if status == .Down {
            string += " - Down"
        }
        
        if status == .Closed {
            string += " - Closed"
        }
        
        return string
    }
    
    var description: String {
        var string = "EuroDisney.Attraction :\n"
        string +=   "   id:         \(id)\n"
        string +=   "   name:       \(name)\n"
        string +=   "   waittime:   \(waitTime)\n"
        string +=   "   active:     \(active)\n"
        string +=   "   status:     \(status)\n"
        string +=   "   fastpass:   \(areFastPassAvailable)\n"
        string +=   "   opening:    \(schedule.opening)\n"
        string +=   "   closing:    \(schedule.closing)\n"
        
        return string
    }
}

func ==(lhs: Attraction, rhs: Attraction) -> Bool {
    return lhs.id == rhs.id
}

/**
    API EXTENSIONS
*/

extension Attraction {
    static func getAttractions(park: Park, completion: (success: Bool, attractions:[Attraction]?, error: NSError?)->Void) {
        
        let manager = AFHTTPSessionManager()
        
        manager.GET(BaseURL() + "\(park.parkId)-waittimes.json", parameters: nil, progress: nil, success: { (task, response) -> Void in
                if let value = response {
                    let json = JSON(value)
                    var attractions = [Attraction]()
                
                    for attrJson in json.arrayValue {
                        attractions.append(Attraction(json: attrJson, park: park))
                    }
                
                    completion(success: true, attractions: attractions, error: nil)
                }
            }, failure: { (task, error) -> Void in
                completion(success: false, attractions: nil, error: error)
            })
    }
    
    var imageUrl: String {
        let scale = min(2, Int(UIScreen.mainScreen().scale))
        return BaseURL() + "images/\(self.id)@\(scale).png"
    }
}

extension NSDate {
    convenience init(stringDate: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        if let d = dateFormatter.dateFromString(stringDate) {
            self.init(timeInterval: 0, sinceDate: d)
        } else {
            self.init()
        }
    }
}