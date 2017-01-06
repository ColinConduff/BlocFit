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
    
    var viewModel: DashboardViewModelProtocol! {
        didSet {
            viewModel.totalRunnersCountDidChange = { [unowned self] viewModel in
                self.blocMemberCountLabel?.text = viewModel.totalRunnersCount
            }
            viewModel.timeDidChange = { [unowned self] viewModel in
                self.timeLabel.text = viewModel.time
            }
            viewModel.scoreDidChange = { [unowned self] viewModel in
                self.scoreLabel.text = viewModel.score
            }
            viewModel.distanceRateUnitsDidChange = { [unowned self] viewModel in
                self.distanceLabel.text = viewModel.distance
                self.rateLabel.text = viewModel.rate
                self.distanceUnitsLabel.text = viewModel.distanceUnit
                self.rateUnitsLabel.text = viewModel.rateUnit
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.unitsMayHaveChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
