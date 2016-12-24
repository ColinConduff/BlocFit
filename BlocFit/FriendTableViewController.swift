//
//  FriendTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

class FriendTableViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        getBlocMembers(context: context)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    static let reuseIdentifier = "friendTableCell"
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FriendTableViewController.reuseIdentifier,
            for: indexPath) as? FriendTableViewCell
        
        if let blocMember = fetchedResultsController?.object(at: indexPath) as? BlocMember {
            cell?.viewModel = FriendCellViewModel(blocMember: blocMember)
        }
            
        return cell!
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let blocMember = fetchedResultsController?.object(at: indexPath) as? BlocMember {
                do {
                    try blocMember.delete()
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let blocMember = fetchedResultsController?.object(at: indexPath) as? BlocMember {
            do {
                try blocMember.update(trusted: !blocMember.trusted)
            } catch let error {
                print(error)
            }
        }
    }
    
    func getBlocMembers(context: NSManagedObjectContext) {
        
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
