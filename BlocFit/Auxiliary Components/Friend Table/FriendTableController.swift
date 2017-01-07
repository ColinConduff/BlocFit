//
//  FriendTableController.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/24/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

class FriendTableController: FRCTableViewDataSource {
    
    init(tableView: UITableView, context: NSManagedObjectContext) {
        super.init(tableView: tableView)
        getBlocMembers(context: context)
    }
    
    // MARK: - Table view data source
    private static let reuseIdentifier = "friendTableCell"
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FriendTableController.reuseIdentifier,
            for: indexPath) as? FriendTableViewCell
        
        if let blocMember = fetchedResultsController?.object(at: indexPath) as? BlocMember {
            cell?.Controller = FriendCellController(blocMember: blocMember)
        }
        
        return cell!
    }
    
    func didSelectRow(indexPath: IndexPath) {
        if let blocMember = fetchedResultsController?.object(at: indexPath) as? BlocMember {
            try? blocMember.update(trusted: !blocMember.trusted)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let blocMember = fetchedResultsController?.object(at: indexPath) as? BlocMember {
                try? blocMember.delete()
            }
        }
    }
    
    private func getBlocMembers(context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSManagedObject>(entityName: BlocMember.entityName)
        
        request.sortDescriptors = [NSSortDescriptor(
            key: BlocMember.username,
            ascending: true
            )]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }
}
