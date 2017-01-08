//
//  CurrentBlocTableViewC.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/13/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class CurrentBlocTableViewC: UITableViewController {
    
    var currentBlocTableDataSource: CurrentBlocTableDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        currentBlocTableDataSource.tableView = tableView
        tableView.dataSource = currentBlocTableDataSource
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
