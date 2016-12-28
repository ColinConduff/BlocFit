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

class SideMenuTableDelegate: NSObject, UITableViewDelegate {
    
    var seguePerformer: SegueCoordinationDelegate
    
    init(segueCoordinator: SegueCoordinationDelegate) {
        self.seguePerformer = segueCoordinator
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Cell.profile.sec &&
            indexPath.row == Cell.profile.row {
            return 80
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let segueIdentifier = segueIdentifier(section: indexPath.section,
                                                 row: indexPath.row) {
            seguePerformer.transition(withSegueIdentifier: segueIdentifier)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Section and row numbers corresponding to static table cells
    private struct Cell {
        static let profile = (sec: 0, row: 0) 
        static let friends = (sec: 1, row: 0)
        static let gameCenter = (sec: 1, row: 1)
        static let runHistory = (sec: 2, row: 0)
        static let statistics = (sec: 2, row: 1)
        static let settings = (sec: 3, row: 0)
    }
    
    // Return the segueIdentifier corresponding to the selected static table cell
    private func segueIdentifier(section: Int, row: Int) -> String? {
        var segueIdentifier: String?
        
        if section == Cell.friends.sec ||
            section == Cell.gameCenter.sec {
            
            if row == Cell.friends.row {
                segueIdentifier = SegueIdentifier.friendTableSegue
                
            } else if row == Cell.gameCenter.row {
                segueIdentifier = SegueIdentifier.gameCenterSegue
            }
            
        } else if section == Cell.runHistory.sec ||
            section == Cell.statistics.sec {
            
            if row == Cell.runHistory.row {
                segueIdentifier = SegueIdentifier.runHistoryTableSegue
                
            } else if row == Cell.statistics.row {
                segueIdentifier = SegueIdentifier.statisticsTableSegue
            }
            
        } else if section == Cell.settings.sec &&
            row == Cell.settings.row {
            
            segueIdentifier = SegueIdentifier.settingsTableSegue
        }
        
        return segueIdentifier
    }
}

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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        viewModel = SideMenuTableViewModel(context: context)
//    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.resetLabelValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        // create navigation protocol/delegate to handle this
//        if let mainViewController = parent as? MainViewController,
//            let segueIdentifier = viewModel?.segueIdentifier(section: indexPath.section,
//                                                             row: indexPath.row) {
//            
//            if segueIdentifier == SegueIdentifier.gameCenterSegue {
//                mainViewController.showLeaderboard()
//                
//            } else {
//                mainViewController.performSegue(withIdentifier: segueIdentifier,
//                                                sender: mainViewController)
//            }
//        }
//        
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
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
