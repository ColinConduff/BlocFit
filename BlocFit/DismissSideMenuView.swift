//
//  DismissSideMenuView.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/29/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class DismissSideMenuView: UIView {
    
    init(mainVC: MainViewController, sideMenuWidth: CGFloat) {
        let frame = CGRect(
            x: sideMenuWidth,
            y: 0,
            width: mainVC.view.bounds.width - sideMenuWidth,
            height: mainVC.view.bounds.height)
        super.init(frame: frame)
        mainVC.view.addSubview(self)
        
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: mainVC,
            action: #selector(MainViewController.tapHideSideMenu))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
