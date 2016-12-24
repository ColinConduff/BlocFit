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
    
    var viewModel: SettingsViewModelProtocol! {
        didSet {
            viewModel.unitsDidChange = { [unowned self] viewModel in
                self.unitsLabel?.text = viewModel.units
            }
            viewModel.defaultTrustedDidChange = { [unowned self] viewModel in
                self.newFriendsSettingLabel?.text = viewModel.defaultTrusted
            }
            viewModel.shareFirstNameDidChange = { [unowned self] viewModel in
                self.shareFirstNameLabel?.text = viewModel.shareFirstName
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = SettingsViewModel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewModel.resetLabelValues()
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
            
            viewModel.toggleUnitsSetting()
        
        } else if indexPath.section == Loc.friendsDefaultToTrustedCell.sec &&
            indexPath.row == Loc.friendsDefaultToTrustedCell.row {
                
            viewModel.toggleTrustedDefaultSetting()
            
        } else if indexPath.section == Loc.shareNameCell.sec &&
            indexPath.row == Loc.shareNameCell.row {
                
            viewModel.toggleShareFirstNameSetting()
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
