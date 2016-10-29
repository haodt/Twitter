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

let consumerKey = "JWJtknZ97A6n5XtXgA3PfpYto"
let consumerSecret = "0KGsDwfeKftIOUomJFBcjIyR2oQw8cZbOZCNvQiiEVZs3doHhE"

class Twitter: BDBOAuth1SessionManager {

    var accessToken:BDBOAuth1Credential!{
        didSet{
            let cache = NSCache<NSString, BDBOAuth1Credential>()
            
            cache.setObject(accessToken, forKey: "accessToken")
            self.requestSerializer.saveAccessToken(accessToken)
        }
    }
    
    var requestToken:BDBOAuth1Credential!{
        didSet{
            // Caching
            let cache = NSCache<NSString, BDBOAuth1Credential>()
            
            cache.setObject(requestToken, forKey: "requestToken")
        }
    }
    
    
    private static var _client:Twitter!
    
    static func client() -> Twitter! {
        
        if _client == nil {
            _client = Twitter(
                baseURL: URL(string:"https://api.twitter.com/"),
                consumerKey: consumerKey,
                consumerSecret: consumerSecret
            )

            let cache = NSCache<NSString, BDBOAuth1Credential>()
            
            if let cachedRequestToken = cache.object(forKey: "requestToken") {
                _client.requestToken = cachedRequestToken
            }
            if let cachedAccessToken = cache.object(forKey: "accessToken") {
                _client.accessToken = cachedAccessToken
            }
        }
        
        return _client
    }
    
    func askRequestToken(){
        if requestToken != nil {
            print("You already had request token")
            return;
        }
        
        requestSerializer.removeAccessToken()
        
        var request = URLRequest(
            url: URL(string:"https://api.twitter.com/oauth/request_token")!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        request.setValue("OAuth oauth_consumer_key=\"JWJtknZ97A6n5XtXgA3PfpYto\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1477733623\",oauth_nonce=\"ZBERMd\",oauth_version=\"1.0\",oauth_signature=\"fpVf5uj0%2FS9rL%2F%2FmjJkBvP0c6QU%3D\"", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task:URLSessionDataTask = session.dataTask(
            with: request,
            completionHandler:{ (data:Data?, response:URLResponse?, error:Error?) in
                print("MANUAL",NSString(data: (data)!, encoding: String.Encoding.utf8.rawValue),response, error)
            }
        )
        
        task.resume();
        
        
        fetchRequestToken(
            withPath: "/oauth/request_token",
            method: "GET",
            callbackURL: URL(string:"haodt1990twitter://oauth"),
            scope: nil,
            success: { (response:BDBOAuth1Credential?) in
                print("got request token",response)
                
                let authUrl = NSURL(string:"https://api.twitter.com/oauth/authorize?oauth_token=\(response?.token)")
                UIApplication.shared.open(authUrl! as URL)
                
            },
            failure: { (error:Error?) in
                print("error fetching request token",error?.localizedDescription,self.requestSerializer.debugDescription,self.requestSerializer.oAuthParameters())
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
                
                print("i have access token now",response)
                
                self.accessToken = BDBOAuth1Credential(token: response?.token, secret: response?.secret, expiration: nil)

                
            },
            failure: { (error:Error?) in
                print("access token error",error?.localizedDescription)
            }
        )
    }
    
}
