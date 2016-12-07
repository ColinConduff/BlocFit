//
//  RunHistoryTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

class RunHistoryTableViewController: BaseTableViewController {
    
    weak var loadRunDelegate: LoadRunDelegate?
    
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
        didSet {
            getRuns()
        }
    }
    
    var imperial: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRuns()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    static let reuseIdentifier = "runHistoryTableCell"
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RunHistoryTableViewController.reuseIdentifier,
            for: indexPath) as? RunHistoryTableViewCell
            
        if let run = fetchedResultsController?.object(at: indexPath) as? Run {
            if let start = run.startTime as? Date,
                let end = run.endTime as? Date,
                let blocMemberCount = run.blocMembers?.count {
                
                cell?.timeIntervalLabel?.text = getTimeInterval(start: start, end: end)
                cell?.scoreLabel?.text = String(run.score) + " Pts"
                cell?.numRunnersLabel?.text = getRunnersLabel(blocMemberCount: blocMemberCount)
                
                if imperial == nil {
                    imperial = BFUserDefaults.getUnitsSetting()
                }
                
                if let imperial = imperial {
                    let unitLabels = BFUnitConverter.unitLabels(isImperialUnits: imperial)
                    
                    cell?.paceLabel?.text = getRateString(
                        imperial: imperial,
                        secondsPerMeter: run.secondsPerMeter,
                        label: unitLabels.rate)
                    
                    cell?.distanceLabel?.text = getDistanceString(
                        imperial: imperial,
                        meters: run.totalDistanceInMeters,
                        label: unitLabels.distance)
                }
            }
        }
            
        return cell!
    }
    
    func getRunnersLabel(blocMemberCount: Int) -> String {
        let numRunners = blocMemberCount + 1
        let label = numRunners > 1 ? " Runners" : " Runner"
        return String(numRunners) + label
    }
    
    func add(unitLabel: String, toString: String) -> String {
        return toString + " " + unitLabel
    }
    
    func getRateString(imperial: Bool, secondsPerMeter: Double, label: String) -> String {
        let convertedRate = BFUnitConverter.rateFrom(
            secondsPerMeter: secondsPerMeter, isImperial: imperial)
        let rateString = BFFormatter.stringFrom(totalSeconds: convertedRate)
        let rateWithUnitLabel = add(
            unitLabel: label,
            toString: rateString)
        return rateWithUnitLabel
    }
    
    func getDistanceString(imperial: Bool, meters: Double, label: String) -> String {
        let convertedDistance = BFUnitConverter.distanceFrom(
            meters: meters, isImperial: imperial)
        let distanceString = BFFormatter.stringFrom(number: convertedDistance)
        let distanceWithUnitLabel = add(
            unitLabel: label,
            toString: distanceString)
        return distanceWithUnitLabel
    }
    
    func getFormattedDateString(date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func getTimeInterval(start: Date, end: Date) -> String? {
        let formatter = DateIntervalFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        
        return formatter.string(from: start, to: end)
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let run = fetchedResultsController?.object(at: indexPath) as? Run {
                do {
                    try run.delete()
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let run = fetchedResultsController?.object(at: indexPath) as? Run {
            loadRunDelegate?.tellMapToLoadRun(run: run)
            let _ = navigationController!.popViewController(animated: true)
        }
    }
    
    func getRuns() {
        if let context = context {
            
            let request = NSFetchRequest<NSManagedObject>(entityName: Run.entityName)
//            request.predicate = NSPredicate(format: "\(Run.score) > 20")
            request.sortDescriptors = [NSSortDescriptor(
                key: Run.startTime,
                ascending: false
                )]
            
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: Run.startDateShortFormat,
                cacheName: nil)
        } else {
            fetchedResultsController = nil
        }
    }
}
