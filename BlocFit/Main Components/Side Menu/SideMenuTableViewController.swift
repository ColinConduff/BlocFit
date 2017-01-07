//
//  SideMenuTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit

class SideMenuTableViewController: UITableViewController {
    
    @IBOutlet weak var fbCoverImageView: FBSDKProfilePictureView!
    
    @IBOutlet weak var leftLabelForFBName: UILabel!
    @IBOutlet weak var fbNameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var controller: SideMenuTableControllerProtocol! {
        didSet {
            controller.fbNameDidChange = { [unowned self] Controller in
                if let fbName = Controller.fbName {
                    self.showFBData(fbName: fbName)
                } else {
                    self.hideFBData()
                }
            }
            controller.usernameDidChange = { [unowned self] Controller in
                self.usernameLabel?.text = Controller.username
            }
            controller.scoreDidChange = { [unowned self] Controller in
                self.scoreLabel?.text = Controller.score
            }
        }
    }
    
    var tableDelegate: UITableViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        controller = SideMenuTableController(context: context)
        
        tableView.delegate = tableDelegate
        
        fbCoverImageView.profileID = "/me" // should be set by view model?
        hideFBData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isScrollEnabled = UIDevice.current.orientation == .landscapeLeft ||
            UIDevice.current.orientation == .landscapeRight
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        controller.resetLabelValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { coordinatorContext in
            self.tableView.isScrollEnabled = UIDevice.current.orientation == .landscapeLeft ||
                                             UIDevice.current.orientation == .landscapeRight
        }
    }
    
    func hideFBData() {
        leftLabelForFBName.isHidden = true
        fbNameLabel?.text = ""
        fbNameLabel.isHidden = true
        fbCoverImageView.isHidden = true
    }
    
    func showFBData(fbName: String) {
        leftLabelForFBName.isHidden = false
        fbNameLabel?.text = fbName
        fbNameLabel.isHidden = false
        fbCoverImageView.isHidden = false
    }

}
