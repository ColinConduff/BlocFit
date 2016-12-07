//
//  MainViewController+GameKit.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/10/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import GameKit

extension MainViewController: GKGameCenterControllerDelegate, ScoreReporterDelegate {
    
    static let runLeaderboardID = "blocFitRunLeaderboard"
    static let totalScoreLeaderboardID = "blocFitTotalScoreLeaderboard"
    
    /*
     Achievements 
     Distance
     1 mile: 1609 m
     5k    : 5000 m
     10k
     15k
     20k
     half marathon : 21082 m
     25k
     30k
     marathon : 42164 m
     
     Pace
     < 10 min/Mile
     < 9
     < 8
     < 7
     < 6
     < 5
     
     Time 
     30 min, 1 hr, 1.5 hr, 2 hr
     
     Bloc #
     2, 4, 6, 8
    */
    
    func authenticatePlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = { (viewController, error) in
            if let viewController = viewController {
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    func showLeaderboard() {
        let gameCenterViewController = GKGameCenterViewController()
        
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        gameCenterViewController.leaderboardTimeScope = .allTime
        gameCenterViewController.leaderboardIdentifier = MainViewController.runLeaderboardID
        self.present(gameCenterViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore(run: Run) {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated {
            let gkScore = GKScore(leaderboardIdentifier: MainViewController.runLeaderboardID)
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
                leaderboardIdentifier: MainViewController.totalScoreLeaderboardID,
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
