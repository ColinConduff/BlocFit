//
//  CurrentBlocTableViewCell.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/12/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class CurrentBlocTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
