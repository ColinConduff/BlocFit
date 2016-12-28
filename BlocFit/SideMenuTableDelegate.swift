//
//  SideMenuTableDelegate.swift
//  BlocFit
//
//  Created by Colin Conduff on 12/27/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit

class SideMenuTableDelegate: NSObject, UITableViewDelegate {
    
    var seguePerformer: SegueCoordinationDelegate
    
    init(segueCoordinator: SegueCoordinationDelegate) {
        self.seguePerformer = segueCoordinator
    }
    
    // Make the profile cell larger to accomodate more information
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Cell.profile.sec &&
            indexPath.row == Cell.profile.row {
            return 80
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let segueIdentifier = segueIdentifier(section: indexPath.section,
                                                 row: indexPath.row) {
            seguePerformer.transition(withSegueIdentifier: segueIdentifier)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Section and row numbers corresponding to static table cells
    private struct Cell {
        static let profile = (sec: 0, row: 0)
        static let friends = (sec: 1, row: 0)
        static let gameCenter = (sec: 1, row: 1)
        static let runHistory = (sec: 2, row: 0)
        static let statistics = (sec: 2, row: 1)
        static let settings = (sec: 3, row: 0)
    }
    
    // Return the segueIdentifier corresponding to the selected static table cell
    private func segueIdentifier(section: Int, row: Int) -> String? {
        var segueIdentifier: String?
        
        if section == Cell.friends.sec ||
            section == Cell.gameCenter.sec {
            
            if row == Cell.friends.row {
                segueIdentifier = SegueIdentifier.friendTableSegue
                
            } else if row == Cell.gameCenter.row {
                segueIdentifier = SegueIdentifier.gameCenterSegue
            }
            
        } else if section == Cell.runHistory.sec ||
            section == Cell.statistics.sec {
            
            if row == Cell.runHistory.row {
                segueIdentifier = SegueIdentifier.runHistoryTableSegue
                
            } else if row == Cell.statistics.row {
                segueIdentifier = SegueIdentifier.statisticsTableSegue
            }
            
        } else if section == Cell.settings.sec &&
            row == Cell.settings.row {
            
            segueIdentifier = SegueIdentifier.settingsTableSegue
        }
        
        return segueIdentifier
    }
}
