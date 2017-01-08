//
//  RunHistoryTableController.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/25/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

// Refactor this
protocol SelectRowAndLoadRunProtocol: class {
    func didSelectRow(indexPath: IndexPath,
                      loadRunDelegate: LoadRunDelegate,
                      navController: UINavigationController)
}

class RunHistoryTableController: FRCTableViewDataSource, SelectRowAndLoadRunProtocol {
    
    private let imperialUnits: Bool
    
    init(tableView: UITableView, context: NSManagedObjectContext) {
        imperialUnits = BFUserDefaults.getUnitsSetting()
        super.init(tableView: tableView)
        getRuns(context: context)
    }
    
    // MARK: - Table view data source
    
    private static let reuseIdentifier = "runHistoryTableCell"
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RunHistoryTableController.reuseIdentifier,
            for: indexPath) as? RunHistoryTableViewCell
        
        if let run = fetchedResultsController?.object(at: indexPath) as? Run {
            cell?.controller = RunHistoryCellController(run: run, usingImperialUnits: imperialUnits)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let run = fetchedResultsController?.object(at: indexPath) as? Run {
                try? run.delete()
            }
        }
    }
    
    func didSelectRow(indexPath: IndexPath,
                      loadRunDelegate: LoadRunDelegate,
                      navController: UINavigationController) {
        
        if let run = fetchedResultsController?.object(at: indexPath) as? Run {
            loadRunDelegate.tellMapToLoadRun(run: run)
            let _ = navController.popViewController(animated: true)
        }
    }
    
    private func getRuns(context: NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSManagedObject>(entityName: Run.entityName)
    
        request.sortDescriptors = [NSSortDescriptor(
            key: Run.startTime,
            ascending: false
            )]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: Run.startDateShortFormat,
            cacheName: nil)
    }
}
