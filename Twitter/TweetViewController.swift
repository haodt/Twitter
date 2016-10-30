//
//  TweetViewController.swift
//  Twitter
//
//  Created by Hao on 10/30/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetViewController: UIViewController {

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var favouriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var tweet:Tweet!
    
    @IBAction func onHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        // Do any additional setup after loading the view.
    }
    
    func render(){
        if let tweet = tweet {
            
            tweet.render(
                tweetLabel: tweetLabel,
                userScreenNameLabel: userScreenNameLabel,
                userNameLabel: userNameLabel,
                userImageView: userImageView
            )
            
            tweet.render(
                replyButton:replyButton,
                retweetButton:retweetButton,
                favouriteButton:favouriteButton,
                delegate:self
            )
            
            tweet.render(
                favouriteCountLabel:favouriteCountLabel,
                retweetCountLabel:retweetCountLabel
            )
            
            let dateformatter = DateFormatter()
            
            dateformatter.dateFormat = "hh:mm dd/MM/YYYY"
            
            createdAtLabel.text = dateformatter.string(from: tweet.created_at)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TweetViewController:TweetDelegate {
    
    @objc func reply(_ button:UIButton) {
        let compose = self.storyboard?.instantiateViewController(withIdentifier: "ComposeViewController") as! ComposeViewController
        let navigation = UINavigationController(rootViewController: compose)
        
        compose.replyTo = tweet
        
        self.present(navigation, animated: true, completion: nil)
    }
    
    @objc func retweet(_ button:UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        tweet.retweet { (tweet:Tweet) in
            self.tweet = tweet
            self.render()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    @objc func favourite(_ button:UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        tweet.favourite { (tweet:Tweet) in
            self.tweet = tweet
            self.render()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
}
