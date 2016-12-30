//
//  MultipeerManager.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/4/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import CoreData
import MultipeerConnectivity

import FBSDKLoginKit // move to an fb view model/manager

struct MultipeerModel {
    var username: String
    var totalScore: Int32
    var firstName: String?
    
    init(username: String, totalScore: Int32, firstName: String? = nil) {
        self.username = username
        self.totalScore = totalScore
        self.firstName = firstName
    }
}

protocol MultipeerManagerProtocol: class {
    var multipeerModel: MultipeerModel { get }
    
    init(context: NSManagedObjectContext)
    
    func prepareMCBrowser() -> MCBrowserViewController
}

class MultipeerManager: NSObject, MultipeerManagerProtocol {
    
    var multipeerViewHandlerDelegate: MultipeerViewHandlerProtocol!
    
    var multipeerModel: MultipeerModel
    
    let context: NSManagedObjectContext
    let peerID: MCPeerID
    var session: MCSession
    
    var mcAssistant: MCAdvertiserAssistant?
    var mcBrowserVC: MCBrowserViewController?
    var serviceAdvertiser: MCNearbyServiceAdvertiser?
    var serviceBrowser: MCNearbyServiceBrowser?
    
    required init(context: NSManagedObjectContext) {

        self.context = context
        
        let owner = try! Owner.get(context: context)!
        let username = owner.username!
        let totalScore = owner.totalScore
        
        multipeerModel = MultipeerModel(username: username,
                                        totalScore: totalScore)
        
        peerID = MCPeerID(displayName: multipeerModel.username)
        
        session = MCSession(peer: peerID,
                            securityIdentity: nil,
                            encryptionPreference: .required)
        
        super.init()
        
        session.delegate = self
        
        createAndStartMCAdvertiserAndMCBrowser()
    }
    
    private func refreshModel() {
        let owner = try! Owner.get(context: context)!
        let username = owner.username!
        let totalScore = owner.totalScore
        let fbName = fbFirstName()
        
        multipeerModel = MultipeerModel(username: username,
                                        totalScore: totalScore,
                                        firstName: fbName)
    }
    
    private func fbFirstName() -> String? {
        var firstname: String? = nil
        
        if BFUserDefaults.getShareFirstNameWithTrustedSetting() {
            if FBSDKAccessToken.current() != nil,
                let profile = FBSDKProfile.current() {
                
                firstname = profile.firstName
            }
        }
        
        return firstname
    }
    
    // MultipeerManagerProtocol method called when
    // user clicks top menu's "+" button
    func prepareMCBrowser() -> MCBrowserViewController {
        disableAdvertiserAndBrowser()
        
        mcBrowserVC = MCBrowserViewController(serviceType: MPConstant.serviceType,
                                              session: session)
        mcBrowserVC!.delegate = self
        
        mcAssistant = MCAdvertiserAssistant(serviceType: MPConstant.serviceType,
                                            discoveryInfo: nil,
                                            session: session)
        mcAssistant!.delegate = self
        mcAssistant!.start()
        
        return mcBrowserVC!
    }
    
    fileprivate func disableAssistantAndBrowserVC() {
        mcAssistant?.stop()
        mcBrowserVC = nil
        mcAssistant = nil
    }
    
    fileprivate func createAndStartMCAdvertiserAndMCBrowser() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                                      discoveryInfo: nil,
                                                      serviceType: MPConstant.serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID,
                                                serviceType: MPConstant.serviceType)
        
        serviceAdvertiser!.delegate = self
        serviceBrowser!.delegate = self
        
        serviceAdvertiser!.startAdvertisingPeer()
        serviceBrowser!.startBrowsingForPeers()
    }
    
    fileprivate func disableAdvertiserAndBrowser() {
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceBrowser?.stopBrowsingForPeers()
        serviceAdvertiser = nil
        serviceBrowser = nil
    }
    
    fileprivate func disableMultipeerConnectivity() {
        disableAssistantAndBrowserVC()
        disableAdvertiserAndBrowser()
    }
    
    // not used
    func sendMessage(message: String, toPeers: [MCPeerID]) {
        NSLog("%@", "sending message: \(message)")
        if session.connectedPeers.count > 0 {
            let data = message.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                try self.session.send(data, toPeers: toPeers, with: .reliable)
            } catch let error {
                NSLog("%@", "\(error)")
            }
        }
    }
    
    func sendJsonMessage(toPeers: [MCPeerID]) {
        
        refreshModel()
        
        let jsonDictionary: [String: Any?] = [
            "username": multipeerModel.username,
            "totalScore": multipeerModel.totalScore,
            "firstname": multipeerModel.firstName
        ]
        
        //print("sendJsonMessage: firstname \(firstname)")
        
        if session.connectedPeers.count > 0 {
            do {
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary,
                                                              options: .prettyPrinted) {
                    try self.session.send(jsonData, toPeers: toPeers, with: .reliable)
                } else {
                    print("Unable to serialize json data")
                }
            } catch let error {
                NSLog("%@", "\(error)")
            }
        }
    }
    
    func handleBlocMemberData(username: String, totalScore: Int32, firstname: String?) {
        
        var blocMember = try! BlocMember.get(username: username, context: context)
        
        if blocMember == nil {
            blocMember = try! BlocMember.create(username: username,
                                                totalScore: totalScore,
                                                firstname: firstname,
                                                context: context)
        } else {
            try! blocMember!.update(totalScore: totalScore)
            try! blocMember!.update(firstname: firstname)
        }
        
        // Notify mainVC of change to bloc
        if let blocMember = blocMember,
            !multipeerViewHandlerDelegate.blocMembersContains(blocMember: blocMember) {
            multipeerViewHandlerDelegate.addToCurrentBloc(blocMember: blocMember)
        }
    }
    
    func shouldConnect(peerUsername: String, shouldNotHaveAlreadyConnected: Bool) -> Bool {
        
        let dontCareIfAlreadyConnected = !shouldNotHaveAlreadyConnected

        if let blocMember = try! BlocMember.get(username: peerUsername, context: context) {
            
            // ask mainVC if blocMember already in current bloc
            let haveNotAlreadyConnected = !multipeerViewHandlerDelegate.blocMembersContains(blocMember: blocMember)
            
            return blocMember.trusted &&
                     peerUsername != multipeerModel.username &&
                        (dontCareIfAlreadyConnected ||
                        shouldNotHaveAlreadyConnected && haveNotAlreadyConnected)
        }
        return false
    }
}

extension MultipeerManager: MCBrowserViewControllerDelegate, MCAdvertiserAssistantDelegate {
    func restartBrowserAdvertiser() {
        createAndStartMCAdvertiserAndMCBrowser()
        disableAssistantAndBrowserVC()
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: restartBrowserAdvertiser)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: restartBrowserAdvertiser)
    }
    
    func browserViewController(_ browserViewController: MCBrowserViewController,
                               shouldPresentNearbyPeer peerID: MCPeerID,
                               withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: Error) { }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let peerUsername = peerID.displayName
        let shouldAcceptInvite = shouldConnect(
            peerUsername: peerUsername,
            shouldNotHaveAlreadyConnected: false)
        
        invitationHandler(shouldAcceptInvite, self.session)
    }
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) { }
    
    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        
        if shouldConnect(peerUsername: peerID.displayName,
                         shouldNotHaveAlreadyConnected: true) {
            
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) { }
}

extension MultipeerManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            sendJsonMessage(toPeers: [peerID])
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any?],
            let username = json?["username"] as? String,
            let totalScore = json?["totalScore"] as? Int32,
            let firstname = json?["firstname"] as? String? {
            
            handleBlocMemberData(
                username: username,
                totalScore: totalScore,
                firstname: firstname)
        
        } else if let message = NSString(
            data: data,
            encoding: String.Encoding.utf8.rawValue) as? String {
            print("Received message: \(message)")
        }
    }
    
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID) { }
    
    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL,
        withError error: Error?) { }
    
    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress) { }
}
