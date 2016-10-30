//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Hao on 10/30/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit
import MBProgressHUD

class ComposeViewController: UIViewController {

    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var tweetTextView: UITextView!
    var tweetPlaceholderLabel : UILabel!
    
    var replyTo:Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.delegate = self
        
        tweetPlaceholderLabel = UILabel()
        tweetPlaceholderLabel.text = "Type or say something"
        tweetPlaceholderLabel.font = UIFont.italicSystemFont(ofSize: (tweetTextView.font?.pointSize)!)
        tweetPlaceholderLabel.sizeToFit()
        
        tweetTextView.addSubview(tweetPlaceholderLabel)
        
        tweetPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (tweetTextView.font?.pointSize)! / 2)
        tweetPlaceholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        tweetPlaceholderLabel.isHidden = !tweetTextView.text.isEmpty
        
        tweetTextView.becomeFirstResponder()
        
        if let client = Twitter.client() {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            client.user(completion: {(user:User) in
                MBProgressHUD.hide(for: self.view, animated: true)
                self.userNameLabel.text = user.name
                self.userScreenNameLabel.text = "@\(user.screen_name)"
                self.userImageView.setImageWith(URL(string:user.profile_image_url_https)!)
            })
        }
        
        if let replyTo = replyTo {
            
            tweetTextView.text = "@\(replyTo.user.screen_name) "
            tweetPlaceholderLabel.isHidden = true
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTweet(_ sender: Any) {
        if let client = Twitter.client() {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            client.tweet(
                status: tweetTextView.text,
                completion: { (tweet:Tweet) in
                    print("Tweeted",tweet)
                    self.dismiss(animated: true, completion: nil)
                },
                replyTo:self.replyTo
            )
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

extension ComposeViewController:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        tweetPlaceholderLabel.isHidden = !tweetTextView.text.isEmpty
    }
    
}
