//
//  AppProtocols.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import MultipeerConnectivity

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
