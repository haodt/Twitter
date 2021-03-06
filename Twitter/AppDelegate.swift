//
//  AppDelegate.swift
//  Twitter
//
//  Created by Hao on 10/28/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit

import BDBOAuth1Manager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barTintColor = UIColor(red:0.00, green:0.67, blue:0.93, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let client = Twitter.client() {
            
            if client.isAuthorized {
            
                let timeline = storyboard.instantiateViewController(withIdentifier: "TimelineViewController") as! TimelineViewController
                let navigation = UINavigationController(rootViewController: timeline)
                
                self.window?.rootViewController = navigation
                
            }
            else {
                
                let login = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                
                self.window?.rootViewController = login
                
            }
            
            self.window?.makeKeyAndVisible()
        }

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        if let queries = url.query?.components(separatedBy: "&") {
            let isAccepted = queries.filter({ (q) -> Bool in
                return q.contains("oauth_token")
            })
            if isAccepted.count > 0 {
                
                print("oauth request token return",url);

                let request = BDBOAuth1Credential(queryString: url.query)
                let client = Twitter.client()!
                
                client.requestToken = request;
                
                if let current = self.window?.rootViewController as? LoginViewController {
                
                    current.askAccessToken()
                
                }
                
                
            }
        }
        
        
        return true;
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

