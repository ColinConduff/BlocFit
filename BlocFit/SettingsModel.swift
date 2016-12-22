//
//  SettingsModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/22/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

struct SettingsModel {
    var isImperialUnits: Bool
    var willDefaultToTrusted: Bool
    var willShareFirstName: Bool
    
    init(isImperialUnits: Bool,
         willDefaultToTrusted: Bool,
         willShareFirstName: Bool) {
        self.isImperialUnits = isImperialUnits
        self.willDefaultToTrusted = willDefaultToTrusted
        self.willShareFirstName = willShareFirstName
    }
}
