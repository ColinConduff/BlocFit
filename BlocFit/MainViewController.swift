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

class MainViewController: UIViewController, LoadRunDelegate, RequestMainDataDelegate, SegueCoordinationDelegate, TopMenuDelegate {
    
    weak var dashboardUpdateDelegate: DashboardViewModelProtocol!
    weak var mapViewController: MapViewController?
    weak var sideMenuDelegate: SideMenuDelegate?
    
    @IBOutlet weak var menuView: UIView! // change to side menu
    @IBOutlet weak var menuWidthConstraint: NSLayoutConstraint! // change to side menu
    
    // Created when the side menu is openned 
    // Destroyed when the side menu is closed
    var dismissSubview: UIView?
    
    // Can be edited by CurrentBlocTableViewController
    var blocMembers = [BlocMember]() {
        didSet {
            // Notify map and dashboard of change
            mapViewController?.updateCurrentRunWith(blocMembers: blocMembers)
            dashboardUpdateDelegate?.update(blocMembersCount: blocMembers.count)
        }
    }
    
    var owner: Owner?
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // Multipeer related
    var peerID: MCPeerID?
    var session: MCSession?
    var mcAssistant: MCAdvertiserAssistant?
    var mcBrowserVC: MCBrowserViewController?
    var serviceAdvertiser: MCNearbyServiceAdvertiser?
    var serviceBrowser: MCNearbyServiceBrowser?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideSideMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        owner = getOwner()
        peerID = MCPeerID(displayName: owner!.username!)
        session = createSession(peerID: peerID!)
        createAndStartMCAdvertiserAndMCBrowser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        authenticatePlayer()
        
        sideMenuDelegate?.setScrollable(
            isScrollable: UIDevice.current.orientation == .landscapeLeft ||
                UIDevice.current.orientation == .landscapeRight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: afterRotation)
    }
    
    func afterRotation(_ coordinatorContext: UIViewControllerTransitionCoordinatorContext) {
        tapHideSideMenu()
        
        sideMenuDelegate?.setScrollable(
            isScrollable: UIDevice.current.orientation == .landscapeLeft ||
                          UIDevice.current.orientation == .landscapeRight)
    }
    
    // Side Menu Functions //
    func hideSideMenu() {
        menuWidthConstraint.constant = 20
        menuView.isHidden = true
    }
    
    func tapHideSideMenu() {
        hideSideMenu()
        sideMenuAnimation()
        removeDismissSubview()
    }
    
    func showSideMenu() {
        let newWidth = view.bounds.width * 2 / 3
        menuWidthConstraint.constant = newWidth
        menuView.isHidden = false
        addDismissSubview(sideMenuWidth: newWidth)
        sideMenuAnimation()
    }
    
    func addDismissSubview(sideMenuWidth: CGFloat) {
        let frame = CGRect(
            x: sideMenuWidth,
            y: 0,
            width: view.bounds.width - sideMenuWidth,
            height: view.bounds.height)
        dismissSubview = UIView(frame: frame)
        view.addSubview(dismissSubview!)
        
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapHideSideMenu))
        dismissSubview?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func removeDismissSubview() {
        dismissSubview?.removeFromSuperview()
    }
    
    func sideMenuAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    var actionButtonImageIsStartButton = true
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            alertTheUserThatLocationServicesAreDisabled()
        } else {
        
            if actionButtonImageIsStartButton {
                sender.setImage(#imageLiteral(resourceName: "StopRunButton"), for: .normal)
            } else {
                sender.setImage(#imageLiteral(resourceName: "StartRunButton"), for: .normal)
            }
        
            actionButtonImageIsStartButton = !actionButtonImageIsStartButton
            mapViewController?.didPressActionButton()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueIdentifier.dashboardEmbedSegue {
            if let dashboardViewController = segue.destination as? DashboardViewController {
                let dashboardViewModel = DashboardViewModel()
                dashboardViewController.viewModel = dashboardViewModel
                dashboardUpdateDelegate = dashboardViewModel
                mapViewController?.dashboardUpdateDelegate = dashboardUpdateDelegate
            }
            
        } else if segue.identifier ==  SegueIdentifier.mapEmbedSegue {
            mapViewController = segue.destination as? MapViewController
            mapViewController!.dashboardUpdateDelegate = dashboardUpdateDelegate
            mapViewController!.mainVCDataDelegate = self
            mapViewController!.scoreReporterDelegate = self
            
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
                sideMenuDelegate = sideMenuTableViewController
            }
        } else if segue.identifier == SegueIdentifier.topMenuEmbedSegue {
            if let topMenuViewController = segue.destination as? TopMenuViewController {
                topMenuViewController.topMenuDelegate = self
            }
        }
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
    
    func getOwner() -> Owner? {
        var owner: Owner?
        do {
            owner = try Owner.get(context: context!)
        } catch let error {
            print(error)
        }
        return owner
    }
    
    func getBlocMember(username: String) -> BlocMember? {
        var blocMember: BlocMember?
        do {
            blocMember = try BlocMember.get(username: username, context: context!)
        } catch let error {
            print(error)
        }
        return blocMember
    }
    
    func createBlocMember(
        username: String, totalScore: Int32, firstname: String?) -> BlocMember? {

        var blocMember: BlocMember?

        do {
            blocMember = try BlocMember.create(
                username: username,
                totalScore: totalScore,
                firstname: firstname,
                context: context!)
        } catch let error {
            print(error)
        }
        return blocMember
    }
    
    func createSession(peerID: MCPeerID) -> MCSession {
        let session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required)
        
        session.delegate = self
        
        return session
    }
    
    // LoadRunDelegate function
    func tellMapToLoadRun(run: Run) {
        mapViewController?.loadSavedRun(run: run)
    }
    
    // RequestMainDataDelegate method for map to get current bloc members
    func getCurrentBlocMembers() -> [BlocMember] {
        return blocMembers
    }
    
    // Called if location auth status is not authorized always
    func alertTheUserThatLocationServicesAreDisabled() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please authorize BlocFit to access your location.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Open Settings", style: .default) {
            _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // SegueCoordinationDelegate method
    func transition(withSegueIdentifier identifier: String) {
        if identifier == SegueIdentifier.gameCenterSegue {
            showLeaderboard()
        } else {
            performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    // TopMenuProtocol methods 
    
    func segueToCurrentBlocTable() {
        performSegue(withIdentifier: SegueIdentifier.currentBlocTableSegue, sender: self)
    }
    
    func toggleSideMenu() {
        if menuView.isHidden {
            showSideMenu()
        } else {
            hideSideMenu()
        }
    }
}
