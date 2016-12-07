//
//  AppProtocols.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MapDashboardDelegate: class {
    func setCountLabel(blocMembersCount: Int)
    func setTimeLabel(totalSeconds: Double)
    func setDistanceLabel(newDistance: Double)
    func setRateLabel(seconds: Double, distance: Double)
    func setScoreLabel(newScore: Int)
}

protocol LoadRunDelegate: class {
    func tellMapToLoadRun(run: Run)
}

protocol RequestMainDataDelegate: class {
    func getCurrentBlocMembers() -> [BlocMember]
}

protocol ScoreReporterDelegate: class {
    func submitScore(run: Run)
    func submitScore(owner: Owner)
}

protocol SideMenuDelegate: class {
    func setScrollable(isScrollable: Bool)
}
