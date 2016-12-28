//
//  MainViewController+Multipeer.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/4/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import FBSDKLoginKit

extension MainViewController {
    
    // TopMenuProtocol method
    // Called from TopMenuViewController when user clicks multipeer button
    func presentMCBrowserAndStartMCAssistant() {
        disableAdvertiserAndBrowser()
        
        mcBrowserVC = MCBrowserViewController(
            serviceType: MPConstant.serviceType,
            session: session!)
        mcBrowserVC!.delegate = self
        
        mcAssistant = MCAdvertiserAssistant(
            serviceType: MPConstant.serviceType,
            discoveryInfo: nil,
            session: session!)
        mcAssistant!.delegate = self
        mcAssistant!.start()
        
        self.present(mcBrowserVC!, animated: true, completion: nil)
    }
    
    func disableAssistantAndBrowserVC() {
        mcAssistant?.stop()
        mcBrowserVC = nil
        mcAssistant = nil
    }
    
    func createAndStartMCAdvertiserAndMCBrowser() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(
            peer: peerID!,
            discoveryInfo: nil,
            serviceType: MPConstant.serviceType)
        serviceBrowser = MCNearbyServiceBrowser(
            peer: peerID!,
            serviceType: MPConstant.serviceType)
        
        serviceAdvertiser!.delegate = self
        serviceBrowser!.delegate = self
        
        serviceAdvertiser!.startAdvertisingPeer()
        serviceBrowser!.startBrowsingForPeers()
    }
    
    func disableAdvertiserAndBrowser() {
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceBrowser?.stopBrowsingForPeers()
        serviceAdvertiser = nil
        serviceBrowser = nil
    }
    
    func disableMultipeerConnectivity() {
        disableAssistantAndBrowserVC()
        disableAdvertiserAndBrowser()
    }
    
    func sendMessage(message: String, toPeers: [MCPeerID]) {
        NSLog("%@", "sending message: \(message)")
        if session!.connectedPeers.count > 0 {
            let data = message.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                try self.session!.send(data, toPeers: toPeers, with: .reliable)
            } catch let error {
                NSLog("%@", "\(error)")
            }
        }
    }
    
    func sendJsonMessage(toPeers: [MCPeerID]) {
        
        let username = owner!.username!
        let totalScore = owner!.totalScore
        var firstname: String? = nil
        
        // Will send nil name if message is sent before fb is authenticated
        if BFUserDefaults.getShareFirstNameWithTrustedSetting() {
            if FBSDKAccessToken.current() != nil,
                let profile = FBSDKProfile.current() {
                
                firstname = profile.firstName
            }
        }
        
        print("sendJsonMessage: firstname \(firstname)")
        
        let jsonDictionary: [String: Any?] = [
            "username": username,
            "totalScore": totalScore,
            "firstname": firstname
        ]
        
        if session!.connectedPeers.count > 0 {
            do {
                if let jsonData = try? JSONSerialization.data(
                    withJSONObject: jsonDictionary,
                    options: .prettyPrinted) {
                    try self.session!.send(jsonData, toPeers: toPeers, with: .reliable)
                } else {
                    print("Unable to serialize json data")
                }
            } catch let error {
                NSLog("%@", "\(error)")
            }
        }
    }
    
    func handleBlocMemberData(username: String, totalScore: Int32, firstname: String?) {
        
        var blocMember = getBlocMember(username: username)
        
        if blocMember == nil {
            blocMember = createBlocMember(
                username: username,
                totalScore: totalScore,
                firstname: firstname)
        
        } else {
            try? blocMember!.update(totalScore: totalScore)
            try? blocMember!.update(firstname: firstname)
        }
        
        if let blocMember = blocMember, !blocMembers.contains(blocMember) {
            DispatchQueue.main.sync {
                blocMembers.append(blocMember)
            }
        }
    }
    
    func shouldConnect(peerUsername: String, shouldNotHaveAlreadyConnected: Bool) -> Bool {
        
        let dontCareIfAlreadyConnected = !shouldNotHaveAlreadyConnected

        if let ownerUsername = owner?.username,
            let blocMember = getBlocMember(username: peerUsername),
            
            blocMember.trusted &&
                peerUsername != ownerUsername &&
                    (dontCareIfAlreadyConnected ||
                        shouldNotHaveAlreadyConnected && !blocMembers.contains(blocMember)) {
            
            return true
        }
        return false
    }
}

extension MainViewController: MCBrowserViewControllerDelegate, MCAdvertiserAssistantDelegate {
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
    
    func browserViewController(
        _ browserViewController: MCBrowserViewController,
        shouldPresentNearbyPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?)
        -> Bool {
        return true
    }
}

extension MainViewController: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error) { }
    
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?)
        -> Void) {
        
        let peerUsername = peerID.displayName
        let shouldAcceptInvite = shouldConnect(
            peerUsername: peerUsername,
            shouldNotHaveAlreadyConnected: false)
        
        invitationHandler(shouldAcceptInvite, self.session)
    }
}

extension MainViewController: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) { }
    
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?) {
        
        if shouldConnect(
            peerUsername: peerID.displayName,
            shouldNotHaveAlreadyConnected: true) {
            
            browser.invitePeer(
                peerID,
                to: session!,
                withContext: nil,
                timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) { }
}

extension MainViewController: MCSessionDelegate {
    
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
