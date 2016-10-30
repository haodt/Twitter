//
//  TimelineViewController.swift
//  Twitter
//
//  Created by Hao on 10/29/16.
//  Copyright © 2016 Hao. All rights reserved.
//

import UIKit
import MBProgressHUD

class TimelineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: UITableView!
    
    var tweets:[Tweet] = []
    
    var isLoading:Bool = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TimelineViewController.onRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.rowHeight = UITableViewAutomaticDimension
        timelineTableView.estimatedRowHeight = 100
        timelineTableView.addSubview(refreshControl)
        
        self.fetch(fresh:true)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    func onRefresh(_ refreshControl: UIRefreshControl){
        self.fetch(fresh:true)
    }
    
    func fetch(fresh:Bool){
        
        if isLoading {
            return
        }
        
        isLoading = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Tweets.timeline(
            completion: { (tweets:[Tweet]) in
                
                if fresh {
                    self.tweets = tweets
                }
                else {
                    self.tweets += tweets
                }
                
                self.timelineTableView.reloadData()
                self.isLoading = false
                
                self.refreshControl.endRefreshing()
                MBProgressHUD.hide(for: self.view, animated: true)
                
            },
            fresh:fresh
        )
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identifier = segue.identifier {
            
            switch(identifier){
                case "logOut":
                    Twitter.logout()
                    break
                case "showDetail":
                    let nav = segue.destination as! UINavigationController
                    let detail = nav.topViewController as! TweetViewController
                    
                    if let row = timelineTableView.indexPathForSelectedRow?.row {
                        detail.tweet = tweets[row]
                    }
                    
                    break
                default:
                    break;
            
            }
        
        }
    }

}

extension TimelineViewController:UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = timelineTableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as! TweetTableViewCell
        
        cell.tweet = tweets[indexPath.row]
        cell.currentViewController = self
        
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            
            self.fetch(fresh:false)
                
        }
    }

}
