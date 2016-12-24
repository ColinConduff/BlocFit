//
//  FriendTableViewCell.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/13/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var trustedLabel: UILabel!
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var viewModel: FriendCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            usernameLabel?.text = viewModel.username
            trustedLabel?.text = viewModel.trusted
            firstnameLabel?.text = viewModel.firstname
            firstnameLabel?.isHidden = viewModel.hiddenFirstname ?? false
            scoreLabel?.text = viewModel.score
        }
    }

}
