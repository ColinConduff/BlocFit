//
//  FriendCellViewModel.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/24/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation

protocol FriendCellViewModelProtocol: class {
    
    var username: String? { get }
    var trusted: String? { get }
    var firstname: String? { get }
    var hiddenFirstname: Bool? { get }
    var score: String? { get }
    
    init(blocMember: BlocMember)
}

class FriendCellViewModel: FriendCellViewModelProtocol {
    
    var username: String?
    var trusted: String?
    var firstname: String?
    var hiddenFirstname: Bool?
    var score: String?
    
    required init(blocMember: BlocMember) {
        setBlocMemberData(blocMember: blocMember)
    }
    
    private func setBlocMemberData(blocMember: BlocMember) {
        username = blocMember.username ?? "NA"
        trusted = stringFor(trusted: blocMember.trusted)
        firstname = blocMember.firstname
        hiddenFirstname = (firstname == nil)
        score = String(blocMember.totalScore)
    }
    
    private func stringFor(trusted: Bool) -> String {
        return trusted ? "Trusted" : "Untrusted"
    }
}
