//
//  RunHistoryTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

class RunHistoryTableViewController: UITableViewController {
    
    var dataSource: FRCTableViewDataSource?
    weak var loadRunDelegate: LoadRunDelegate?
    var didSelectDelegate: SelectRowAndLoadRunProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let runHistoryTableViewModel = RunHistoryTableViewModel(tableView: tableView, context: context)
        dataSource = runHistoryTableViewModel
        didSelectDelegate = runHistoryTableViewModel
        tableView.dataSource = dataSource
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectDelegate?.didSelectRow(indexPath: indexPath,
                                               loadRunDelegate: loadRunDelegate!,
                                               navController: navigationController!)
    }
}
