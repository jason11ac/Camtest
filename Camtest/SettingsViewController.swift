//
//  SettingsViewController.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 10/19/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var Coins: UILabel!
    @IBOutlet weak var Wins: UILabel!
    
    var activityView:UIActivityIndicatorView!
    
    
    @IBAction func handleLogOut2(_ sender: Any) {
        
        myUrl = ""
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @IBAction func handleLogOut(_ target: UIBarButtonItem) {
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Account"

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        
        view.addSubview(activityView)
        // Do any additional setup after loading the view.
        
        
        if let user = Auth.auth().currentUser {
            userName.text = user.displayName
            email.text = user.email
            
            let userRefCoins = Database.database().reference().child("users/\(user.uid)/coins")
            let userRefWins = Database.database().reference().child("users/\(user.uid)/wins")
            
            
            //userRef.observe(.value, with: { (snapshot) in
            userRefCoins.observeSingleEvent(of: .value, with: { (snapshot) in
                if let coins = snapshot.value as? Int {
                    self.Coins.text = String(coins)
                }
            })
            
            userRefWins.observeSingleEvent(of: .value, with: { (snapshot) in
                if let wins = snapshot.value as? Int {
                    self.Wins.text = String(wins)
                }
            })
            
            
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
        
    func convert(snapshot: DataSnapshot) -> String
    {
        var text: String = ""
        if let value = snapshot.value as? String {
            text = value
        }
        return text
    }

}
