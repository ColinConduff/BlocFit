//
//  BFUserDefaults.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/8/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

struct BFUserDefaults {
    
    static let unitSetting = "unitsSetting"
    static let friendsDefaultTrusted = "friendsDefaultTrusted"
    static let shareFirstNameWithTrusted = "shareFirstNameWithTrusted"
    
    static func stringFor(unitsSetting isImperialUnits: Bool) -> String {
        if isImperialUnits {
            return "Imperial (mi)"
        } else {
            return "Metric (km)"
        }
    }
    
    static func getUnitsSetting() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: BFUserDefaults.unitSetting)
    }
    
    static func set(isImperial: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(isImperial, forKey: BFUserDefaults.unitSetting)
    }
    
    static func stringFor(friendsWillDefaultToTrusted defaultTrusted: Bool) -> String {
        if defaultTrusted {
            return "New friends are trusted by default"
        } else {
            return "New friends are untrusted by default"
        }
    }
    
    static func getNewFriendDefaultTrustedSetting() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: BFUserDefaults.friendsDefaultTrusted)
    }
    
    static func set(friendsWillDefaultToTrusted defaultTrusted: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(defaultTrusted, forKey: BFUserDefaults.friendsDefaultTrusted)
    }
    
    static func stringFor(willShareFirstNameWithTrustedFriends willShareName: Bool) -> String {
        if willShareName {
            return "Share first name with trusted friends"
        } else {
            return "Do not share first name with trusted friends"
        }
    }
    
    static func getShareFirstNameWithTrustedSetting() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: BFUserDefaults.shareFirstNameWithTrusted)
    }
    
    static func set(willShareFirstNameWithTrustedFriends willShareName: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(willShareName, forKey: BFUserDefaults.shareFirstNameWithTrusted)
    }
}
