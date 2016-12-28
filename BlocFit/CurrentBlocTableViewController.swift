//
//  CurrentBlocTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/13/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

protocol SyncBlocMembersProtocol: class {
    func sync(blocMembers: [BlocMember])
}

class CurrentBlocTableViewController: UITableViewController, SyncBlocMembersProtocol {
    
    var currentBlocTableViewModel: UITableViewDataSource?
    
    // passed in from mainVC through segue
    // synchronized with datasource
    // sent back to mainVC through unwind segue
    var blocMembers = [BlocMember]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        currentBlocTableViewModel = CurrentBlocTableViewModel(tableView: tableView, blocMembers: &blocMembers, syncDelegate: self)
        tableView.dataSource = currentBlocTableViewModel
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // SyncBlocMembersProtocol method
    
    func sync(blocMembers: [BlocMember]) {
        self.blocMembers = blocMembers
    }
}
