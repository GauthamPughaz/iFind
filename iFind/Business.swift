//
//  Follower.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 02/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit

class Business: NSObject, NSCoding {
    
    var imageURL: NSURL
    var name: String
    var id: String
    
    init(imageURL: NSURL, name: String, id: String) {
        self.imageURL = imageURL
        self.name = name
        self.id = id
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.imageURL, forKey: "imageURL")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.id, forKey: "id")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let imageURL = aDecoder.decodeObjectForKey("imageURL") as? NSURL
        let name = aDecoder.decodeObjectForKey("name") as? String
        let id = aDecoder.decodeObjectForKey("id") as? String
        
        guard imageURL != nil && name != nil && id != nil else {
            return nil
        }
        self.init(imageURL: imageURL!, name: name!, id: id!)
    }
}