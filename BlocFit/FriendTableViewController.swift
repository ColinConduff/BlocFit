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
    var blocMembers = [BlocMember]()
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
        didSet {
            getBlocMembers()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBlocMembers()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    static let reuseIdentifier = "friendTableCell"
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FriendTableViewController.reuseIdentifier,
            for: indexPath) as? FriendTableViewCell
        
        if let blocMember = fetchedResultsController?.object(at: indexPath) as? BlocMember {
            cell?.usernameLabel?.text = blocMember.username
            cell?.trustedLabel?.text = getStringFor(trusted: blocMember.trusted)
            
            if let firstname = blocMember.firstname {
                cell?.firstnameLabel?.text = firstname
            } else {
                cell?.firstnameLabel?.isHidden = true
            }
            cell?.scoreLabel?.text = String(blocMember.totalScore)
        }
            
        return cell!
    }
    
    func getStringFor(trusted: Bool) -> String {
        return trusted ? "Trusted" : "Untrusted"
    }
    
    override func tableView(
        _ tableView: UITableView,
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
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FriendTableViewController.reuseIdentifier,
            for: indexPath)
        
        if let blocMember = fetchedResultsController?.object(at: indexPath) as? BlocMember {
            cell.detailTextLabel?.text = getStringFor(trusted: blocMember.trusted)
            do {
                try blocMember.update(trusted: !blocMember.trusted)
            } catch let error {
                print(error)
            }
        }
    }
    
    func getBlocMembers() {
        if let context = context {
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
        } else {
            fetchedResultsController = nil
        }
    }
}
