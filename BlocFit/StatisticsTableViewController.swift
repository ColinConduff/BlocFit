//
//  StatisticsTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

class StatisticsTableViewController: UITableViewController {
    
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var bestRateLabel: UILabel!
    @IBOutlet weak var bestDistanceLabel: UILabel!
    @IBOutlet weak var bestTimeLabel: UILabel!
    
    @IBOutlet weak var medianScoreLabel: UILabel!
    @IBOutlet weak var medianRateLabel: UILabel!
    @IBOutlet weak var medianDistanceLabel: UILabel!
    @IBOutlet weak var medianTimeLabel: UILabel!
    
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var isImperial: Bool?
    var unitLabels: (distance: String, rate: String)?
    
    var bestRun: Run? {
        didSet {
            if let isImperial = isImperial,
                let unitLabels = unitLabels {
                setBestRunLabels(isImperial: isImperial, withUnitLabels: unitLabels)
            }
        }
    }
    var medianRunValues: (score: Int32, seconds: Int16, meters: Double, rate: Double)? {
        didSet {
            if let isImperial = isImperial,
                let unitLabels = unitLabels {
                setMedianRunLabels(isImperial: isImperial, withUnitLabels: unitLabels)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isImperial = BFUserDefaults.getUnitsSetting()
        
        if let isImperial = isImperial {
            unitLabels = BFUnitConverter.unitLabels(isImperialUnits: isImperial)
        }
        
        getBestRun()
        getAllRuns()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func add(unitLabel: String, toString: String) -> String {
        return toString + " " + unitLabel
    }
    
    func setBestRunLabels(
        isImperial: Bool,
        withUnitLabels unitLabels: (distance: String, rate: String)) {
        
        if let bestRun = bestRun {
            let distance = BFUnitConverter.distanceFrom(
                meters: bestRun.totalDistanceInMeters,
                isImperial: isImperial)
            let distanceString = BFFormatter.stringFrom(number: distance)
            let distanceWithUnitLabel = add(
                unitLabel: unitLabels.distance,
                toString: distanceString)
            
            let rate = BFUnitConverter.rateFrom(
                secondsPerMeter: bestRun.secondsPerMeter,
                isImperial: isImperial)
            let rateString = BFFormatter.stringFrom(totalSeconds: rate)
            let rateWithUnitLabel = add(
                unitLabel: unitLabels.rate,
                toString: rateString)
            
            let time = BFFormatter.stringFrom(
                totalSeconds: Double(bestRun.secondsElapsed))
            
            bestScoreLabel?.text = String(bestRun.score)
            bestRateLabel?.text = rateWithUnitLabel
            bestDistanceLabel?.text = distanceWithUnitLabel
            bestTimeLabel?.text = time
        }
    }
    
    func setMedianRunLabels(
        isImperial: Bool,
        withUnitLabels unitLabels: (distance: String, rate: String)) {
        
        if let medianRunValues = medianRunValues {
            let distance = BFUnitConverter.distanceFrom(
                meters: medianRunValues.meters,
                isImperial: isImperial)
            let distanceString = BFFormatter.stringFrom(number: distance)
            let distanceWithUnitLabel = add(
                unitLabel: unitLabels.distance,
                toString: distanceString)
            
            let rate = BFUnitConverter.rateFrom(
                secondsPerMeter: medianRunValues.rate,
                isImperial: isImperial)
            let rateString = BFFormatter.stringFrom(totalSeconds: rate)
            let rateWithUnitLabel = add(
                unitLabel: unitLabels.rate,
                toString: rateString)
            
            let time = BFFormatter.stringFrom(totalSeconds: Double(medianRunValues.seconds))
            
            medianScoreLabel?.text = String(medianRunValues.score)
            medianRateLabel?.text = rateWithUnitLabel
            medianDistanceLabel?.text = distanceWithUnitLabel
            medianTimeLabel?.text = time
        }
    }
    
    func getBestRun() {
        context?.perform {
            let request: NSFetchRequest<Run> = Run.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: Run.score, ascending: false)]
            request.fetchLimit = 1
            
            do {
                self.bestRun = try self.context?.fetch(request).first
            } catch let error {
                print(error)
            }
        }
    }
    
    func calculateMedianRunValues(runs: inout [Run])
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
    
    func getAllRuns() {
        context?.perform {
            let request: NSFetchRequest<Run> = Run.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: Run.score, ascending: false)]
            request.predicate = NSPredicate(format: "\(Run.score) > 50")
            
            do {
                var allRuns = try self.context?.fetch(request) ?? [Run]()
                self.medianRunValues = self.calculateMedianRunValues(runs: &allRuns)
                
            } catch let error {
                print(error)
            }
        }
    }

}
