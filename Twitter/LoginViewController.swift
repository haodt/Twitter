//
//  ViewController.swift
//  Twitter
//
//  Created by Hao on 10/28/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onLogin(_ sender: AnyObject) {
        let client = Twitter.client()
        
        if client?.requestToken == nil {
            client?.askRequestToken()
        }
        
    }


}

