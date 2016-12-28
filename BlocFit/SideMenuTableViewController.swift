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

class SideMenuTableViewController: UITableViewController, SideMenuDelegate {
    
    @IBOutlet weak var fbCoverImageView: FBSDKProfilePictureView!
    
    @IBOutlet weak var leftLabelForFBName: UILabel!
    @IBOutlet weak var fbNameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var viewModel: SideMenuTableViewModelProtocol! {
        didSet {
            viewModel.fbNameDidChange = { [unowned self] viewModel in
                if let fbName = viewModel.fbName {
                    self.showFBData(fbName: fbName)
                } else {
                    self.hideFBData()
                }
            }
            viewModel.usernameDidChange = { [unowned self] viewModel in
                self.usernameLabel?.text = viewModel.username
            }
            viewModel.scoreDidChange = { [unowned self] viewModel in
                self.scoreLabel?.text = viewModel.score
            }
        }
    }
    
    var tableDelegate: UITableViewDelegate!
    var seguePerformer: SegueCoordinationDelegate! // passed in from mainVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        viewModel = SideMenuTableViewModel(context: context)
        
        tableDelegate = SideMenuTableDelegate(segueCoordinator: seguePerformer)
        tableView.delegate = tableDelegate
        
        fbCoverImageView.profileID = "/me" // should be set by view model?
        hideFBData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.resetLabelValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // delegate method called from mainVC
    func setScrollable(isScrollable: Bool) {
        self.tableView.isScrollEnabled = isScrollable
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
