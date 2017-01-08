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
    
    var controller: StatisticsControllerProtocol! {
        didSet {
            self.controller.averageRunDidChange = { [unowned self] controller in
                self.averageScoreLabel?.text = self.controller.averageRunValues?.score
                self.averageRateLabel?.text = self.controller.averageRunValues?.rate
                self.averageDistanceLabel?.text = self.controller.averageRunValues?.distance
                self.averageTimeLabel?.text = self.controller.averageRunValues?.time
            }
            self.controller.bestRunDidChange = { [unowned self] controller in
                self.bestScoreLabel?.text = self.controller.bestRunValues?.score
                self.bestRateLabel?.text = self.controller.bestRunValues?.rate
                self.bestDistanceLabel?.text = self.controller.bestRunValues?.distance
                self.bestTimeLabel?.text = self.controller.bestRunValues?.time
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        controller = StatisticsController(context: context)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        controller.resetLabelValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
