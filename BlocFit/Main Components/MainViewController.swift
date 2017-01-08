//
//  MainViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MultipeerConnectivity
import GameKit

protocol SegueCoordinationDelegate: class {
    func transition(withSegueIdentifier identifier: String)
}

protocol TopMenuDelegate: class {
    func toggleSideMenu()
    func segueToCurrentBlocTable()
    func presentMCBrowserAndStartMCAssistant()
}

protocol MultipeerViewHandlerProtocol: class {
    func addToCurrentBloc(blocMember: BlocMember)
    func blocMembersContains(blocMember: BlocMember) -> Bool
}

protocol LoadRunDelegate: class {
    func tellMapToLoadRun(run: Run)
}

protocol RequestMainDataDelegate: class {
    func getCurrentBlocMembers() -> [BlocMember]
}

protocol GameViewPresenterDelegate: class {
    func presentGameVC(_ viewController: UIViewController)
}

class MainViewController: UIViewController, LoadRunDelegate, RequestMainDataDelegate, SegueCoordinationDelegate, TopMenuDelegate, MultipeerViewHandlerProtocol, GameViewPresenterDelegate {
    
    weak var multipeerManagerDelegate: MultipeerManagerDelegate!
    weak var dashboardUpdateDelegate: DashboardControllerProtocol!
    weak var mapNotificationDelegate: MapNotificationDelegate!
    weak var gameKitManagerDelegate: GameKitManagerDelegate!
    
    // used to set the dashboard's delegate in the prepare for segue method
    // need to find a way to do so without keeping this reference
    weak var mapViewController: MapViewController?
    
    @IBOutlet weak var sideMenuContainerView: UIView!
    @IBOutlet weak var sideMenuContainerWidthConstraint: NSLayoutConstraint!
    
    // Created when the side menu is openned 
    // Destroyed when the side menu is closed
    weak var dismissSideMenuView: DismissSideMenuView?
    
    // Can be edited by CurrentBlocTableViewController
    // need a better way to synchronize blocMembers array across multiple classes
    var blocMembers = [BlocMember]() {
        didSet {
            // Notify map and dashboard of change
            mapNotificationDelegate.blocMembersDidChange(blocMembers)
            dashboardUpdateDelegate.update(blocMembersCount: blocMembers.count)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideSideMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        GameKitManager.sharedInstance.gameViewPresenterDelegate = self
        gameKitManagerDelegate = GameKitManager.sharedInstance
        
        multipeerManagerDelegate = MultipeerManager.sharedInstance
        MultipeerManager.sharedInstance.multipeerViewHandlerDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameKitManagerDelegate.authenticatePlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { coordinatorContext in
            self.tapHideSideMenu()
        }
    }
    
    // Side Menu Functions //
    
    // should be moved to side menu displayer view model?
    func hideSideMenu() {
        sideMenuContainerWidthConstraint.constant = 20
        sideMenuContainerView.isHidden = true
    }
    
    func tapHideSideMenu() {
        hideSideMenu()
        sideMenuAnimation()
        dismissSideMenuView?.removeFromSuperview()
    }
    
    func showSideMenu() {
        let newWidth = view.bounds.width * 2 / 3
        sideMenuContainerWidthConstraint.constant = newWidth
        sideMenuContainerView.isHidden = false
        dismissSideMenuView = DismissSideMenuView(mainVC: self, sideMenuWidth: newWidth)
        sideMenuAnimation()
    }
    
    func sideMenuAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    var actionButtonImageIsStartButton = true
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        let authorizedToProceed = mapNotificationDelegate.didPressActionButton()
        
        if authorizedToProceed {
            if actionButtonImageIsStartButton {
                sender.setImage(#imageLiteral(resourceName: "StopRunButton"), for: .normal)
            } else {
                sender.setImage(#imageLiteral(resourceName: "StartRunButton"), for: .normal)
            }
            actionButtonImageIsStartButton = !actionButtonImageIsStartButton
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueIdentifier.dashboardEmbedSegue {
            if let dashboardViewController = segue.destination as? DashboardViewController {
                prepareForDashboard(dashboardViewController)
            }
            
        } else if segue.identifier ==  SegueIdentifier.mapEmbedSegue {
            mapViewController = segue.destination as? MapViewController
            prepareForMap(mapViewController!)
            
        } else if segue.identifier ==  SegueIdentifier.runHistoryTableSegue {
            if let runHistoryTableViewController = segue.destination
                as? RunHistoryTableViewController {
                runHistoryTableViewController.loadRunDelegate = self
            }
        } else if segue.identifier == SegueIdentifier.currentBlocTableSegue {
            if let currentBlocTableViewController = segue.destination
                as? CurrentBlocTableViewController {
                
                currentBlocTableViewController.currentBlocTableDataSource = CurrentBlocTableDataSource(blocMembers: blocMembers)
            }
        } else if segue.identifier == SegueIdentifier.sideMenuTableEmbedSegue {
            if let sideMenuTableViewController = segue.destination as? SideMenuTableViewController {
                
                sideMenuTableViewController.tableDelegate = SideMenuTableDelegate(segueCoordinator: self)
            }
        } else if segue.identifier == SegueIdentifier.topMenuEmbedSegue {
            if let topMenuViewController = segue.destination as? TopMenuViewController {
                topMenuViewController.topMenuDelegate = self
            }
        }
    }
    
    func prepareForDashboard(_ dashboardViewController: DashboardViewController) {
        let dashboardController = DashboardController()
        dashboardViewController.controller = dashboardController
        dashboardUpdateDelegate = dashboardController
        mapViewController?.dashboardUpdateDelegate = dashboardUpdateDelegate
    }
    
    func prepareForMap(_ mapViewController: MapViewController) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        mapViewController.controller = MapController(requestMainDataDelegate: self, scoreReporterDelegate: GameKitManager.sharedInstance, context: context)
        mapNotificationDelegate = mapViewController.controller as! MapNotificationDelegate!
        mapViewController.dashboardUpdateDelegate = dashboardUpdateDelegate
    }
    
    @IBAction func undwindToMainViewController(_ sender: UIStoryboardSegue) {
        if sender.identifier == SegueIdentifier.unwindFromCurrentBlocTable {
            if let currentBlocTableVC = sender.source
                as? CurrentBlocTableViewController,
                let currentBlocTableDataSource = currentBlocTableVC.currentBlocTableDataSource {
                blocMembers = currentBlocTableDataSource.blocMembers
            }
        }
    }
    
    // LoadRunDelegate function
    func tellMapToLoadRun(run: Run) {
        mapNotificationDelegate.loadSavedRun(run: run)
    }
    
    // RequestMainDataDelegate method for map to get current bloc members
    
    func getCurrentBlocMembers() -> [BlocMember] { return blocMembers }
    
    // SegueCoordinationDelegate method (for the side menu)
    
    func transition(withSegueIdentifier identifier: String) {
        if identifier == SegueIdentifier.gameCenterSegue {
            gameKitManagerDelegate.showLeaderboard()
        } else {
            performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    // TopMenuProtocol methods 
    
    func segueToCurrentBlocTable() {
        performSegue(withIdentifier: SegueIdentifier.currentBlocTableSegue,
                     sender: self)
    }
    
    func toggleSideMenu() {
        sideMenuContainerView.isHidden ? showSideMenu() : hideSideMenu()
    }
    
    // Called from TopMenuViewController when user clicks multipeer button
    func presentMCBrowserAndStartMCAssistant() {
        let mcBrowserVC = multipeerManagerDelegate.prepareMCBrowser()
        self.present(mcBrowserVC, animated: true, completion: nil)
    }
    
    // MultipeerViewHandlerDelegate methods
    
    func blocMembersContains(blocMember: BlocMember) -> Bool {
        // should be in view model not view
        return blocMembers.contains(blocMember)
    }
    
    func addToCurrentBloc(blocMember: BlocMember) {
        // should not be handled by view
        DispatchQueue.main.sync {
            blocMembers.append(blocMember)
        }
    }
    
    // GameKitManagerDelegate methods
    
    func presentGameVC(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}
