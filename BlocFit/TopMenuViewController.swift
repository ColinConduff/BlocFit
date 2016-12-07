//
//  TopMenuViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class TopMenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func openSideMenu(_ sender: UIButton) {
        if let mainViewController = parent as? MainViewController {
            mainViewController.toggleSideMenu()
        }
    }
    @IBAction func didClickBlocMemberButton(_ sender: UIButton) {
        if let mainViewController = parent as? MainViewController {
            mainViewController.performSegue(
                withIdentifier: SegueIdentifier.currentBlocTableSegue,
                sender: mainViewController)
        }
    }
    @IBAction func didClickMultipeerButton(_ sender: UIButton) {
        if let mainViewController = parent as? MainViewController {
            mainViewController.presentMCBrowserAndStartMCAssistant()
        }
    }
}
