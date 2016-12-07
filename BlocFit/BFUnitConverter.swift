//
//  BFUnitConverter.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/8/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

struct BFUnitConverter {
    
    static let metersToMilesConversionConstant = 0.000621371
    static let secPerMeterToSecPerMileConstant = 1609.34
    
    static func distanceFrom(meters: Double, isImperial: Bool) -> Double {
        if isImperial {
            return milesFrom(meters: meters)
        } else {
            return kmFrom(meters: meters)
        }
    }
    
    static func rateFrom(secondsPerMeter: Double, isImperial: Bool) -> Double {
        if isImperial {
            return secPerMiFrom(secondsPerMeter: secondsPerMeter)
        } else {
            return secPerKmFrom(secondsPerMeter: secondsPerMeter)
        }
    }
    
    static func secPerMiFrom(secondsPerMeter: Double) -> Double {
        return secondsPerMeter * secPerMeterToSecPerMileConstant
    }
    
    static func secPerKmFrom(secondsPerMeter: Double) -> Double {
        return secondsPerMeter * 1000
    }
    
    static func milesFrom(meters: Double) -> Double {
        return meters * metersToMilesConversionConstant
    }
    
    static func kmFrom(meters: Double) -> Double {
        return meters / 1000
    }
    
    static func hoursMinutesAndSecondsFrom(
        totalSeconds: Double)
        -> (hours: Double, minutes: Double, seconds: Double) {
        
        return (hours: hoursFrom(seconds: totalSeconds),
                minutesFrom(seconds: totalSeconds),
                secondsFrom(totalSeconds: totalSeconds))
    }
    
    static func hoursFrom(seconds: Double) -> Double {
        return seconds / 3600.0
    }
    
    static func minutesFrom(seconds: Double) -> Double {
        return (seconds / 60.0).truncatingRemainder(dividingBy: 60.0)
    }
    
    static func secondsFrom(totalSeconds: Double) -> Double {
        return totalSeconds.truncatingRemainder(dividingBy: 60.0)
    }
    
    static func unitLabels(isImperialUnits: Bool) -> (distance: String, rate: String) {
        if isImperialUnits {
            return (distance: "Mi", rate: "Min / Mi")
        } else {
            return (distance: "Km", rate: "Min / Km")
        }
    }
}
