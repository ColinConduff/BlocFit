//
//  SideMenuTableViewModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/27/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import CoreData
import FBSDKLoginKit

protocol SideMenuTableViewModelProtocol: class {
    
    var username: String? { get }
    var score: String? { get }
    var fbName: String? { get }
    
    var fbNameDidChange: ((SideMenuTableViewModelProtocol) -> ())? { get set }
    var usernameDidChange: ((SideMenuTableViewModelProtocol) -> ())? { get set }
    var scoreDidChange: ((SideMenuTableViewModelProtocol) -> ())? { get set }
    
    init(context: NSManagedObjectContext)
    
    func resetLabelValues()
}

class SideMenuTableViewModel: SideMenuTableViewModelProtocol {
    
    var owner: Owner? { didSet { setOwnerLabels() } }
    
    var username: String? { didSet { self.usernameDidChange?(self) } }
    var score: String? { didSet { self.scoreDidChange?(self) } }
    var fbName: String? { didSet { self.fbNameDidChange?(self) } }
    
    var usernameDidChange: ((SideMenuTableViewModelProtocol) -> ())?
    var scoreDidChange: ((SideMenuTableViewModelProtocol) -> ())?
    var fbNameDidChange: ((SideMenuTableViewModelProtocol) -> ())?
    
    required init(context: NSManagedObjectContext) {
        FBSDKProfile.enableUpdates(onAccessTokenChange: true) // also set in settings
        fetchOwner(context: context)
        fetchFBProfile()
    }
    
    func resetLabelValues() {
        setOwnerLabels()
        fetchFBProfile()
    }
    
    func fetchOwner(context: NSManagedObjectContext) {
        if owner == nil,
            case let owner?? = try? Owner.get(context: context) {
            self.owner = owner
        }
    }
    
    func setOwnerLabels() {
        if let owner = owner,
            let ownerUsername = owner.username {
            username = ownerUsername
            score = String(describing: owner.totalScore)
        }
    }
    
    func fetchFBProfile() {
        if FBSDKAccessToken.current() != nil {
            if let profile = FBSDKProfile.current() {
                fbName = profile.firstName
            }
        } else {
            fbName = nil
        }
    }
    
}
