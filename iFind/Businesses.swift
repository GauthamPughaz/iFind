//
//  Followers.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 02/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//
import UIKit

class Businesses: NSObject, NSCoding {
    var businesses: [Business]
    var isEmpty: Bool = false
    
    init(businesses: [Business]) {
        self.businesses = businesses
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.businesses, forKey: "businesses")
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let followers = aDecoder.decodeObjectForKey("businesses") as? [Business]
        
        guard followers != nil else {
            return nil
        }
        
        self.init(businesses: followers!)
    }
    
    convenience init?(data: NSData, rating: String) {
        
        var businesses = [Business]();
        
        
        
        guard let jsonData = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))) as? Dictionary<String,AnyObject> else {
            return nil
        }
        
        guard let businessList = jsonData["businesses"] as? Array<AnyObject> else {
            return nil
        }
                
        for item in businessList {
            
            guard let itemDict = item as? Dictionary<String, AnyObject> else {
                return nil
            }
            
            guard let aURL = itemDict["image_url"] as? String else {
                return nil
            }

            guard let name = itemDict["name"] as? String else {
                return nil
            }
            
            guard let id =  itemDict["id"] as? String else {
                return nil
            }
            
            guard let imageURL = NSURL(string: aURL) else {
                return nil
            }
            
            if Double(itemDict["rating"] as! NSNumber) >= Double(rating)! {
                businesses.append(Business(imageURL: imageURL, name: name, id: id))
            }
        }
        
        self.init(businesses: businesses)
        
        if businessList.count == 0 {
            isEmpty = true
        }
        
    }
}