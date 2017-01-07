//
//  SideMenuTableController.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/27/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import CoreData
import FBSDKLoginKit

protocol SideMenuTableControllerProtocol: class {
    
    var username: String? { get }
    var score: String? { get }
    var fbName: String? { get }
    
    var fbNameDidChange: ((SideMenuTableControllerProtocol) -> ())? { get set }
    var usernameDidChange: ((SideMenuTableControllerProtocol) -> ())? { get set }
    var scoreDidChange: ((SideMenuTableControllerProtocol) -> ())? { get set }
    
    init(context: NSManagedObjectContext)
    
    func resetLabelValues()
}

class SideMenuTableController: SideMenuTableControllerProtocol {
    
    var owner: Owner? { didSet { setOwnerLabels() } }
    
    var username: String? { didSet { self.usernameDidChange?(self) } }
    var score: String? { didSet { self.scoreDidChange?(self) } }
    var fbName: String? { didSet { self.fbNameDidChange?(self) } }
    
    var usernameDidChange: ((SideMenuTableControllerProtocol) -> ())?
    var scoreDidChange: ((SideMenuTableControllerProtocol) -> ())?
    var fbNameDidChange: ((SideMenuTableControllerProtocol) -> ())?
    
    required init(context: NSManagedObjectContext) {
        FBSDKProfile.enableUpdates(onAccessTokenChange: true) // also set in settings
        fetchOwner(context: context)
        fetchFBProfile()
    }
    
    func resetLabelValues() {
        setOwnerLabels()
        fetchFBProfile()
    }
    
    private func fetchOwner(context: NSManagedObjectContext) {
        if owner == nil,
            case let owner?? = try? Owner.get(context: context) {
            self.owner = owner
        }
    }
    
    private func setOwnerLabels() {
        if let owner = owner,
            let ownerUsername = owner.username {
            username = ownerUsername
            score = String(describing: owner.totalScore)
        }
    }
    
    private func fetchFBProfile() {
        if FBSDKAccessToken.current() != nil {
            if let profile = FBSDKProfile.current() {
                fbName = profile.firstName
            }
        } else {
            fbName = nil
        }
    }
    
}
