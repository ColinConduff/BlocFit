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
    
    var viewModel: StatisticsViewModelProtocol! {
        didSet {
            self.viewModel.averageRunDidChange = { [unowned self] viewModel in
                self.averageScoreLabel?.text = self.viewModel.averageRunValues?.score
                self.averageRateLabel?.text = self.viewModel.averageRunValues?.rate
                self.averageDistanceLabel?.text = self.viewModel.averageRunValues?.distance
                self.averageTimeLabel?.text = self.viewModel.averageRunValues?.time
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
