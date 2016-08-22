//
//  GKGameCenterViewController.swift
//  swiftris
//
//  Created by Lisa on 8/20/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import Foundation
import GameKit

class GameCenterViewController: UIViewController, GKGameCenterControllerDelegate {
    
    func showLeaderboard() {
        var gameCenterController = GKGameCenterViewController()
            gameCenterController.gameCenterDelegate = self
            gameCenterController.viewState = .Leaderboards
            gameCenterController.leaderboardTimeScope = .Today
            gameCenterController.leaderboardIdentifier = "scores";
            self.presentViewController(gameCenterController, animated: true, completion: { _ in })
    }
    
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        // TODO: Code to restart the game
        //gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        print("gameCenterViewControllerDidFinish");
    }

}