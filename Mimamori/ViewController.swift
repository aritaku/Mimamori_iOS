//
//  ViewController.swift
//  Mimamori
//
//  Created by 有村琢磨 on 2015/12/26.
//  Copyright © 2015年 有村琢磨. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var lm :CLLocationManager! = nil
    var longitude :CLLocationDegrees!
    var latitude :CLLocationDegrees!
    var timer :NSTimer?
    
    let dateformetter = NSDateFormatter()
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBAction func start(){
        lm.startUpdatingLocation()
        statusLabel.text = "位置情報収集中"
    }
    
    @IBAction func stopLog(sender: AnyObject) {
        lm.stopUpdatingLocation()
        longitude = 0.0
        latitude = 0.0
        latitudeLabel.text = "緯度"
        longitudeLabel.text = "経度"
        statusLabel.text = "停止中"
    }
    
    
//    func writeGeoDataToRealm(latitude:Double, longitude:Double, os:String){
//        let geoData = GeoData()
//        geoData.latitude = latitude
//        geoData.longitude = longitude
//        geoData.os = "iOS"
//        
//        let now = NSDate()
//        geoData.timeStamp = dateformetter.stringFromDate(now)
//        
//        let realm = try! Realm()
//        try! realm.write {
//            realm.add(geoData)
//        }
//        
//        print(realm.objects(GeoData).last)
//    }
    
    
    
    func writeGeoDataToParse(latitude:Double, longitude:Double){
        let geoData = PFObject(className: "GeoData")
        let now = NSDate()
        geoData["longitude"] = longitude
        geoData["latitude"] = latitude
        geoData["timeStamp"] = dateformetter.stringFromDate(now)
        geoData["OS"] = "iOS"
        geoData.saveInBackgroundWithBlock { [unowned self](success: Bool, error: NSError?) -> Void in
            print("Object has been saved in Parse. \(self.dateformetter.stringFromDate(now))")
            if error != nil {
                self.statusLabel.text = String(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lm = CLLocationManager()
        lm.delegate = self
        lm.requestAlwaysAuthorization()
        lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if #available(iOS 9.0, *){
            lm.allowsBackgroundLocationUpdates = true
        }
        lm.distanceFilter = 5
        
        longitude = 0.0
        latitude = 0.0
        longitudeLabel.text = "経度"
        latitudeLabel.text = "緯度"
        statusLabel.text = "停止中"
        
        dateformetter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateformetter.timeStyle = .MediumStyle
        dateformetter.dateStyle = .MediumStyle
        
        timer = NSTimer.scheduledTimerWithTimeInterval(600, target: self, selector: "start", userInfo: nil, repeats: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        longitude = newLocation.coordinate.longitude
        latitude = newLocation.coordinate.latitude
        
        //writeGeoDataToRealm(latitude, longitude: longitude, os: "iOS")
        writeGeoDataToParse(latitude, longitude: longitude)
        
        self.longitudeLabel.text = String(self.longitude)
        self.latitudeLabel.text = String(self.latitude)
        statusLabel.text = "位置情報収集中"
    }
    
    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("位置情報の取得に失敗しています。")
        statusLabel.text = "位置情報の取得に失敗しています。"
    }
}

