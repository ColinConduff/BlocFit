//
//  SettingsTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var fbLoginView: UIView!
    @IBOutlet weak var newFriendsSettingLabel: UILabel!
    @IBOutlet weak var shareFirstNameLabel: UILabel!
    
    var Controller: SettingsControllerProtocol! {
        didSet {
            Controller.unitsDidChange = { [unowned self] Controller in
                self.unitsLabel?.text = Controller.units
            }
            Controller.defaultTrustedDidChange = { [unowned self] Controller in
                self.newFriendsSettingLabel?.text = Controller.defaultTrusted
            }
            Controller.shareFirstNameDidChange = { [unowned self] Controller in
                self.shareFirstNameLabel?.text = Controller.shareFirstName
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.Controller = SettingsController()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        Controller.resetLabelValues()
        setUpFB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct Loc {
        static let friendsDefaultToTrustedCell = (sec: 1, row: 0)
        static let shareNameCell = (sec: 2, row: 0)
        static let unitConversionCell = (sec: 3, row: 0)
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == Loc.unitConversionCell.sec &&
            indexPath.row == Loc.unitConversionCell.row {
            
            Controller.toggleUnitsSetting()
        
        } else if indexPath.section == Loc.friendsDefaultToTrustedCell.sec &&
            indexPath.row == Loc.friendsDefaultToTrustedCell.row {
                
            Controller.toggleTrustedDefaultSetting()
            
        } else if indexPath.section == Loc.shareNameCell.sec &&
            indexPath.row == Loc.shareNameCell.row {
                
            Controller.toggleShareFirstNameSetting()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setUpFB() {
        let loginButton = FBSDKLoginButton()
        loginButton.center = fbLoginView.center
        fbLoginView.addSubview(loginButton)
        
        // Move to FB View Model
        loginButton.readPermissions = [
            "public_profile"
        ]
        
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
    }
}
