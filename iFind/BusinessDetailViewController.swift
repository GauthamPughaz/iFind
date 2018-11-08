//
//  FollowerDetailViewController.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 03/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit

class BusinessDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var business: Business?
    var businessDetail: [Dictionary<String, AnyObject>] = [] {
        didSet {
            self.profileTableView.reloadData()
        }
    }
    
    var imageMap = ["0": "0", "1": "1", "1.5": "1_half", "2": "2", "2.5": "2_half", "3": "3", "3.5": "3_half", "4": "4", "4.5": "4_half", "5": "5"]
    
    var alert: UIAlertController!
    @IBOutlet weak var profileTableView: UITableView!
    var yelpClient: YelpAPIClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.yelpClient = YelpAPIClient()
        self.loadBusinessDetailJsonWithURL()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businessDetail.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let title = self.businessDetail[indexPath.row]["key"] as? String
        let rating = String(self.businessDetail[indexPath.row]["val"]!)
        if title == "Rating" {
            let cell = tableView.dequeueReusableCellWithIdentifier("businessRating", forIndexPath: indexPath) as! BusinessRatingCell
            cell.ratingImage.image = UIImage(named: "\(imageMap[rating]!)")
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("followerProfile", forIndexPath: indexPath)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = String(self.businessDetail[indexPath.row]["val"]!)
            return cell
        }
    }
    
    func loadBusinessDetailJsonWithURL() -> Void {
        
        self.yelpClient.getBussinessDetail(self.business!.id) { (data, error) in
            if error == nil && data != nil {
                guard let businessDetail = BusinessDetail(data: data!) else {
                    print("Follower profile is empty...")
                    return
                }
                self.businessDetail = businessDetail.businessDetail
            }
        }
        
    }
    
    func formatData(followerProfile: BusinessDetail) {
        
    }
}
