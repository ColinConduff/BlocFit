//
//  StatisticsTableViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class StatisticsTableViewController: UITableViewController {
    
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var bestRateLabel: UILabel!
    @IBOutlet weak var bestDistanceLabel: UILabel!
    @IBOutlet weak var bestTimeLabel: UILabel!
    
    @IBOutlet weak var averageScoreLabel: UILabel!
    @IBOutlet weak var averageRateLabel: UILabel!
    @IBOutlet weak var averageDistanceLabel: UILabel!
    @IBOutlet weak var averageTimeLabel: UILabel!
    
    var Controller: StatisticsControllerProtocol! {
        didSet {
            self.Controller.averageRunDidChange = { [unowned self] Controller in
                self.averageScoreLabel?.text = self.Controller.averageRunValues?.score
                self.averageRateLabel?.text = self.Controller.averageRunValues?.rate
                self.averageDistanceLabel?.text = self.Controller.averageRunValues?.distance
                self.averageTimeLabel?.text = self.Controller.averageRunValues?.time
            }
            self.Controller.bestRunDidChange = { [unowned self] Controller in
                self.bestScoreLabel?.text = self.Controller.bestRunValues?.score
                self.bestRateLabel?.text = self.Controller.bestRunValues?.rate
                self.bestDistanceLabel?.text = self.Controller.bestRunValues?.distance
                self.bestTimeLabel?.text = self.Controller.bestRunValues?.time
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.Controller = StatisticsController(context: context)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        Controller.resetLabelValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
