//
//  DashboardViewModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/28/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

protocol DashboardViewModelProtocol: class {
    
    var dashboardModel: DashboardModel { get }
    
    var totalRunnersCount: String? { get }
    var time: String? { get }
    var distance: String? { get }
    var rate: String? { get }
    var score: String? { get }
    var distanceUnit: String? { get }
    var rateUnit: String? { get }
    
    var totalRunnersCountDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var timeDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var distanceRateUnitsDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    var scoreDidChange: ((DashboardViewModelProtocol) -> ())? { get set }
    
    init()
    
    func update(blocMembersCount: Int)
    func update(totalSeconds: Double)
    func update(meters: Double, secondsPerMeter: Double)
    func update(score: Int)
    
    func unitsMayHaveChanged()
}

class DashboardViewModel: DashboardViewModelProtocol {
    
    var dashboardModel: DashboardModel
    
    var totalRunnersCount: String? { didSet { self.totalRunnersCountDidChange?(self) } }
    var time: String? { didSet { self.timeDidChange?(self) } }
    var score: String? { didSet { self.scoreDidChange?(self) } }
    var distance: String? { didSet { self.distanceRateUnitsDidChange?(self) } }
    var rate: String? { didSet { self.distanceRateUnitsDidChange?(self) } }
    var distanceUnit: String? { didSet { self.distanceRateUnitsDidChange?(self) } }
    var rateUnit: String? { didSet { self.distanceRateUnitsDidChange?(self) } }
    
    var totalRunnersCountDidChange: ((DashboardViewModelProtocol) -> ())?
    var timeDidChange: ((DashboardViewModelProtocol) -> ())?
    var scoreDidChange: ((DashboardViewModelProtocol) -> ())?
    var distanceRateUnitsDidChange: ((DashboardViewModelProtocol) -> ())?
    
    required init() {
        dashboardModel = DashboardModel(secondsPerMeter: 0,
                                        meters: 0,
                                        imperialUnits: BFUserDefaults.getUnitsSetting())
    }
    
    func update(blocMembersCount: Int) {
        totalRunnersCount = String(describing: blocMembersCount + 1)
    }
    func update(totalSeconds: Double) {
        time = BFFormatter.stringFrom(totalSeconds: totalSeconds)
    }
    func update(meters: Double, secondsPerMeter: Double) {
        dashboardModel = DashboardModel(secondsPerMeter: secondsPerMeter,
                                        meters: meters,
                                        imperialUnits: BFUserDefaults.getUnitsSetting())
        
        let convertedDistance = BFUnitConverter.distanceFrom(meters: dashboardModel.meters,isImperial: dashboardModel.imperialUnits)
        distance = BFFormatter.stringFrom(number: convertedDistance)
        
        let convertedRate = BFUnitConverter.rateFrom(secondsPerMeter: dashboardModel.secondsPerMeter, isImperial: dashboardModel.imperialUnits)
        rate = BFFormatter.stringFrom(totalSeconds: convertedRate)
        
        let unitLabels = BFUnitConverter.unitLabels(isImperialUnits: dashboardModel.imperialUnits)
        distanceUnit = unitLabels.distance
        rateUnit = unitLabels.rate
    }
    func update(score: Int) {
        self.score = String(score)
    }
    
    func unitsMayHaveChanged() {
        // units may have been changed in settings
        // so recalculate conversions and create new model
        update(meters: dashboardModel.meters, secondsPerMeter: dashboardModel.secondsPerMeter)
    }
}
