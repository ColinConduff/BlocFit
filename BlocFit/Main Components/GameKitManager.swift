//
//  GameKitManager.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/10/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import GameKit

protocol ScoreReporterDelegate: class {
    func submitScore(run: Run)
    func submitScore(owner: Owner)
}

protocol GameKitManagerDelegate: class {
    func authenticatePlayer()
    func showLeaderboard()
}

class GameKitManager: NSObject, GKGameCenterControllerDelegate, GameKitManagerDelegate, ScoreReporterDelegate {
    
    static let runLeaderboardID = "blocFitRunLeaderboard"
    static let totalScoreLeaderboardID = "blocFitTotalScoreLeaderboard"
    
    weak var gameViewPresenterDelegate: GameViewPresenterDelegate!
    
    static let sharedInstance = GameKitManager()
    
    func authenticatePlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = { (viewController, error) in
            if let viewController = viewController {
                self.gameViewPresenterDelegate.presentGameVC(viewController)
            }
        }
    }
    
    func showLeaderboard() {
        let gameCenterViewC = GKGameCenterViewController()
        
        gameCenterViewC.gameCenterDelegate = self
        gameCenterViewC.viewState = .leaderboards
        gameCenterViewC.leaderboardTimeScope = .allTime
        gameCenterViewC.leaderboardIdentifier = GameKitManager.runLeaderboardID
        
        gameViewPresenterDelegate.presentGameVC(gameCenterViewC)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore(run: Run) {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated {
            let gkScore = GKScore(leaderboardIdentifier: GameKitManager.runLeaderboardID)
            gkScore.value = Int64(run.score)
            
            GKScore.report([gkScore]) { (error) in
                if let error = error {
                    self.showBanner(submissionSuccessful: false)
                    print(error)
                } else {
                    self.showBanner(submissionSuccessful: true)
                }
            }
        }
    }
    
    func submitScore(owner: Owner) {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated {
            let gkScore = GKScore(
                leaderboardIdentifier: GameKitManager.totalScoreLeaderboardID,
                player: localPlayer)
            gkScore.value = Int64(owner.totalScore)
            
            GKScore.report([gkScore]) { (error) in
                if let error = error {
                    self.showBanner(submissionSuccessful: false)
                    print(error)
                }
            }
        }
    }
    
    func showBanner(submissionSuccessful: Bool) {
        if submissionSuccessful {
            GKNotificationBanner.show(
                withTitle: "Score Submitted",
                message: "Score submitted to Game Center",
                duration: 5,
                completionHandler: nil)
        } else {
            GKNotificationBanner.show(
                withTitle: "Score Not Submitted",
                message: "Unable to submit score to Game Center",
                duration: 5,
                completionHandler: nil)
        }
    }
}
