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
    
    var isImperialUnits: Bool?
    var willDefaultToTrusted: Bool?
    var willShareFirstName: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if isImperialUnits == nil {
            isImperialUnits = BFUserDefaults.getUnitsSetting()
        }
        if let isImperialUnits = isImperialUnits {
            unitsLabel?.text = BFUserDefaults.stringFor(unitsSetting: isImperialUnits)
        }
        
        if willDefaultToTrusted == nil {
            willDefaultToTrusted = BFUserDefaults.getNewFriendDefaultTrustedSetting()
        }
        if let willDefaultToTrusted = willDefaultToTrusted {
            newFriendsSettingLabel?.text = BFUserDefaults.stringFor(
                friendsWillDefaultToTrusted: willDefaultToTrusted)
        }
        
        if willShareFirstName == nil {
            willShareFirstName = BFUserDefaults.getShareFirstNameWithTrustedSetting()
        }
        if let willShareFirstName = willShareFirstName {
            shareFirstNameLabel?.text = BFUserDefaults.stringFor(
                willShareFirstNameWithTrustedFriends: willShareFirstName)
        }
        
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
            
            if isImperialUnits != nil {
                isImperialUnits = !isImperialUnits!
            
                unitsLabel.text = BFUserDefaults.stringFor(unitsSetting: isImperialUnits!)
                BFUserDefaults.set(isImperial: isImperialUnits!)
            }
        
        } else if indexPath.section == Loc.friendsDefaultToTrustedCell.sec &&
            indexPath.row == Loc.friendsDefaultToTrustedCell.row {
                
            if willDefaultToTrusted != nil {
                willDefaultToTrusted = !willDefaultToTrusted!
                newFriendsSettingLabel?.text = BFUserDefaults.stringFor(
                    friendsWillDefaultToTrusted: willDefaultToTrusted!)
                BFUserDefaults.set(friendsWillDefaultToTrusted: willDefaultToTrusted!)
            }
                
        } else if indexPath.section == Loc.shareNameCell.sec &&
            indexPath.row == Loc.shareNameCell.row {
                
            if willShareFirstName != nil {
                willShareFirstName = !willShareFirstName!
                shareFirstNameLabel?.text = BFUserDefaults.stringFor(
                    willShareFirstNameWithTrustedFriends: willShareFirstName!)
                BFUserDefaults.set(
                    willShareFirstNameWithTrustedFriends: willShareFirstName!)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setUpFB() {
        let loginButton = FBSDKLoginButton()
        loginButton.center = fbLoginView.center
        fbLoginView.addSubview(loginButton)
        
        loginButton.readPermissions = [
            "public_profile"
        ]
        
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
    }

}
