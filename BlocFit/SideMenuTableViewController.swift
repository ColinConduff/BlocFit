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
    
    var owner: Owner?
    var fbName: String? {
        didSet {
            if let fbName = fbName {
                showFBData(fbName: fbName)
            }
        }
    }
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBSDKProfile.enableUpdates(onAccessTokenChange: true) // also set in settings
        fbCoverImageView.profileID = "/me"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFBProfile()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setUserCell()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    private struct Cell {
        static let friends = (sec: 1, row: 0)
        static let gameCenter = (sec: 1, row: 1)
        static let runHistory = (sec: 2, row: 0)
        static let statistics = (sec: 2, row: 1)
        static let settings = (sec: 3, row: 0)
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        
        var segueIdentifier: String?
        
        if indexPath.section == Cell.friends.sec ||
            indexPath.section == Cell.gameCenter.sec {
            
            if indexPath.row == Cell.friends.row {
                segueIdentifier = SegueIdentifier.friendTableSegue
                
            } else if indexPath.row == Cell.gameCenter.row {
                segueIdentifier = SegueIdentifier.gameCenterSegue
            }
            
        } else if indexPath.section == Cell.runHistory.sec ||
            indexPath.section == Cell.statistics.sec {
            
            if indexPath.row == Cell.runHistory.row {
                segueIdentifier = SegueIdentifier.runHistoryTableSegue
                
            } else if indexPath.row == Cell.statistics.row {
                segueIdentifier = SegueIdentifier.statisticsTableSegue
            }
            
        } else if indexPath.section == Cell.settings.sec &&
            indexPath.row == Cell.settings.row {
            
            segueIdentifier = SegueIdentifier.settingsTableSegue
        }
        
        if let mainViewController = parent as? MainViewController,
            let segueIdentifier = segueIdentifier {
            
            if segueIdentifier == SegueIdentifier.gameCenterSegue {
                mainViewController.showLeaderboard()
                
            } else {
                mainViewController.performSegue(
                    withIdentifier: segueIdentifier,
                    sender: mainViewController)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setUserCell() {
        if let owner = owner {
            setLabels(owner: owner)
            
        } else if let context = context,
            case let owner?? = try? Owner.get(context: context) {
            setLabels(owner: owner)
        }
    }
    
    func setLabels(owner: Owner) {
        if let ownerUsername = owner.username {
            usernameLabel?.text = ownerUsername
            scoreLabel?.text = String(owner.totalScore)
        }
    }
    
    func setScrollable(isScrollable: Bool) {
        self.tableView.isScrollEnabled = isScrollable
    }
    
    func fetchFBProfile() {
        if FBSDKAccessToken.current() != nil {
            if let profile = FBSDKProfile.current() {
                fbName = profile.firstName
            }
        } else {
            hideFBData()
        }
    }
    
    func hideFBData() {
        fbName = nil
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
