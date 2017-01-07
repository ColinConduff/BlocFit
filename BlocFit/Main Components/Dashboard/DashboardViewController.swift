//
//  DashboardViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var distanceUnitsLabel: UILabel!
    @IBOutlet weak var rateUnitsLabel: UILabel!
    
    @IBOutlet weak var blocMemberCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var controller: DashboardControllerProtocol! {
        didSet {
            controller.totalRunnersCountDidChange = { [unowned self] Controller in
                self.blocMemberCountLabel?.text = Controller.totalRunnersCount
            }
            controller.timeDidChange = { [unowned self] Controller in
                self.timeLabel.text = Controller.time
            }
            controller.scoreDidChange = { [unowned self] Controller in
                self.scoreLabel.text = Controller.score
            }
            controller.distanceRateUnitsDidChange = { [unowned self] Controller in
                self.distanceLabel.text = Controller.distance
                self.rateLabel.text = Controller.rate
                self.distanceUnitsLabel.text = Controller.distanceUnit
                self.rateUnitsLabel.text = Controller.rateUnit
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        controller.unitsMayHaveChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
