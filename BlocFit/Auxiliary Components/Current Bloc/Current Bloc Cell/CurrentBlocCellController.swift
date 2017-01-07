//
//  CurrentBlocCellController.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/25/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

protocol CurrentBlocCellControllerProtocol: class {
    
    var username: String? { get }
    var firstname: String? { get }
    var score: String? { get }
    
    init(blocMember: BlocMember)
}

class CurrentBlocCellController: CurrentBlocCellControllerProtocol {
    
    var username: String?
    var firstname: String?
    var score: String?
    
    required init(blocMember: BlocMember) {
        setBlocMemberData(blocMember: blocMember)
    }
    
    private func setBlocMemberData(blocMember: BlocMember) {
        username = blocMember.username ?? "NA"
        firstname = blocMember.firstname ?? ""
        score = String(blocMember.totalScore)
    }
}
