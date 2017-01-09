//
//  DashboardModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/28/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

/**
 Immutable model for storing the run-values used by the dashboard.
 */
struct DashboardModel {
    let secondsPerMeter: Double
    let meters: Double
    let imperialUnits: Bool
    
    init(secondsPerMeter: Double, meters: Double, imperialUnits: Bool) {
        self.secondsPerMeter = secondsPerMeter
        self.meters = meters
        self.imperialUnits = imperialUnits
    }
}
