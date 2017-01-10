//
//  MainViewC.swift
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

/**
 Used by the sideMenu to notify the MainViewC that the user would like to segue to an auxiliary view.
 */
internal protocol SegueCoordinationDelegate: class {
    func transition(withSegueIdentifier identifier: String)
}

/**
 Used by the topMenu to notify the MainViewC that the user would like to either open the sideMenu or segue to the current bloc table view or the multipeer browser view.
 */
internal protocol TopMenuDelegate: class {
    func toggleSideMenu()
    func segueToCurrentBlocTable()
    func presentMCBrowserAndStartMCAssistant()
}

/**
 Used by the MultipeerManager to notify the MainViewC that the user has connected with a nearby peer.
 */
internal protocol MultipeerViewHandlerProtocol: class {
    func addToCurrentBloc(blocMember: BlocMember)
    func blocMembersContains(blocMember: BlocMember) -> Bool
}

/**
 Used by the Run History Table to notify the MainViewC that the user would like to display a past run path on the map and its values on the dashboard.
 */
internal protocol LoadRunDelegate: class {
    func tellMapToLoadRun(run: Run)
}

/**
 Used by the MapController to request the current bloc members from the MainViewC.
 */
internal protocol RequestMainDataDelegate: class {
    func getCurrentBlocMembers() -> [BlocMember]
}

/**
 Used by the GameKitManager to request that the MainViewC present GameKit-related view controller.
 */
internal protocol GameViewPresenterDelegate: class {
    func presentGameVC(_ viewController: UIViewController)
}

/**
 The initial view controller for the application.
 
 The MainViewC is responsible for controlling most of the communication and navigation between child view controllers.  It also controls the opening and closing of the side menu view.
 */
final class MainViewC: UIViewController, LoadRunDelegate, RequestMainDataDelegate, SegueCoordinationDelegate, TopMenuDelegate, MultipeerViewHandlerProtocol, GameViewPresenterDelegate {
    
    // MARK: - Properties
    
    private weak var multipeerManagerDelegate: MultipeerManagerDelegate!
    private weak var dashboardUpdateDelegate: DashboardControllerProtocol!
    private weak var mapNotificationDelegate: MapNotificationDelegate!
    private weak var gameKitManagerDelegate: GameKitManagerDelegate!
    
    // used to set the dashboard's delegate in the prepare for segue method
    // need to find a way to do so without keeping this reference
    private weak var mapViewC: MapViewC?
    
    @IBOutlet weak var sideMenuContainerView: UIView!
    @IBOutlet weak var sideMenuContainerWidthConstraint: NSLayoutConstraint!
    
    // Created when the side menu is openned 
    // Destroyed when the side menu is closed
    private weak var dismissSideMenuView: DismissSideMenuView?
    
    // Can be edited by CurrentBlocTableViewC
    // need a better way to synchronize blocMembers array across multiple classes
    private var blocMembers = [BlocMember]() {
        didSet {
            // Notify map and dashboard of change
            mapNotificationDelegate.blocMembersDidChange(blocMembers)
            dashboardUpdateDelegate.update(blocMembersCount: blocMembers.count)
        }
    }
    
    // MARK: - View Controller Lifecycle methods

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
    }
    
    // MARK: - Orientation Transition method
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { coordinatorContext in
            self.tapHideSideMenu()
        }
    }
    
    // MARK: - Side Menu Methods
    
    // should be moved to a separate controller?
    private func hideSideMenu() {
        sideMenuContainerWidthConstraint.constant = 20
        sideMenuContainerView.isHidden = true
    }
    
    // Used by dismiss side menu view UITapGestureRecognizer
    internal func tapHideSideMenu() {
        hideSideMenu()
        sideMenuAnimation()
        dismissSideMenuView?.removeFromSuperview()
    }
    
    private func showSideMenu() {
        let newWidth = view.bounds.width * 2 / 3
        sideMenuContainerWidthConstraint.constant = newWidth
        sideMenuContainerView.isHidden = false
        dismissSideMenuView = DismissSideMenuView(mainVC: self, sideMenuWidth: newWidth)
        sideMenuAnimation()
    }
    
    private func sideMenuAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Action Button IBAction Method
    
    private var actionButtonImageIsStartButton = true
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
    
    // TODO: - Create a Navigator class for managing navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueIdentifier.dashboardEmbedSegue {
            if let dashboardViewC = segue.destination as? DashboardViewC {
                prepareForDashboard(dashboardViewC)
            }
            
        } else if segue.identifier ==  SegueIdentifier.mapEmbedSegue {
            mapViewC = segue.destination as? MapViewC
            prepareForMap(mapViewC!)
            
        } else if segue.identifier ==  SegueIdentifier.runHistoryTableSegue {
            if let runHistoryTableViewC = segue.destination
                as? RunHistoryTableViewC {
                runHistoryTableViewC.loadRunDelegate = self
            }
        } else if segue.identifier == SegueIdentifier.currentBlocTableSegue {
            if let currentBlocTableViewC = segue.destination
                as? CurrentBlocTableViewC {
                
                currentBlocTableViewC.currentBlocTableDataSource = CurrentBlocTableDataSource(blocMembers: blocMembers)
            }
        } else if segue.identifier == SegueIdentifier.sideMenuTableEmbedSegue {
            if let sideMenuTableViewC = segue.destination as? SideMenuTableViewC {
                
                sideMenuTableViewC.tableDelegate = SideMenuTableDelegate(segueCoordinator: self)
            }
        } else if segue.identifier == SegueIdentifier.topMenuEmbedSegue {
            if let topMenuViewC = segue.destination as? TopMenuViewC {
                topMenuViewC.topMenuDelegate = self
            }
        }
    }
    
    private func prepareForDashboard(_ dashboardViewC: DashboardViewC) {
        let dashboardController = DashboardController()
        dashboardViewC.controller = dashboardController
        dashboardUpdateDelegate = dashboardController
        mapViewC?.dashboardUpdateDelegate = dashboardUpdateDelegate
    }
    
    private func prepareForMap(_ mapViewC: MapViewC) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        mapViewC.controller = MapController(requestMainDataDelegate: self, scoreReporterDelegate: GameKitManager.sharedInstance, context: context)
        mapNotificationDelegate = mapViewC.controller as! MapNotificationDelegate!
        mapViewC.dashboardUpdateDelegate = dashboardUpdateDelegate
    }
    
    // Updates the current blocMembers array if the user removes any 
    //  using the current bloc table view
    @IBAction func undwindToMainViewC(_ sender: UIStoryboardSegue) {
        if sender.identifier == SegueIdentifier.unwindFromCurrentBlocTable {
            if let currentBlocTableVC = sender.source as? CurrentBlocTableViewC,
                let currentBlocTableDataSource = currentBlocTableVC.currentBlocTableDataSource {
                blocMembers = currentBlocTableDataSource.blocMembers
            }
        }
    }
    
    // MARK: - LoadRunDelegate method
    
    internal func tellMapToLoadRun(run: Run) {
        mapNotificationDelegate.loadSavedRun(run: run)
    }
    
    // MARK: - RequestMainDataDelegate method 
    // used by the map to get current bloc members
    
    internal func getCurrentBlocMembers() -> [BlocMember] { return blocMembers }
    
    // MARK: - SegueCoordinationDelegate method 
    // (for the side menu)
    
    internal func transition(withSegueIdentifier identifier: String) {
        if identifier == SegueIdentifier.gameCenterSegue {
            gameKitManagerDelegate.showLeaderboard()
        } else {
            performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    // MARK: - TopMenuProtocol methods
    
    internal func segueToCurrentBlocTable() {
        performSegue(withIdentifier: SegueIdentifier.currentBlocTableSegue,
                     sender: self)
    }
    
    internal func toggleSideMenu() {
        sideMenuContainerView.isHidden ? showSideMenu() : hideSideMenu()
    }
    
    // Called from TopMenuViewC when user clicks multipeer button
    internal func presentMCBrowserAndStartMCAssistant() {
        let mcBrowserVC = multipeerManagerDelegate.prepareMCBrowser()
        self.present(mcBrowserVC, animated: true, completion: nil)
    }
    
    // MARK: - MultipeerViewHandlerDelegate methods
    
    internal func blocMembersContains(blocMember: BlocMember) -> Bool {
        // should be in view model not view
        return blocMembers.contains(blocMember)
    }
    
    internal func addToCurrentBloc(blocMember: BlocMember) {
        // should not be handled by view
        DispatchQueue.main.sync {
            blocMembers.append(blocMember)
        }
    }
    
    // MARK: - GameKitManagerDelegate methods
    
    internal func presentGameVC(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}
