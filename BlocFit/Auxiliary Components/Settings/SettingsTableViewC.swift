//
//  SettingsTableViewC.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsTableViewC: UITableViewController {
    
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var fbLoginView: UIView!
    @IBOutlet weak var newFriendsSettingLabel: UILabel!
    @IBOutlet weak var shareFirstNameLabel: UILabel!
    
    var controller: SettingsControllerProtocol! {
        didSet {
            controller.unitsDidChange = { [unowned self] controller in
                self.unitsLabel?.text = controller.units
            }
            controller.defaultTrustedDidChange = { [unowned self] controller in
                self.newFriendsSettingLabel?.text = controller.defaultTrusted
            }
            controller.shareFirstNameDidChange = { [unowned self] controller in
                self.shareFirstNameLabel?.text = controller.shareFirstName
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.controller = SettingsController()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        controller.resetLabelValues()
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
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == Loc.unitConversionCell.sec &&
            indexPath.row == Loc.unitConversionCell.row {
            
            controller.toggleUnitsSetting()
        
        } else if indexPath.section == Loc.friendsDefaultToTrustedCell.sec &&
            indexPath.row == Loc.friendsDefaultToTrustedCell.row {
                
            controller.toggleTrustedDefaultSetting()
            
        } else if indexPath.section == Loc.shareNameCell.sec &&
            indexPath.row == Loc.shareNameCell.row {
                
            controller.toggleShareFirstNameSetting()
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
