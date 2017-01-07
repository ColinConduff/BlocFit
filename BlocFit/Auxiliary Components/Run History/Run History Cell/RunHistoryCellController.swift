//
//  RunHistoryCellController.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/25/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

protocol RunHistoryCellControllerProtocol: class {
    
    var time: String? { get }
    var score: String? { get }
    var numRunners: String? { get }
    var pace: String? { get }
    var distance: String? { get }
    
    init(run: Run, usingImperialUnits: Bool)
}

class RunHistoryCellController: RunHistoryCellControllerProtocol {
    
    var time: String?
    var score: String?
    var numRunners: String?
    var pace: String?
    var distance: String?
    
    required init(run: Run, usingImperialUnits: Bool) {
        setRunData(run: run, usingImperialUnits: usingImperialUnits)
    }
    
    private func setRunData(run: Run, usingImperialUnits: Bool) {
        if let start = run.startTime as? Date,
            let end = run.endTime as? Date,
            let blocMemberCount = run.blocMembers?.count {
            
            time = timeIntervalString(start: start, end: end)
            score = String(run.score) + " Pts"
            numRunners = runnersLabelText(blocMemberCount: blocMemberCount)
            
            let unitLabels = BFUnitConverter.unitLabels(isImperialUnits: usingImperialUnits)
            
            pace = rateLabelText(
                imperial: usingImperialUnits,
                secondsPerMeter: run.secondsPerMeter,
                label: unitLabels.rate)
            
            distance = distanceLabelText(
                imperial: usingImperialUnits,
                meters: run.totalDistanceInMeters,
                label: unitLabels.distance)
        }
    }
    
    private func runnersLabelText(blocMemberCount: Int) -> String {
        let numRunners = blocMemberCount + 1
        let label = numRunners > 1 ? " Runners" : " Runner"
        return String(numRunners) + label
    }
    
    private func add(unitLabel: String, toString: String) -> String {
        return toString + " " + unitLabel
    }
    
    private func rateLabelText(imperial: Bool, secondsPerMeter: Double, label: String) -> String {
        let convertedRate = BFUnitConverter.rateFrom(
            secondsPerMeter: secondsPerMeter, isImperial: imperial)
        let rateString = BFFormatter.stringFrom(totalSeconds: convertedRate)
        let rateWithUnitLabel = add(
            unitLabel: label,
            toString: rateString)
        return rateWithUnitLabel
    }
    
    private func distanceLabelText(imperial: Bool, meters: Double, label: String) -> String {
        let convertedDistance = BFUnitConverter.distanceFrom(
            meters: meters, isImperial: imperial)
        let distanceString = BFFormatter.stringFrom(number: convertedDistance)
        let distanceWithUnitLabel = add(
            unitLabel: label,
            toString: distanceString)
        return distanceWithUnitLabel
    }
    
    /*
    func formattedDateString(date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    */
    
    private func timeIntervalString(start: Date, end: Date) -> String? {
        let formatter = DateIntervalFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        
        return formatter.string(from: start, to: end)
    }
}
