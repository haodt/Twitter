//
//  Tweets.swift
//  Twitter
//
//  Created by Hao on 10/30/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit
import FontAwesome_swift

@objc protocol TweetDelegate {

    @objc func reply(_ button:UIButton)
    
    @objc func favourite(_ button:UIButton)
    
    @objc func retweet(_ button:UIButton)
    
}

struct TweetUser {
    
    var name:String
    var screen_name:String
    var profile_image_url_https:String
    
    init(dictionary:NSDictionary){
        
        name = dictionary["name"] as! String
        screen_name = dictionary["screen_name"] as! String
        profile_image_url_https = dictionary["profile_image_url_https"] as! String
        
    }
}

class Tweet:NSObject {
    
    var id:Int
    var created_at:Date
    var favorited:Bool
    var text:String
    var retweet_count:Int
    var favorite_count:Int
    var retweeted:Bool
    var user:TweetUser
    
    init(dictionary:NSDictionary){
        
        self.created_at = Date()
        if let created_at = dictionary["created_at"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            
            self.created_at = formatter.date(from: created_at)!
        }
        
        text = dictionary["text"] as! String
        if let encodedData = text.data(using: .utf8) {
            let attributedOptions: [String : Any] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
            ]
            
            do {
                let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
                text = attributedString.string
            } catch {
                print("Error: \(error)")
            }
        }
        
        
        
        favorited = dictionary["favorited"] as! Bool
        retweeted = dictionary["retweeted"] as! Bool
        
        id = dictionary["id"] as! Int
        favorite_count = dictionary["favorite_count"] as! Int
        retweet_count = dictionary["retweet_count"] as! Int
        
        user = TweetUser(dictionary:dictionary["user"] as! NSDictionary)
        
    }
    
    internal func _render(
        button:UIButton,
        icon:FontAwesome,
        action:Selector,
        delegate:TweetDelegate,
        isNotEnabled:Bool,
        disabledColor:UIColor
    ){
        button.titleLabel?.font = UIFont.fontAwesome(
            ofSize: (button.titleLabel?.font.pointSize)!
        )
        button.setTitleColor(disabledColor, for: .disabled)
        button.setTitle(String.fontAwesomeIcon(name: icon), for: .normal)
        
        if isNotEnabled {
            button.isEnabled = false
            button.removeTarget(delegate, action: action, for: .touchUpInside)
            return
        }
        
        button.addTarget(
            delegate,
            action: action,
            for: .touchUpInside
        )
    }
    
    func retweet(completion:@escaping ((Tweet)->Void)){
        if !retweeted {
            
            if let client = Twitter.client() {
                
                client.post(
                    "1.1/statuses/retweet/\(id).json",
                    parameters: [
                        "id":id
                    ],
                    progress: nil,
                    success: { (task, response:Any) in
                        if let response = response as? NSDictionary {
                            self.retweeted = response["retweeted"] as! Bool
                            self.retweet_count = response["retweet_count"] as! Int
                        }
                        completion(self)
                    },
                    failure: { (task, error) in
                        print("Retweet failed",error.localizedDescription)
                    }
                )
                
            }
            
            return
        }
        completion(self)
    }
    
    func favourite(completion:@escaping ((Tweet)->Void)){
        if !favorited {
            
            if let client = Twitter.client() {
                
                client.post(
                    "1.1/favorites/create.json",
                    parameters: [
                        "id":id
                    ],
                    progress: nil,
                    success: { (task, response:Any) in
                        if let response = response as? NSDictionary {
                            self.favorited = response["favorited"] as! Bool
                            self.favorite_count = response["favorite_count"] as! Int
                        }
                        completion(self)
                    },
                        failure: { (task, error) in
                            print("Retweet failed",error.localizedDescription)
                    }
                )
                
            }
            
            return
        }
        completion(self)
    }
    
    func render(
        favouriteCountLabel:UILabel,
        retweetCountLabel:UILabel
    ){
        favouriteCountLabel.text = NSString.init(format: "%d",favorite_count) as String
        retweetCountLabel.text = NSString.init(format: "%d",retweet_count) as String
        
        if favorited {
            favouriteCountLabel.textColor = UIColor(red:0.91, green:0.11, blue:0.31, alpha:1.0)
        }
        
        if retweeted {
            retweetCountLabel.textColor = UIColor(red:0.10, green:0.81, blue:0.53, alpha:1.0)
        }
        
    }
    
    func render(
            replyButton:UIButton,
            retweetButton:UIButton,
            favouriteButton:UIButton,
            delegate:TweetDelegate
        ){
    
        _render(
            button: replyButton,
            icon: FontAwesome.reply,
            action:#selector(delegate.reply(_:)),
            delegate:delegate,
            isNotEnabled:false,
            disabledColor:UIColor.clear
        )
        
        _render(
            button: retweetButton,
            icon: FontAwesome.retweet,
            action:#selector(delegate.retweet(_:)),
            delegate:delegate,
            isNotEnabled:retweeted,
            disabledColor:UIColor(red:0.10, green:0.81, blue:0.53, alpha:1.0)
        )
        
        _render(
            button: favouriteButton,
            icon: FontAwesome.heart,
            action:#selector(delegate.favourite(_:)),
            delegate:delegate,
            isNotEnabled:favorited,
            disabledColor:UIColor(red:0.91, green:0.11, blue:0.31, alpha:1.0)
        )
    }
    
    func render(
            tweetLabel:UILabel,
            userScreenNameLabel:UILabel,
            userNameLabel:UILabel,
            userImageView:UIImageView
        ){
        tweetLabel.text = text
        tweetLabel.sizeToFit()
        userScreenNameLabel.text = "@\(user.screen_name)"
        userNameLabel.text = user.name
        userImageView.setImageWith(URL(string:user.profile_image_url_https)!)
    }
    
    func getDiffFromNow() -> Int{
        return Calendar.current.dateComponents([.minute], from: created_at, to: Date()).minute!
    }
    
}

class Tweets: NSObject {
 
    static var latest:[Tweet]?
    
    static var youngest:Int?
    
    static func parse(response:NSArray) -> [Tweet]{
        
        var tweets:[Tweet] = []
        
        for item in response {
            let tweet = Tweet(dictionary: item as! NSDictionary)
            tweets.append(tweet)
            
            if Tweets.youngest == nil {
                Tweets.youngest = tweet.id
            }
            
            if tweet.id < Tweets.youngest! {
                Tweets.youngest = tweet.id
            }
            
            
        }
        Tweets.latest = tweets
        return tweets;
    }
    
    static func timeline(completion:@escaping (([Tweet])->Void),fresh:Bool){
        
        if let client = Twitter.client() {
            
            var parameters:[String:Any] = [
                "count":20
            ]
            
            if !fresh {
                parameters["max_id"] = Tweets.youngest
            }
            
            client.get(
                "1.1/statuses/home_timeline.json",
                parameters: parameters,
                progress: nil,
                success: { (task, response:Any) in
                    if let response = response as? NSArray {
                        completion(Tweets.parse(response: response))
                    }
                },
                failure: { (task, error) in
                    if let latest = Tweets.latest {
                        completion(latest)
                    }
                    print(error.localizedDescription)
                }
            )
        }
        
    }
    

}
