//
//  RunStatisticsModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/22/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

struct RunStatisticsModel {
    let score: Int32
    let seconds: Int16
    let meters: Double
    let rate: Double
    
    init(score: Int32, seconds: Int16, meters: Double, rate: Double) {
        self.score = score
        self.seconds = seconds
        self.meters = meters
        self.rate = rate
    }
}
