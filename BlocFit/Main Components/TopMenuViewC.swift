//
//  TopMenuViewC.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class TopMenuViewC: UIViewController {
    
    var topMenuDelegate: TopMenuDelegate! // set by mainVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func openSideMenu(_ sender: UIButton) {
        topMenuDelegate.toggleSideMenu()
    }
    @IBAction func didClickBlocMemberButton(_ sender: UIButton) {
        topMenuDelegate.segueToCurrentBlocTable()
    }
    @IBAction func didClickMultipeerButton(_ sender: UIButton) {
        topMenuDelegate.presentMCBrowserAndStartMCAssistant()
    }
}
