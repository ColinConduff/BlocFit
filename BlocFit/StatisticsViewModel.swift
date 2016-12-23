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
    
    var averageRunModel: StatisticsRunModel? { get }
    var bestRunModel: StatisticsRunModel? { get }
    
    var averageRunValues: (score: String, time: String, distance: String, rate: String)? { get }
    var bestRunValues: (score: String, time: String, distance: String, rate: String)? { get }
    
    var averageRunDidChange: ((StatisticsViewModelProtocol) -> ())? { get set }
    var bestRunDidChange: ((StatisticsViewModelProtocol) -> ())? { get set }
    
    init(context: NSManagedObjectContext)
    
    func resetLabelValues()
}

class StatisticsViewModel: StatisticsViewModelProtocol {
    
    var averageRunModel: StatisticsRunModel? { didSet { setAverageRunValues() } }
    var bestRunModel: StatisticsRunModel? { didSet { setBestRunValues() } }
    
    var averageRunValues: (score: String, time: String, distance: String, rate: String)? {
        didSet { self.averageRunDidChange?(self) }
    }
    var bestRunValues: (score: String, time: String, distance: String, rate: String)? {
        didSet { self.bestRunDidChange?(self) }
    }
    
    var averageRunDidChange: ((StatisticsViewModelProtocol) -> ())?
    var bestRunDidChange: ((StatisticsViewModelProtocol) -> ())?
    
    private let isImperialUnits: Bool
    private let unitLabels: (distance: String, rate: String)
    
    required init(context: NSManagedObjectContext) {
        isImperialUnits = BFUserDefaults.getUnitsSetting()
        unitLabels = BFUnitConverter.unitLabels(isImperialUnits: isImperialUnits)
        
        getAverageRun(context: context)
        getBestRun(context: context)
    }
    
    func resetLabelValues() {
        setAverageRunValues()
        setBestRunValues()
    }
    
    private func setBestRunValues() {
        if let bestRunModel = bestRunModel {
            self.bestRunValues = getFormattedRunValues(model: bestRunModel)
        }
    }
    
    private func setAverageRunValues() {
        if let averageRunModel = averageRunModel {
            self.averageRunValues = getFormattedRunValues(model: averageRunModel)
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
    
    private func getAverageRun(context: NSManagedObjectContext) {
        context.perform {
            
            let avgScore = "avgScore"
            let avgRate = "avgRate"
            let avgDistance = "avgDistance"
            let avgTime = "avgTime"
            
            let average = "average:"
            
            let scoreExpDesc = NSExpressionDescription()
            scoreExpDesc.name = avgScore
            scoreExpDesc.expression = NSExpression(forFunction: average, arguments: [NSExpression(forKeyPath: Run.score)])
            
            let rateExpDesc = NSExpressionDescription()
            rateExpDesc.name = avgRate
            rateExpDesc.expression = NSExpression(forFunction: average, arguments: [NSExpression(forKeyPath: Run.secondsPerMeter)])
            
            let distanceExpDesc = NSExpressionDescription()
            distanceExpDesc.name = avgDistance
            distanceExpDesc.expression = NSExpression(forFunction: average, arguments: [NSExpression(forKeyPath: Run.totalDistanceInMeters)])
            
            let timeExpDesc = NSExpressionDescription()
            timeExpDesc.name = avgTime
            timeExpDesc.expression = NSExpression(forFunction: average, arguments: [NSExpression(forKeyPath: Run.secondsElapsed)])
            
            let request = NSFetchRequest<NSDictionary>(entityName: Run.entityName)
            request.propertiesToFetch = [scoreExpDesc, rateExpDesc, distanceExpDesc, timeExpDesc]
            request.resultType = .dictionaryResultType
            
            let results = try! context.fetch(request)
            
            if let dict = results.first as? Dictionary<String, NSString>,
                let score = dict[avgScore]?.intValue,
                let rate = dict[avgRate]?.doubleValue,
                let distance = dict[avgDistance]?.doubleValue,
                let timeString = dict[avgTime]?.intValue {
                
                let time = Int16(timeString)
                
                self.averageRunModel = StatisticsRunModel(score: score,
                                                              seconds: time,
                                                              meters: distance,
                                                              rate: rate)
            }
        }
    }
    
    /*
     // The following functions can be used to find median run values.
     
     // The "median:" function does not work on iOS for NSExpression.
     
     // This following approach pulls all of the runs out of the database,
     // and sorts them repeatedly (very slow, should be avoided).
     
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
 */
}
