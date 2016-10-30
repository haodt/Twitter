//
//  TweetTableViewCell.swift
//  Twitter
//
//  Created by Hao on 10/30/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var favouriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var currentViewController:UIViewController!
    
    var tweet:Tweet!{
        didSet{
            tweet.render(
                replyButton:replyButton,
                retweetButton:retweetButton,
                favouriteButton:favouriteButton,
                delegate:self
            )
            
            tweet.render(
                tweetLabel: tweetLabel,
                userScreenNameLabel: userScreenNameLabel,
                userNameLabel: userNameLabel,
                userImageView: userImageView
            )
            
            tweet.render(
                favouriteCountLabel:favouriteCountLabel,
                retweetCountLabel:retweetCountLabel
            )
            
            let minutes = tweet.getDiffFromNow()
            
            switch(true){
                case minutes > 60*24:
                    timeLabel.text = NSString.init(format: "%dd %dh", minutes / (60*24), minutes % (60*24) / 60) as String
                    break
                case minutes > 60:
                    timeLabel.text = NSString.init(format: "%dh %dm", minutes / 60,minutes % 60) as String
                    break
                default:
                    timeLabel.text = NSString.init(format: "%dm", minutes) as String
            }
            
            
               
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TweetTableViewCell:TweetDelegate {
    
    @objc func reply(_ button:UIButton) {
        let compose = self.currentViewController.storyboard?.instantiateViewController(withIdentifier: "ComposeViewController") as! ComposeViewController
        let navigation = UINavigationController(rootViewController: compose)
        
        compose.replyTo = tweet
        
        self.currentViewController.present(navigation, animated: true, completion: nil)
    }
    
    @objc func retweet(_ button:UIButton) {
        MBProgressHUD.showAdded(to: self.currentViewController.view, animated: true)
        tweet.retweet { (tweet:Tweet) in
            self.tweet = tweet
            MBProgressHUD.hide(for: self.currentViewController.view, animated: true)
        }
    }
    
    @objc func favourite(_ button:UIButton) {
        MBProgressHUD.showAdded(to: self.currentViewController.view, animated: true)
        tweet.favourite { (tweet:Tweet) in
            self.tweet = tweet
            MBProgressHUD.hide(for: self.currentViewController.view, animated: true)
        }
    }
    
}
