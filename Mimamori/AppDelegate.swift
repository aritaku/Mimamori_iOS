//
//  AppDelegate.swift
//  Mimamori
//
//  Created by 有村琢磨 on 2015/12/26.
//  Copyright © 2015年 有村琢磨. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var time :NSTimeInterval = 10
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        Parse.setApplicationId("bYVfB23l7xzyPpTgKmYU410tLXSpiox1flfH0ly4", clientKey: "UXjvGbfRIXgPcMlCsL0IgOAge7ygb2HitbSmIgtF")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //Background fetch
//        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(time)
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if #available(iOS 8.0, *) {
            let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.time = 10
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        let newLocation = CLLocation()
        var longitude :CLLocationDegrees = 0.0
        var latitude :CLLocationDegrees = 0.0
        
        latitude = newLocation.coordinate.latitude
        longitude = newLocation.coordinate.longitude
        
        let geoData_Realm = GeoData()
        let geoData_Parse = PFObject(className: "GeoData")
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        locationManager.startUpdatingLocation()
        geoData_Realm.latitude = latitude
        geoData_Realm.longitude = longitude
        geoData_Realm.os = "iOS"
        geoData_Realm.timeStamp = formatter.stringFromDate(now)
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(geoData_Realm)
        }
        
        geoData_Parse["longitude"] = longitude
        geoData_Parse["latitude"] = latitude
        geoData_Parse["timeStamp"] = formatter.stringFromDate(now)
        geoData_Parse["OS"] = "iOS"
        geoData_Parse.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
            print("Object has been saved in Parse. \(formatter.stringFromDate(now))")
            if error != nil {
                print(error)
            }
        }
        print(realm.objects(GeoData).last)
        completionHandler(UIBackgroundFetchResult.NewData)
    }


}

