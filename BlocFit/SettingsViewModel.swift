//
//  SettingsViewModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/22/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

protocol SettingsViewModelProtocol: class {
    var units: String? { get }
    var defaultTrusted: String? { get }
    var shareFirstName: String? { get }
    
    var unitsDidChange: ((SettingsViewModelProtocol) -> ())? { get set }
    var defaultTrustedDidChange: ((SettingsViewModelProtocol) -> ())? { get set }
    var shareFirstNameDidChange: ((SettingsViewModelProtocol) -> ())? { get set }
    
    init()
    
    func resetLabelValues()
    
    func showUnits()
    func showDefaultTrusted()
    func showShareFirstName()
    
    func toggleUnitsSetting()
    func toggleTrustedDefaultSetting()
    func toggleShareFirstNameSetting()
}

class SettingsViewModel: SettingsViewModelProtocol {
    
    var settingsModel: SettingsModel
    
    var units: String? { didSet { self.unitsDidChange?(self) } }
    var defaultTrusted: String? { didSet { self.defaultTrustedDidChange?(self) } }
    var shareFirstName: String? { didSet { self.shareFirstNameDidChange?(self) } }
    
    var unitsDidChange: ((SettingsViewModelProtocol) -> ())?
    var defaultTrustedDidChange: ((SettingsViewModelProtocol) -> ())?
    var shareFirstNameDidChange: ((SettingsViewModelProtocol) -> ())?
    
    required init() {
        self.settingsModel = SettingsModel(
            isImperialUnits: BFUserDefaults.getUnitsSetting(),
            willDefaultToTrusted: BFUserDefaults.getNewFriendDefaultTrustedSetting(),
            willShareFirstName: BFUserDefaults.getShareFirstNameWithTrustedSetting())
    }
    
    func resetLabelValues() {
        showUnits()
        showDefaultTrusted()
        showShareFirstName()
    }
    
    func showUnits() {
        self.units = BFUserDefaults.stringFor(unitsSetting: settingsModel.isImperialUnits)
    }
    func showDefaultTrusted() {
        self.defaultTrusted = BFUserDefaults.stringFor(
            friendsWillDefaultToTrusted: settingsModel.willDefaultToTrusted)
    }
    func showShareFirstName() {
        self.shareFirstName = BFUserDefaults.stringFor(
            willShareFirstNameWithTrustedFriends: settingsModel.willShareFirstName)
    }
    
    func toggleUnitsSetting() {
        settingsModel.isImperialUnits = !settingsModel.isImperialUnits
        self.units = BFUserDefaults.stringFor(unitsSetting: settingsModel.isImperialUnits)
        BFUserDefaults.set(isImperial: settingsModel.isImperialUnits)
    }
    
    func toggleTrustedDefaultSetting() {
        settingsModel.willDefaultToTrusted = !settingsModel.willDefaultToTrusted
        self.defaultTrusted = BFUserDefaults.stringFor(
            friendsWillDefaultToTrusted: settingsModel.willDefaultToTrusted)
        BFUserDefaults.set(friendsWillDefaultToTrusted: settingsModel.willDefaultToTrusted)
    }
    
    func toggleShareFirstNameSetting() {
        settingsModel.willShareFirstName = !settingsModel.willShareFirstName
        self.shareFirstName = BFUserDefaults.stringFor(
            willShareFirstNameWithTrustedFriends: settingsModel.willShareFirstName)
        BFUserDefaults.set(willShareFirstNameWithTrustedFriends: settingsModel.willShareFirstName)
    }
}
