//
//  CurrentBlocTableDataSource.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/25/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

class CurrentBlocTableDataSource: NSObject, UITableViewDataSource {
    
    var blocMembers: [BlocMember]
    weak var tableView: UITableView!
    
    init(blocMembers: [BlocMember]) {
        self.blocMembers = blocMembers
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blocMembers.count
    }
    
    private static let reuseIdentifier = "currentBlocTableViewCell"
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CurrentBlocTableDataSource.reuseIdentifier,
            for: indexPath) as? CurrentBlocTableViewCell
        
        let blocMember = blocMembers[indexPath.row]
        cell?.controller = CurrentBlocCellController(blocMember: blocMember)
        
        return cell!
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            blocMembers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
