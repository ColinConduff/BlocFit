//
//  BFFormatter.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/9/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

struct BFFormatter {
    
    static let numberFormatter = NumberFormatter()
    static let dateFormatter = DateFormatter()
    static let dateIntervalFormatter = DateIntervalFormatter()

    static func stringFrom(number: Double, maxDigits: Int = 2) -> String {
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maxDigits
        numberFormatter.roundingMode = .up
        
        return numberFormatter.string(from: (number as NSNumber))!
    }
    
    static func stringFrom(totalSeconds: Double) -> String {
        
        let time = BFUnitConverter.hoursMinutesAndSecondsFrom(totalSeconds: totalSeconds)
        
        let hours = Int(time.hours)
        let minutes = Int(time.minutes)
        let seconds = Int(time.seconds)
        
        if totalSeconds >= 3600 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else if minutes > 9 {
            return String(format: "%02i:%02i", minutes, seconds)
        } else {
            return String(format: "%0i:%02i", minutes, seconds)
        }
    }
}
