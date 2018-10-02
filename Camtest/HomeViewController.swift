//
//  HomeViewController.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/8/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase


var titleOfContest: String = ""

class HomeViewController: UITableViewController, UIToolbarDelegate
{
    
    @IBOutlet weak var composeBarButtonItem: UIBarButtonItem!
    
    //1. create a reference to the db location you want to download
    let storiesRef = Database.database().reference().child("stories")
    var contestRef: DatabaseReference!
    var stories = [Story]()
    
    var refresher: UIRefreshControl!
    
    @IBAction func handleLogOut(_ target: UIBarButtonItem) {
        
        myUrl = ""
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
        //self.tableView.reloadData()
        
        //download stories
        storiesRef.queryOrdered(byChild: "numberOfLikes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.stories.removeAll() //remove all old data
            
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let story = Story(snapshot: childSnapshot)
                print("HomeViewController")
                print("children: \(snapshot.childrenCount)")
                
                //if (story.numberOfUsers == story.maxUsers) {
                    //Send notification
                //} else {
                    self.stories.insert(story, at: 0)
                    print("HomeViewController added \(story.text)")
                    self.tableView.reloadData()
                //}
            }
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        storiesRef.removeAllObservers()
        
        if (contestRef != nil) {
            contestRef.removeAllObservers()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        title = "Contests"
        self.navigationItem.rightBarButtonItem = composeBarButtonItem
        
        self.tableView.estimatedRowHeight = 92.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //Refresh Code
        self.refresher = UIRefreshControl()
        self.tableView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView!.addSubview(refresher)
        
        //self.stories.removeAll() //remove all old data
        
    }
    
    @objc func refresh() {
    
        //download stories
        storiesRef.queryOrdered(byChild: "numberOfLikes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.stories.removeAll() //remove all old data
            
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let story = Story(snapshot: childSnapshot)
                print("HomeViewController")
                print("children: \(snapshot.childrenCount)")
                
                
                //if (story.numberOfUsers == story.maxUsers) {
                    //Send notification
                //} else {
                    self.stories.insert(story, at: 0)
                    print("HomeView Controller added \(story.text)")
                    self.tableView.reloadData()
                //}
            }
        })
        self.refresher.endRefreshing()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // TODO: return the stories count
        //print("STORIES COUNT \(stories.count)")
        return stories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Story Cell", for: indexPath) as! StoryTableViewCell
        let story = stories[indexPath.row]
                
        cell.story = story
        
        var uid: String = ""
        if let user = Auth.auth().currentUser {
            uid = user.uid
        }
        
        contestRef = Database.database().reference().child("users/\(uid)/contests")
        
        contestRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (story.numberOfUsers == story.maxUsers) {
                cell.contentView.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 198/255, alpha: 1)
            } else {
                if (snapshot.hasChild(story.text)) {
                    cell.contentView.backgroundColor = UIColor(red: 229/255, green: 255/255, blue: 229/255, alpha: 1)
                } else {
                    cell.contentView.backgroundColor = UIColor.white
                }
            }
        })
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contestInfo = stories[indexPath.row]
        
        titleOfContest = contestInfo.text
    }
            
    func convert(snapshot: DataSnapshot) -> String
    {
        var text: String = ""
        if let value = snapshot.value as? String {
            text = value
        }
        return text
    }

}
