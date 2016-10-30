//
//  ViewController.swift
//  Twitter
//
//  Created by Hao on 10/28/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {

        let client = Twitter.client()!
        
        if client.isAuthorized {
            let timeline = self.storyboard?.instantiateViewController(withIdentifier: "TimelineViewController") as! TimelineViewController
            let navigation = UINavigationController(rootViewController: timeline)
            
            self.present(navigation, animated: true, completion: nil)
            
        }
        
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
            client.askRequestToken()
        }
        
    }


}

