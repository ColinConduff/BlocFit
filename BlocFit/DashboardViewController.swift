//
//  DashboardViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, MapDashboardDelegate {
    
    @IBOutlet weak var distanceUnitsLabel: UILabel!
    @IBOutlet weak var rateUnitsLabel: UILabel!
    
    @IBOutlet weak var blocMemberCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateUnitLabels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCountLabel(blocMembersCount: Int) {
        blocMemberCountLabel!.text = String(blocMembersCount + 1) // + 1 for owner
    }
    
    func setTimeLabel(totalSeconds: Double) {
        timeLabel?.text = BFFormatter.stringFrom(totalSeconds: totalSeconds)
    }
    
    func setDistanceLabel(newDistance: Double) {
        let convertedDistance = performUnitConversionOn(distance: newDistance)
        let formattedString = BFFormatter.stringFrom(number: convertedDistance)
        
        distanceLabel?.text = formattedString
    }
    
    func setRateLabel(seconds: Double, distance: Double) {
        if distance > 0 {
            let secondsPerMile = seconds / performUnitConversionOn(distance: distance)
            rateLabel?.text = BFFormatter.stringFrom(totalSeconds: secondsPerMile)
        }
        
        updateUnitLabels()
    }
    
    func performUnitConversionOn(distance: Double) -> Double {
        
        let isImperialUnits = BFUserDefaults.getUnitsSetting()
        
        let convertedDistance = BFUnitConverter.distanceFrom(
            meters: distance,
            isImperial: isImperialUnits)
        
        return convertedDistance
    }
    
    func setScoreLabel(newScore: Int) {
        scoreLabel?.text = String(newScore)
    }
    
    func updateUnitLabels() {
        let isImperialUnits = BFUserDefaults.getUnitsSetting()
        let unitLabels = BFUnitConverter.unitLabels(isImperialUnits: isImperialUnits)
        
        distanceUnitsLabel?.text = unitLabels.distance
        rateUnitsLabel?.text = unitLabels.rate
    }
}
