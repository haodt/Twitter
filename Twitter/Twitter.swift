//
//  Twitter.swift
//  Twitter
//
//  Created by Hao on 10/29/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit

import AFNetworking
import BDBOAuth1Manager

let consumerKey = "JxUiG0fZyXliskmGJZYLjZcc4"
let consumerSecret = "2rW7IMZQ9Iz73JTwm800PGoaRHTPa3Vz59nDRXx2I1NIEaiipo"

struct User {

    var name:String
    var screen_name:String
    var profile_image_url_https:String
    
    init(dictionary:NSDictionary){
        name = dictionary["name"] as! String
        screen_name = dictionary["screen_name"] as! String
        profile_image_url_https = dictionary["profile_image_url_https"] as! String
    }
    
}

class Twitter: BDBOAuth1SessionManager {

    var accessToken:BDBOAuth1Credential!{
        didSet{
            let cache = UserDefaults.standard
            let data = NSKeyedArchiver.archivedData(withRootObject: accessToken)
            
            cache.set(data, forKey: "accessToken")
            self.requestSerializer.saveAccessToken(accessToken)
        }
    }
    
    var requestToken:BDBOAuth1Credential!{
        didSet{
            let cache = UserDefaults.standard
            let data = NSKeyedArchiver.archivedData(withRootObject: requestToken)
            cache.set(data, forKey: "requestToken")
        }
    }
    
    private var _user:User?{
        didSet{

        }
    }
    
    func user(completion:@escaping((User)->Void)) -> Void{
        if _user == nil {
            
            let parameters:[String:Any] = [
                "include_email":false
            ];
            
            self.get(
                "1.1/account/verify_credentials.json",
                parameters: parameters,
                progress: nil,
                success: { (task, response:Any) in
                    if let response = response as? NSDictionary {
                        self._user = User(dictionary: response)
                        completion(self._user!)
                    }
                },
                failure: { (task, error:Error) in
                    print("failed to get user setting \(error.localizedDescription)")
                }
            )
            return
        }
        
        completion(_user!)
    }
    
    private var _status:String?
    
    func tweet(status:String,completion:@escaping ((Tweet) -> Void),replyTo:Tweet?){
        
        if _status == status {
            print("user cannot post same status in a row")
            return
        }
        
        var parameters:[String:Any] = [
            "status":status
        ]
        
        if let replyTo = replyTo {
            parameters["in_reply_to_status_id"] = replyTo.id
        }
        
        post(
            "1.1/statuses/update.json",
            parameters: parameters,
            progress: nil,
            success: { (task, response:Any) in
                if let response = response as? NSDictionary {
                    let tweet = Tweet(dictionary: response)
                    completion(tweet)
                }
            },
            failure: { (task, error:Error) in
                print("failed to update new status \(error.localizedDescription)")
            }
        )
        
    }
    
    private static var _client:Twitter!
    
    static func client() -> Twitter! {
        
        if _client == nil {
            _client = Twitter(
                baseURL: URL(string:"https://api.twitter.com/"),
                consumerKey: consumerKey,
                consumerSecret: consumerSecret
            )

            let cache = UserDefaults.standard
            
            if let cachedRequestToken = cache.object(forKey: "requestToken") as? Data {
                _client.requestToken = NSKeyedUnarchiver.unarchiveObject(with: cachedRequestToken) as! BDBOAuth1Credential
            }
            if let cachedAccessToken = cache.object(forKey: "accessToken") as? Data {
                _client.accessToken = NSKeyedUnarchiver.unarchiveObject(with: cachedAccessToken) as! BDBOAuth1Credential
            }
            
        }
        
        return _client
    }
    
    func authorize(){
        if let token = requestToken.token {
            UIApplication.shared.open(URL(string:"https://api.twitter.com/oauth/authorize?oauth_token=\(token)")!)
        }
    }
    
    func askRequestToken(){
        if requestToken != nil {
            print("You already had request token")
            return;
        }
        
        requestSerializer.removeAccessToken()
        
        fetchRequestToken(
            withPath: "/oauth/request_token",
            method: "GET",
            callbackURL: URL(string:"haodt1990twitter://oauth"),
            scope: nil,
            success: { (response:BDBOAuth1Credential?) in
                print("got request token")
                if let response = response {
                    self.requestToken = response
                    self.authorize()
                }
            },
            failure: { (error:Error?) in
                print("error fetching request token")
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        )
    }
    
    func askAccessToken(){
        if requestToken == nil {
            print("You dont have any request token")
            return;
        }
        
        if accessToken != nil {
            print("You have had access token already")
            return;
        }
        
        fetchAccessToken(
            withPath: "oauth/access_token",
            method: "POST",
            requestToken: requestToken,
            success: { (response:BDBOAuth1Credential?) in
                
                print("i have access token now")
                if let response = response {
                    self.accessToken = response
                }
                
            },
            failure: { (error:Error?) in
                print("access token error")
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        )
    }
    
}
