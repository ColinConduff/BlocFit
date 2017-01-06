//
//  DashboardModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/28/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

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
