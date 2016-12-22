//
//  StatisticsViewModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/22/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import CoreData

protocol StatisticsViewModelProtocol: class {
    
    var medianRunModel: StatisticsRunModel? { get }
    var bestRunModel: StatisticsRunModel? { get }
    
    var medianRunValues: (score: String, time: String, distance: String, rate: String)? { get }
    var bestRunValues: (score: String, time: String, distance: String, rate: String)? { get }
    
    var medianRunDidChange: ((StatisticsViewModelProtocol) -> ())? { get set }
    var bestRunDidChange: ((StatisticsViewModelProtocol) -> ())? { get set }
    
    init(context: NSManagedObjectContext)
    
    func resetLabelValues()
}

class StatisticsViewModel: StatisticsViewModelProtocol {
    
    var medianRunModel: StatisticsRunModel? { didSet { setMedianRunValues() } }
    var bestRunModel: StatisticsRunModel? { didSet { setBestRunValues() } }
    
    var medianRunValues: (score: String, time: String, distance: String, rate: String)? {
        didSet { self.medianRunDidChange?(self) }
    }
    var bestRunValues: (score: String, time: String, distance: String, rate: String)? {
        didSet { self.bestRunDidChange?(self) }
    }
    
    var medianRunDidChange: ((StatisticsViewModelProtocol) -> ())?
    var bestRunDidChange: ((StatisticsViewModelProtocol) -> ())?
    
    private let isImperialUnits: Bool
    private let unitLabels: (distance: String, rate: String)
    
    required init(context: NSManagedObjectContext) {
        isImperialUnits = BFUserDefaults.getUnitsSetting()
        unitLabels = BFUnitConverter.unitLabels(isImperialUnits: isImperialUnits)
        
        getBestRun(context: context)
        getAllRuns(context: context)
    }
    
    func resetLabelValues() {
        setMedianRunValues()
        setBestRunValues()
    }
    
    private func setBestRunValues() {
        if let bestRunModel = bestRunModel {
            self.bestRunValues = getFormattedRunValues(model: bestRunModel)
        }
    }
    
    private func setMedianRunValues() {
        if let medianRunModel = medianRunModel {
            self.medianRunValues = getFormattedRunValues(model: medianRunModel)
        }
    }
    
    private func add(unitLabel: String, toString: String) -> String {
        return toString + " " + unitLabel
    }
    
    private func getFormattedRunValues(model: StatisticsRunModel) -> (score: String, time: String, distance: String, rate: String) {
        
        let distance = BFUnitConverter.distanceFrom(
                meters: model.meters,
                isImperial: isImperialUnits)
        let distanceString = BFFormatter.stringFrom(number: distance)
        let distanceWithUnitLabel = add(
            unitLabel: unitLabels.distance,
            toString: distanceString)
        
        let rate = BFUnitConverter.rateFrom(
            secondsPerMeter: model.rate,
            isImperial: isImperialUnits)
        let rateString = BFFormatter.stringFrom(totalSeconds: rate)
        let rateWithUnitLabel = add(
            unitLabel: unitLabels.rate,
            toString: rateString)
        
        let time = BFFormatter.stringFrom(
            totalSeconds: Double(model.seconds))
        
        return (score: String(model.score),
                time: time,
                distance: distanceWithUnitLabel,
                rate: rateWithUnitLabel)
    }
    
    private func getBestRun(context: NSManagedObjectContext) {
        context.perform {
            let request: NSFetchRequest<Run> = Run.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: Run.score, ascending: false)]
            request.fetchLimit = 1
            
            do {
                if let bestRun = try context.fetch(request).first {
                
                    self.bestRunModel = StatisticsRunModel(score: bestRun.score,
                                                           seconds: bestRun.secondsElapsed,
                                                           meters: bestRun.totalDistanceInMeters,
                                                           rate: bestRun.secondsPerMeter)
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    private func getAllRuns(context: NSManagedObjectContext) {
        context.perform {
            let request: NSFetchRequest<Run> = Run.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: Run.score, ascending: false)]
            request.predicate = NSPredicate(format: "\(Run.score) > 50")
            
            do {
                var allRuns = try context.fetch(request) 
                let medianRunValues = self.calculateMedianRunValues(runs: &allRuns)
                
                self.medianRunModel = StatisticsRunModel(score: medianRunValues.score,
                                                         seconds: medianRunValues.seconds,
                                                         meters: medianRunValues.meters,
                                                         rate: medianRunValues.rate)
            } catch let error {
                print(error)
            }
        }
    }
    
    private func calculateMedianRunValues(runs: inout [Run])
        -> (score: Int32, seconds: Int16, meters: Double, rate: Double) {
            
            if runs.count == 0 {
                return (score: 0, seconds: 0, meters: 0, rate: 0)
            }
            
            let medianScore = runs[runs.count / 2].score
            
            let runsSortedBySeconds = runs.sorted {
                return $0.secondsElapsed < $1.secondsElapsed
            }
            let medianSeconds = runsSortedBySeconds[runs.count / 2].secondsElapsed
            
            let runsSortedByMeters = runs.sorted {
                return $0.totalDistanceInMeters < $1.totalDistanceInMeters
            }
            let medianMeters = runsSortedByMeters[runs.count / 2].totalDistanceInMeters
            
            let runsSortedByRate = runs.sorted {
                return $0.secondsPerMeter < $1.secondsPerMeter
            }
            let medianRate = runsSortedByRate[runs.count / 2].secondsPerMeter
            
            return (score: medianScore, seconds: medianSeconds, meters: medianMeters, rate: medianRate)
    }
}
