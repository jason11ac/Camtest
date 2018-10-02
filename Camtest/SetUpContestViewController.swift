//
//  SetUpContestViewController.swift
//  FirebaseDemo
//
//  Created by Jason Alvarez-Cohen on 11/2/17.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class SetUpContestViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contestNameField: UITextField!
    @IBOutlet weak var contestantField: UITextField!
    @IBOutlet weak var votingTimeField: UITextField!
    
    var name: String = ""
    var contestant: Int = 0
    var voting: Int = 0
    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(secondaryColor, for: .normal)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
        continueButton.addTarget(self, action: #selector(handleSetUp), for: .touchUpInside)
        continueButton.alpha = 0.5
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        
        view.addSubview(activityView)
        
        contestNameField.delegate = self
        contestantField.delegate = self
        votingTimeField.delegate = self
        
        contestNameField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        contestNameField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        contestNameField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        let a = contestNameField.text
        let b = contestantField.text
        let c = votingTimeField.text
        let formFilled = a != nil && a != "" && b != nil && b != "" && c != nil && c != ""
        setContinueButton(enabled: formFilled)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setContinueButton(enabled:Bool) {
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    @objc func handleSetUp() {
        name = contestNameField.text!
        contestant = Int(contestantField.text!)!
        voting = Int(votingTimeField.text!)!
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
        
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
