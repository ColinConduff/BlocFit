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
    
    @IBOutlet weak var medianScoreLabel: UILabel!
    @IBOutlet weak var medianRateLabel: UILabel!
    @IBOutlet weak var medianDistanceLabel: UILabel!
    @IBOutlet weak var medianTimeLabel: UILabel!
    
    var viewModel: StatisticsViewModelProtocol! {
        didSet {
            self.viewModel.medianRunDidChange = { [unowned self] viewModel in
                self.medianScoreLabel?.text = self.viewModel.medianRunValues?.score
                self.medianRateLabel?.text = self.viewModel.medianRunValues?.rate
                self.medianDistanceLabel?.text = self.viewModel.medianRunValues?.distance
                self.medianTimeLabel?.text = self.viewModel.medianRunValues?.time
            }
            self.viewModel.bestRunDidChange = { [unowned self] viewModel in
                self.bestScoreLabel?.text = self.viewModel.bestRunValues?.score
                self.bestRateLabel?.text = self.viewModel.bestRunValues?.rate
                self.bestDistanceLabel?.text = self.viewModel.bestRunValues?.distance
                self.bestTimeLabel?.text = self.viewModel.bestRunValues?.time
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.viewModel = StatisticsViewModel(context: context)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.resetLabelValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
