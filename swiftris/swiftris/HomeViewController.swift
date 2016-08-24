//
//  HomeViewController.swift
//  swiftris
//
//  Created by Lisa on 6/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit


class HomeViewController: UIViewController, UIGestureRecognizerDelegate, GKGameCenterControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        AppDelegate.gc.authenticateLocalPlayer(self);
    }
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if segue.identifier == "Classic" || segue.identifier == "Timed" {
            // we downcast (as!) from UIViewController to GameViewController because UIViewController doesn't have a "gameType" property, which we access below
            let gameViewController = segue.destinationViewController as! GameViewController
            gameViewController.gameType = GamePlayChoice(rawValue: segue.identifier!)
        }
    }
    
    @IBAction func showGameCenter(sender: UIView!) {
        let gameCenterController = GKGameCenterViewController()
        gameCenterController.gameCenterDelegate = self
        
        if (sender.tag == 3) {
            gameCenterController.viewState = .Leaderboards
            gameCenterController.leaderboardTimeScope = .Today
            gameCenterController.leaderboardIdentifier = "scores";
        } else {
            gameCenterController.viewState = .Achievements
        }
        self.presentViewController(gameCenterController, animated: true, completion: { _ in })
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        print("gameCenterViewControllerDidFinish");
    }
}




