//
//  FollowersViewController.swift
//  iHub
//
//  Created by Gautham Pughazhendhi on 02/10/18.
//  Copyright © 2018 Gautham Pughazhendhi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    var urlSession: NSURLSession!
    var locationManager: CLLocationManager!
    var location: CLLocationCoordinate2D!
    var state: Int = 0

    var businesses: [Business]  = [] {
        didSet {
            if self.followersTableView != nil {
                self.followersTableView.reloadData()
            }
        }
    }
    var alert: UIAlertController!
    var yelpClient: YelpAPIClient!
    var ratingData = ["0", "1", "1.5", "2", "2.5", "3", "3.5", "4", "4.5", "5"]
    @IBOutlet weak var followersTableView: UITableView!
    @IBOutlet weak var ratingPickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.urlSession = NSURLSession(configuration: configuration)
        self.followersTableView.delegate = self
        self.followersTableView.dataSource = self
        self.ratingPickerView.delegate = self
        self.ratingPickerView.dataSource = self
        self.yelpClient = YelpAPIClient()
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        alert = UIAlertController(title: nil, message: "No businesses found for this rating", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(alertAction)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BusinessesViewController.readOrLoadData), name: UIApplicationWillEnterForegroundNotification, object: nil)
        self.ratingPickerView.selectRow(7, inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.location = location
        self.locationManager.stopUpdatingLocation()
        self.readOrLoadData()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ratingData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ratingData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if state == 1 {
            self.loadBusinessesWithLocation()
        } else {
            self.loadBusinessesWithLatLng()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let destinationViewController = segue.destinationViewController as? BusinessDetailViewController
            let index = self.followersTableView.indexPathForSelectedRow?.row
            let business = self.businesses[index!]
            
            destinationViewController?.business = business
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        performSegueWithIdentifier("showDetail", sender: cell)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("follower", forIndexPath: indexPath) as? FollowersTableViewCell
        let cellData = self.businesses[indexPath.row]
        cell!.name.text = cellData.name
        let request = NSURLRequest(URL: cellData.imageURL)
        
        cell!.dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error == nil && data != nil {
                    let image = UIImage(data: data!)
                    cell!.avatar.image = image
                }
            })
        }
        
        cell!.dataTask.resume()
        return cell!
    }
    
    func readOrLoadData() {
        loadBusinessesJsonWithURL()
    }
    
    
    func readData() {
        readArchievedData({ (businesses: Businesses) -> Void in
            self.businesses = businesses.businesses
            print("read from cache")
        })
    }
    
    func feedFilePath() -> String {
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let filePath = paths[0].URLByAppendingPathComponent("followers.plist")
        return filePath.path!
    }
    
    func saveData(businesses: Businesses) -> Bool {
        let success = NSKeyedArchiver.archiveRootObject(businesses, toFile: feedFilePath())
        return success
    }
    
    func readArchievedData(completion: (businesses: Businesses) -> Void) {
        let path = feedFilePath()
        let followers = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? Businesses
        
        completion(businesses: followers!)
    }
    
    func loadBusinessesJsonWithURL() -> Void {
        if self.state == 1 {
            self.loadBusinessesWithLocation()
        } else {
            self.loadBusinessesWithLatLng()
        }
    }
    
    func loadBusinessesWithLocation() -> Void {
        let location: String = NSUserDefaults.standardUserDefaults().stringForKey("userLocation")!
        self.yelpClient.locationSearch(location) { (data, error) in
            guard error == nil else {
                print(error)
                let alert = UIAlertController(title: "Connection Error", message: error?.localizedDescription ?? "Yelp connection error.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            let minRating = self.ratingData[self.ratingPickerView.selectedRowInComponent(0)]
            guard let b = Businesses(data: data!, rating: minRating) else {
                return
            }
            
            self.businesses = b.businesses
            if b.isEmpty {
                let alert = UIAlertController(title: nil, message: "Yelp does not support your default location", preferredStyle: .Alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .Cancel) { (UIAlertAction) in
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    })
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                if self.businesses.count == 0 {
                    self.presentViewController(self.alert, animated: true, completion: nil)
                }
                self.state = 1
            }
            
        }
    }
    
    func loadBusinessesWithLatLng() -> Void {
        self.yelpClient.latLngSearch(String(location.latitude), longitude: String(location.longitude)) { (data, error) in
            guard error == nil else {
                let alert = UIAlertController(title: "Connection Error", message: error?.localizedDescription ?? "Yelp connection error.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            let minRating = self.ratingData[self.ratingPickerView.selectedRowInComponent(0)]
            guard let b = Businesses(data: data!, rating: minRating) else {
                return
            }
            
            self.businesses = b.businesses
            if b.isEmpty {
                let alert = UIAlertController(title: nil, message: "Yelp does not support your location, loading for default location", preferredStyle: .Alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.loadBusinessesWithLocation()
            } else {
                if self.businesses.count == 0 {
                    self.presentViewController(self.alert, animated: true, completion: nil)
                }
                self.state = 0
            }
            
            
        }
    }
}
