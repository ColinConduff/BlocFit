//
//  DashboardViewC.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class DashboardViewC: UIViewController {
    
    @IBOutlet weak var distanceUnitsLabel: UILabel!
    @IBOutlet weak var rateUnitsLabel: UILabel!
    
    @IBOutlet weak var blocMemberCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var controller: DashboardControllerProtocol! {
        didSet {
            controller.totalRunnersCountDidChange = { [unowned self] controller in
                self.blocMemberCountLabel?.text = controller.totalRunnersCount
            }
            controller.timeDidChange = { [unowned self] controller in
                self.timeLabel.text = controller.time
            }
            controller.scoreDidChange = { [unowned self] controller in
                self.scoreLabel.text = controller.score
            }
            controller.distanceRateUnitsDidChange = { [unowned self] controller in
                self.distanceLabel.text = controller.distance
                self.rateLabel.text = controller.rate
                self.distanceUnitsLabel.text = controller.distanceUnit
                self.rateUnitsLabel.text = controller.rateUnit
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
