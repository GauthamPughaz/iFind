//
//  FollowerProfile.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 03/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit

class BusinessDetail  {
    var businessDetail: [Dictionary<String, AnyObject>]
    
    init (businessDetail: [Dictionary<String, AnyObject>]) {
       self.businessDetail = businessDetail
    }
    
    convenience init?(data: NSData){
        
        var jsonData: Dictionary<String, AnyObject>?
        var businessDetail = [Dictionary<String, AnyObject>]()
        
        var name: String
        var phone: String
        var location: String = ""
        var openNow: String
        var rating: String
        
        do {
            jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>
        }
        catch {
            
        }
        
        guard let item = jsonData else {
            return nil
        }
        
        if !(item["name"] is NSNull) {
            name = item["name"] as! String
        } else {
            name = "Not available"
        }
        businessDetail.append(["key": "Name", "val": name])
        
        if !(item["display_phone"] is NSNull) {
            phone = item["display_phone"] as! String
        } else {
            phone = "Not available"
        }
        businessDetail.append(["key": "Phone", "val": phone])
        
        
        if !(item["is_open_now"] is NSNull) {
            let hours =  item["hours"]!
            if hours[0]["is_open_now"] as! Bool {
                openNow = "Yes"
            } else {
                openNow = "No, closed"
            }
        } else {
            openNow = "Not available"
        }
        businessDetail.append(["key": "Open now", "val": openNow])
        
        if !(item["location"] is NSNull) {
            let displayAddress = item["location"]!["display_address"] as! Array<String>
            for i in 0...displayAddress.count - 1{
                location += "\(displayAddress[i])"
                if i != displayAddress.count - 1 {
                    location += ", "
                }
            }
        } else {
            location = "Not available"
        }
        
        businessDetail.append(["key": "Location", "val": location])
        
        if !(item["rating"] is NSNull) {
            rating = String(item["rating"]!)
        } else {
            rating = "Not available"
        }
        businessDetail.append(["key": "Rating", "val": rating])
        
        guard let reviewCount = item["review_count"] as? Int else {
            print("Cannot get followingCount...")
            return nil
        }
        businessDetail.append(["key": "Total reviews", "val": reviewCount])
        
        self.init(businessDetail: businessDetail)
    }
}