//
//  RunHistoryTableViewCell.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/13/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class RunHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var numRunnersLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var Controller: RunHistoryCellController? {
        didSet {
            guard let controller = Controller else { return }
            
            timeIntervalLabel?.text = controller.time
            scoreLabel?.text = controller.score
            numRunnersLabel?.text = controller.numRunners
            paceLabel?.text = controller.pace
            distanceLabel?.text = controller.distance
        }
    }

}
