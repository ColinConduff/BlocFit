//
//  CurrentBlocTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/13/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class CurrentBlocTableViewController: UITableViewController {
    
    var blocMembers = [BlocMember]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int)
        -> Int {
        return blocMembers.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cellIdentifier = "currentBlocTableViewCell"
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath) as? CurrentBlocTableViewCell
        
        let blocMember = blocMembers[indexPath.row]
            
        cell?.usernameLabel?.text = blocMember.username
        
        if let firstname = blocMember.firstname {
            cell?.firstnameLabel?.text = firstname
        } else {
            cell?.firstnameLabel?.text = ""
        }
        cell?.scoreLabel?.text = String(blocMember.totalScore)
            
        return cell!
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath)
        -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            blocMembers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
