//
//  ViewController.swift
//  Twitter
//
//  Created by Hao on 10/28/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    func askAccessToken(){
        let client = Twitter.client()!
        if client.requestToken != nil {
            if client.accessToken != nil {
                self.presentTimeline()
                return
            }
            client.askAccessToken(completion: {(client:Twitter) in
                self.presentTimeline()
            })
        }
    }
    
    func presentTimeline(){
        let timeline = self.storyboard?.instantiateViewController(withIdentifier: "TimelineViewController") as! TimelineViewController
        let navigation = UINavigationController(rootViewController: timeline)
        
        self.present(navigation, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: AnyObject) {
        
        if let client = Twitter.client() {
            
            if client.requestToken == nil {
                
                client.askRequestToken()
                return
            
            }
            askAccessToken()
            
        }
        
    }


}

