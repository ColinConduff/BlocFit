//
//  MapRunModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 1/8/17.
//  Copyright © 2017 Colin Conduff. All rights reserved.
//

import Foundation

// Combine with dashboard model?
struct MapRunModel {
    let secondsElapsed: Double
    let score: Int
    let totalDistanceInMeters: Double
    let secondsPerMeter: Double
    
    init(secondsElapsed: Double, score: Int, totalDistanceInMeters: Double, secondsPerMeter: Double) {
        self.secondsElapsed = secondsElapsed
        self.score = score
        self.totalDistanceInMeters = totalDistanceInMeters
        self.secondsPerMeter = secondsPerMeter
    }
}
