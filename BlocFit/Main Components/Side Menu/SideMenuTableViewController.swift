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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        viewModel = SideMenuTableViewModel(context: context)
        
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
        viewModel.resetLabelValues()
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
