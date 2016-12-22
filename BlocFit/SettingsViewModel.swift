//
//  SettingsViewModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/22/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

protocol SettingsViewModelProtocol: class {
    
    var settingsModel: SettingsModel { get }
    
    var units: String? { get }
    var defaultTrusted: String? { get }
    var shareFirstName: String? { get }
    
    var unitsDidChange: ((SettingsViewModelProtocol) -> ())? { get set }
    var defaultTrustedDidChange: ((SettingsViewModelProtocol) -> ())? { get set }
    var shareFirstNameDidChange: ((SettingsViewModelProtocol) -> ())? { get set }
    
    init()
    
    func resetLabelValues()
    
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
    
    private func createSettingsModel(
        isImperialUnits: Bool = BFUserDefaults.getUnitsSetting(),
        willDefaultToTrusted: Bool = BFUserDefaults.getNewFriendDefaultTrustedSetting(),
        willShareFirstName: Bool = BFUserDefaults.getShareFirstNameWithTrustedSetting()) {
        
        self.settingsModel = SettingsModel(
            isImperialUnits: isImperialUnits,
            willDefaultToTrusted: willDefaultToTrusted,
            willShareFirstName: willShareFirstName)
    }
    
    func resetLabelValues() {
        showUnits()
        showDefaultTrusted()
        showShareFirstName()
    }
    
    private func showUnits() {
        self.units = BFUserDefaults.stringFor(unitsSetting: settingsModel.isImperialUnits)
    }
    private func showDefaultTrusted() {
        self.defaultTrusted = BFUserDefaults.stringFor(
            friendsWillDefaultToTrusted: settingsModel.willDefaultToTrusted)
    }
    private func showShareFirstName() {
        self.shareFirstName = BFUserDefaults.stringFor(
            willShareFirstNameWithTrustedFriends: settingsModel.willShareFirstName)
    }
    
    func toggleUnitsSetting() {
        let newUnitsSetting = !settingsModel.isImperialUnits
        self.units = BFUserDefaults.stringFor(unitsSetting: newUnitsSetting)
        
        BFUserDefaults.set(isImperial: newUnitsSetting)
        createSettingsModel(isImperialUnits: newUnitsSetting)
    }
    
    func toggleTrustedDefaultSetting() {
        let newTrustedDefaultSetting = !settingsModel.willDefaultToTrusted
        self.defaultTrusted = BFUserDefaults.stringFor(
            friendsWillDefaultToTrusted: newTrustedDefaultSetting)
        
        BFUserDefaults.set(friendsWillDefaultToTrusted: newTrustedDefaultSetting)
        createSettingsModel(willDefaultToTrusted: newTrustedDefaultSetting)
    }
    
    func toggleShareFirstNameSetting() {
        let newShareNameSetting = !settingsModel.willShareFirstName
        self.shareFirstName = BFUserDefaults.stringFor(
            willShareFirstNameWithTrustedFriends: newShareNameSetting)
        
        BFUserDefaults.set(willShareFirstNameWithTrustedFriends: newShareNameSetting)
        createSettingsModel(willShareFirstName: newShareNameSetting)
    }
}
